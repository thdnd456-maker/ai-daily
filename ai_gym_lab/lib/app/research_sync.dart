// 논문 자료 자동 받아 오기
//
// 앱 업데이트 없이 논문을 더하거나 고칠 수 있도록, GitHub에 올린 JSON 파일을 하루 한 번 받아 옵니다.
// - 파일: ai_gym_lab/remote/research.json (공개 저장소, 무료)
// - 바뀌는 것은 논문 자료(글)뿐입니다. 계산 방식은 앱 업데이트로만 바뀝니다.
// - 인터넷이 없거나 파일이 이상하면 조용히 넘어가고, 마지막으로 받은 자료를 그대로 씁니다.

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../data/repository.dart';
import '../domain/catalog/research.dart';

const researchFeedUrl = 'https://raw.githubusercontent.com/thdnd456-maker/ai-daily/claude/ai-gym-lab-health-app-7razs0/ai_gym_lab/remote/research.json';

const _kJson = 'research.remote';
const _kVersion = 'research.remoteVersion';
const _kChecked = 'research.remoteCheckedAt';

class RemoteResearch {
  final int version;
  final String updated;
  final List<(String, ResearchReference)> items; // (분류: training | nutrition, 논문)
  const RemoteResearch(this.version, this.updated, this.items);

  List<ResearchReference> category(String c) => [
    for (final (k, r) in items)
      if (k == c) r,
  ];
}

/// JSON을 읽어 검증합니다. 형식이 틀리면 FormatException.
RemoteResearch parseRemoteResearch(String body) {
  final j = jsonDecode(body);
  if (j is! Map || j['app'] != 'AI GYM LAB' || j['version'] is! int || j['references'] is! List) {
    throw const FormatException('논문 파일 형식이 아닙니다');
  }
  final out = <(String, ResearchReference)>[];
  for (final r in (j['references'] as List).take(300)) {
    if (r is! Map) continue;
    String s(String k) => (r[k] is String) ? (r[k] as String).trim() : '';
    final id = s('id'), title = s('title'), cat = s('category');
    final year = r['year'];
    if (id.isEmpty || title.isEmpty || year is! int || !(cat == 'training' || cat == 'nutrition')) continue;
    out.add((
      cat,
      ResearchReference(
        id: id,
        title: title,
        authors: s('authors'),
        year: year,
        journal: s('journal'),
        studyType: s('studyType'),
        population: s('population'),
        keyFindings: s('keyFindings'),
        limitations: s('limitations'),
        appliedIn: s('appliedIn'),
      ),
    ));
  }
  return RemoteResearch(j['version'] as int, (j['updated'] as String?) ?? '', out);
}

class ResearchSync {
  final GymRepository repo;
  final http.Client client;
  ResearchSync(this.repo, {http.Client? client}) : client = client ?? http.Client();

  /// 저장해 둔 자료 (없으면 null)
  static Future<RemoteResearch?> cached(GymRepository repo) async {
    final s = await repo.getSetting(_kJson);
    if (s == null) return null;
    try {
      return parseRemoteResearch(s);
    } catch (_) {
      return null;
    }
  }

  /// 하루 한 번 받아 옵니다. 새 버전을 반영했으면 true.
  Future<bool> run({bool force = false, DateTime? now}) async {
    final t = now ?? DateTime.now();
    final last = DateTime.tryParse(await repo.getSetting(_kChecked) ?? '');
    if (!force && last != null && t.difference(last).inHours < 20) return false;
    await repo.setSetting(_kChecked, t.toIso8601String());

    final res = await client.get(Uri.parse(researchFeedUrl)).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) return false;
    final body = utf8.decode(res.bodyBytes);
    final remote = parseRemoteResearch(body);
    final have = int.tryParse(await repo.getSetting(_kVersion) ?? '') ?? 0;
    if (remote.version <= have) return false;

    await repo.upsertResearch([for (final (_, r) in remote.items) r]);
    await repo.setSetting(_kJson, body);
    await repo.setSetting(_kVersion, '${remote.version}');
    return true;
  }
}
