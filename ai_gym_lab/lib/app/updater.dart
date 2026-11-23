// 앱 업데이트: GitHub 릴리스(gym-v*)에서 새 버전을 찾아 내려받고 안드로이드 설치 화면을 엽니다.
// 플레이 스토어 밖 앱은 안드로이드 보안 규칙상 사용자가 「설치」를 직접 눌러야 합니다.
// 토큰·크레딧은 쓰지 않습니다(GitHub에 버전만 물어봄).
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

const updateRepo = 'thdnd456-maker/ai-daily';
const updateTagPrefix = 'gym-v';

class UpdateInfo {
  final String version;
  final String apkUrl;
  final int size;
  final String notes;
  const UpdateInfo({required this.version, required this.apkUrl, required this.size, required this.notes});
}

/// "1.2.0", "v1.2.0", "1.2.0+7" → [1, 2, 0]. 해석할 수 없으면 null.
List<int>? parseVersion(String v) {
  final core = v.trim().replaceFirst(RegExp(r'^v'), '').split('+').first.split('-').first;
  final parts = core.split('.');
  if (parts.isEmpty || parts.length > 4) return null;
  final nums = <int>[];
  for (final p in parts) {
    final n = int.tryParse(p);
    if (n == null) return null;
    nums.add(n);
  }
  return nums;
}

/// a가 b보다 새 버전이면 true
bool isNewerVersion(String a, String b) {
  final x = parseVersion(a), y = parseVersion(b);
  if (x == null || y == null) return false;
  for (var i = 0; i < 4; i++) {
    final p = i < x.length ? x[i] : 0, q = i < y.length ? y[i] : 0;
    if (p != q) return p > q;
  }
  return false;
}

/// 릴리스 설명(마크다운)에서 「바뀐 것」 부분만 짧게 뽑아 보기 좋게 만듭니다.
String summarizeNotes(String body) {
  final lines = body.split('\n');
  final start = lines.indexWhere((l) => l.startsWith('##') && l.contains('바뀐'));
  final picked = <String>[];
  if (start >= 0) {
    for (final l in lines.skip(start + 1)) {
      if (l.startsWith('##')) break;
      picked.add(l);
    }
  }
  final text = picked
      .map((l) => l.replaceAll('**', '').replaceAll('`', '').replaceFirst(RegExp(r'^\s*-\s*'), '· ').trimRight())
      .where((l) => l.trim().isNotEmpty)
      .join('\n');
  return text.length > 400 ? '${text.substring(0, 400)}…' : text;
}

/// GitHub releases API 응답(JSON 배열)에서 현재 버전보다 새 것 중 가장 최신을 고릅니다.
UpdateInfo? pickUpdate(List<dynamic> releases, String currentVersion) {
  UpdateInfo? best;
  for (final r in releases) {
    if (r is! Map) continue;
    if (r['draft'] == true || r['prerelease'] == true) continue;
    final tag = '${r['tag_name'] ?? ''}';
    if (!tag.startsWith(updateTagPrefix)) continue;
    final version = tag.substring(updateTagPrefix.length);
    if (parseVersion(version) == null || !isNewerVersion(version, currentVersion)) continue;
    if (best != null && !isNewerVersion(version, best.version)) continue;
    Map? apk;
    for (final a in (r['assets'] as List?) ?? const []) {
      if (a is Map && '${a['name']}'.toLowerCase().endsWith('.apk')) {
        apk = a;
        break;
      }
    }
    if (apk == null) continue;
    best = UpdateInfo(
      version: version,
      apkUrl: '${apk['browser_download_url']}',
      size: (apk['size'] as num?)?.toInt() ?? 0,
      notes: summarizeNotes('${r['body'] ?? ''}'),
    );
  }
  return best;
}

class Updater {
  static const _ch = MethodChannel('aigymlab/updater');
  final http.Client client;
  Updater({http.Client? client}) : client = client ?? http.Client();

  static bool get supported => Platform.isAndroid;

  Future<String?> currentVersion() async {
    if (!supported) return null;
    return _ch.invokeMethod<String>('getVersion');
  }

  /// 새 버전이 있으면 정보를, 없으면 null을 돌려줍니다. 인터넷 오류는 예외로 던집니다.
  Future<UpdateInfo?> check() async {
    final current = await currentVersion();
    if (current == null) return null;
    final res = await client
        .get(Uri.parse('https://api.github.com/repos/$updateRepo/releases?per_page=30'), headers: {'Accept': 'application/vnd.github+json'})
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) throw HttpException('업데이트 서버 응답 ${res.statusCode}');
    return pickUpdate(jsonDecode(res.body) as List, current);
  }

  /// 설치 파일을 내려받아 경로를 돌려줍니다. [onProgress]는 0~1.
  Future<String> download(UpdateInfo info, void Function(double) onProgress) async {
    final dir = Directory('${(await getTemporaryDirectory()).path}/updates');
    if (dir.existsSync()) dir.deleteSync(recursive: true);
    dir.createSync(recursive: true);
    final file = File('${dir.path}/AI_GYM_LAB_${info.version}.apk');
    final res = await client.send(http.Request('GET', Uri.parse(info.apkUrl)));
    if (res.statusCode != 200) throw HttpException('내려받기 실패 (${res.statusCode})');
    final total = res.contentLength ?? info.size;
    final sink = file.openWrite();
    var got = 0;
    try {
      await for (final chunk in res.stream) {
        sink.add(chunk);
        got += chunk.length;
        if (total > 0) onProgress(got / total);
      }
    } finally {
      await sink.close();
    }
    if (info.size > 0 && file.lengthSync() != info.size) {
      throw const FileSystemException('내려받은 파일이 완전하지 않습니다. 다시 시도해 주세요.');
    }
    return file.path;
  }

  Future<bool> canInstall() async => await _ch.invokeMethod<bool>('canInstall') ?? true;

  Future<void> install(String path) => _ch.invokeMethod('installApk', {'path': path});
}
