import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';

/// 「데이터 내보내기」로 클립보드에 복사된 기록을 불러옵니다.
/// 앱을 지우고 다시 설치했거나 다른 폰으로 옮길 때 사용합니다.
Future<void> showImportDialog(BuildContext context, WidgetRef ref) async {
  final done = await showDialog<String>(
    context: context,
    builder: (_) => const _ImportDialog(),
  );
  if (done == null || !context.mounted) return;
  ref.refreshData();
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('불러오기 완료'),
      content: Text(done),
      actions: [FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('확인'))],
    ),
  );
}

class _ImportDialog extends ConsumerStatefulWidget {
  const _ImportDialog();
  @override
  ConsumerState<_ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends ConsumerState<_ImportDialog> {
  Map<String, dynamic>? _data;
  String? _error;
  bool _busy = false;

  Future<void> _paste() async {
    setState(() {
      _error = null;
      _data = null;
    });
    final clip = await Clipboard.getData(Clipboard.kTextPlain);
    final text = clip?.text?.trim() ?? '';
    if (text.isEmpty) {
      setState(() => _error = '클립보드가 비어 있습니다. 내보내기한 내용을 먼저 복사하세요.');
      return;
    }
    try {
      final d = jsonDecode(text);
      if (d is! Map || d['app'] != 'AI GYM LAB') throw const FormatException();
      setState(() => _data = Map<String, dynamic>.from(d));
    } catch (_) {
      setState(() => _error = '복사된 내용이 AI GYM LAB 기록이 아니거나 일부만 복사되었습니다. 전체를 다시 복사해 주세요.');
    }
  }

  Future<void> _import() async {
    setState(() => _busy = true);
    try {
      final r = await ref.read(repositoryProvider).importAll(_data!);
      if (!mounted) return;
      Navigator.pop(
        context,
        '운동 ${r.sessions}회, 세트 ${r.sets}개를 불러왔습니다.'
        '${r.skipped > 0 ? '\n(운동 목록에 없는 기록 ${r.skipped}개는 건너뛰었습니다.)' : ''}',
      );
    } catch (e) {
      setState(() {
        _busy = false;
        _error = '불러오지 못했습니다. 기존 데이터는 그대로입니다.\n($e)';
      });
    }
  }

  int _count(String key) => (_data?[key] as List?)?.length ?? 0;

  @override
  Widget build(BuildContext context) {
    final d = _data;
    final exported = DateTime.tryParse('${d?['exportedAt'] ?? ''}');
    return AlertDialog(
      title: const Text('기록 불러오기'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '이전 앱의 설정 → 「데이터 내보내기」를 누르면 기록이 복사됩니다.\n'
              '그 상태에서 아래 버튼을 누르세요.',
              style: TextStyle(height: 1.4),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _busy ? null : _paste,
                icon: const Icon(Icons.content_paste),
                label: const Text('복사한 기록 붙여넣기'),
              ),
            ),
            if (d != null) ...[
              const SizedBox(height: 12),
              Text(
                '확인된 기록\n'
                '· 운동 ${_count('workout_sessions')}회 (세트 ${_count('workout_sets')}개)\n'
                '· 신체 기록 ${_count('body_measurements')}개\n'
                '${exported == null ? '' : '· 내보낸 날짜: ${exported.year}.${exported.month}.${exported.day}\n'}'
                '\n지금 이 앱에 있는 기록은 이 내용으로 바뀝니다.',
                style: const TextStyle(height: 1.4),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: GymColors.danger, height: 1.4)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.pop(context), child: const Text('취소')),
        FilledButton(
          onPressed: d == null || _busy ? null : _import,
          child: _busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('불러오기'),
        ),
      ],
    );
  }
}
