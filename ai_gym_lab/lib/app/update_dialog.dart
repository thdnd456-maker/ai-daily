import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'providers.dart';
import 'research_sync.dart';

import 'theme.dart';
import 'updater.dart';

bool _autoChecked = false;

/// 앱을 켤 때 한 번 조용히 확인합니다(새 버전이 있을 때만 창을 띄움).
Future<void> autoCheckForUpdate(BuildContext context) async {
  if (_autoChecked || !Updater.supported) return;
  _autoChecked = true;
  try {
    final info = await Updater().check();
    if (info != null && context.mounted) await _offer(context, info);
  } catch (e) {
    debugPrint('업데이트 확인 실패: $e'); // 자동 확인은 조용히 넘어감
  }
}

/// 설정 화면의 「업데이트 확인」 버튼
Future<void> manualCheckForUpdate(BuildContext context) async {
  if (!Updater.supported) {
    await _message(context, '업데이트', '이 기기에서는 앱 안 업데이트를 지원하지 않습니다.');
    return;
  }
  final updater = Updater();
  UpdateInfo? info;
  String? current;
  try {
    current = await updater.currentVersion();
    if (!context.mounted) return;
    info = await _withSpinner(context, '새 버전 확인 중…', updater.check());
  } catch (e) {
    if (context.mounted) await _message(context, '확인하지 못했어요', '인터넷 연결을 확인하고 다시 시도해 주세요.\n($e)');
    return;
  }
  if (!context.mounted) return;
  if (info == null) {
    await _message(context, '최신 버전이에요', '지금 쓰고 있는 버전($current)이 가장 최신입니다.');
  } else {
    await _offer(context, info);
  }
}

Future<void> _offer(BuildContext context, UpdateInfo info) async {
  final mb = info.size > 0 ? ' (${(info.size / 1024 / 1024).toStringAsFixed(0)}MB)' : '';
  final go = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('새 버전이 나왔어요 (${info.version})'),
      content: SingleChildScrollView(
        child: Text(
          '${info.notes.isEmpty ? '' : '${info.notes}\n\n'}'
          '「업데이트」를 누르면 내려받은 뒤 설치 화면이 열립니다$mb.\n운동 기록은 그대로 남아요.',
          style: const TextStyle(height: 1.4),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('나중에')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('업데이트')),
      ],
    ),
  );
  if (go != true || !context.mounted) return;

  final updater = Updater();
  final progress = ValueNotifier<double>(0);
  String path;
  try {
    path = await _withProgress(context, progress, updater.download(info, (p) => progress.value = p));
  } catch (e) {
    if (context.mounted) await _message(context, '내려받지 못했어요', '인터넷 연결을 확인하고 다시 시도해 주세요.\n($e)');
    return;
  }
  if (!context.mounted) return;
  if (!await updater.canInstall()) {
    if (!context.mounted) return;
    await _message(context, '처음 한 번만 허용해 주세요', '다음 화면에서 「이 출처 허용」(또는 「알 수 없는 앱 설치」)을 켠 뒤 뒤로 돌아오면 설치 화면이 나옵니다.');
  }
  try {
    await updater.install(path);
  } catch (e) {
    if (context.mounted) await _message(context, '설치 화면을 열지 못했어요', '$e');
  }
}

Future<T> _withSpinner<T>(BuildContext context, String text, Future<T> job) async {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      content: Row(
        children: [
          const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5)),
          const SizedBox(width: 16),
          Expanded(child: Text(text)),
        ],
      ),
    ),
  );
  try {
    return await job;
  } finally {
    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
  }
}

Future<T> _withProgress<T>(BuildContext context, ValueNotifier<double> progress, Future<T> job) async {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      title: const Text('내려받는 중…'),
      content: ValueListenableBuilder<double>(
        valueListenable: progress,
        builder: (_, v, _) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(value: v <= 0 ? null : v, color: GymColors.accent),
            const SizedBox(height: 10),
            Text('${(v * 100).clamp(0, 100).toStringAsFixed(0)}%'),
          ],
        ),
      ),
    ),
  );
  try {
    return await job;
  } finally {
    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
  }
}

Future<void> _message(BuildContext context, String title, String body) => showDialog<void>(
  context: context,
  builder: (ctx) => AlertDialog(
    title: Text(title),
    content: Text(body, style: const TextStyle(height: 1.4)),
    actions: [FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('확인'))],
  ),
);

/// 앱 맨 위에 두어, 어떤 화면(시작 화면 포함)에서든 앱을 켤 때 한 번 새 버전을 확인합니다.
class UpdateCheckHost extends ConsumerStatefulWidget {
  final Widget child;
  const UpdateCheckHost({super.key, required this.child});
  @override
  ConsumerState<UpdateCheckHost> createState() => _UpdateCheckHostState();
}

class _UpdateCheckHostState extends ConsumerState<UpdateCheckHost> {
  @override
  void initState() {
    super.initState();
    // 인터넷이 없거나 실패하면 조용히 넘어감
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) autoCheckForUpdate(context);
      _syncResearch();
    });
  }

  /// 새 논문 자료 받아 오기 (하루 한 번)
  Future<void> _syncResearch() async {
    if (!(Platform.isAndroid || Platform.isIOS)) return; // 테스트·데스크톱에서는 건너뜀
    try {
      if (await ResearchSync(ref.read(repositoryProvider)).run() && mounted) ref.refreshData();
    } catch (e) {
      debugPrint('논문 자료 확인 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
