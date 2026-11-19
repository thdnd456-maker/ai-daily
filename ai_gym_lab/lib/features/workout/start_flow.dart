import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../app/widgets.dart';
import '../../domain/engines/progression_engine.dart';
import '../../domain/engines/recovery_engine.dart';
import '../../domain/engines/stats_engine.dart';
import '../../domain/models.dart';
import 'session_screen.dart';

/// 운동 시작 공통 흐름: 진행 중 세션 확인 → 오늘의 상태(선택) → 세션 생성 → 기록 화면
Future<void> startWorkoutFlow(BuildContext context, WidgetRef ref, {int? dayIndex}) async {
  final repo = ref.read(repositoryProvider);
  final existing = await repo.inProgressSession();
  if (existing != null) {
    if (!context.mounted) return;
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => SessionScreen(sessionId: existing.id)));
    ref.refreshData();
    return;
  }
  final program = await repo.getActiveProgram();
  if (program == null || program.days.isEmpty || !context.mounted) return;
  final idx = dayIndex ?? await repo.nextDayIndex(program);
  if (!context.mounted) return;
  final res = await showModalBottomSheet<(RecoveryResult, int)?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: GymColors.surface,
    builder: (_) => ReadinessSheet(dayName: program.days[idx].row.name),
  );
  if (!context.mounted) return;
  if (res == null && !(await _skipConfirmed(context))) return;
  final sid = await repo.startSession(program: program, dayIndex: idx, recovery: res?.$1, recoveryLogId: res?.$2);
  ref.refreshData();
  if (!context.mounted) return;
  await Navigator.of(context).push(MaterialPageRoute(builder: (_) => SessionScreen(sessionId: sid)));
  ref.refreshData();
}

Future<bool> _skipConfirmed(BuildContext context) async => confirm(context, '상태 체크 없이 시작', '오늘의 상태를 입력하지 않으면 계획된 운동량 그대로 시작합니다.', ok: '바로 시작');

class ReadinessSheet extends ConsumerStatefulWidget {
  final String dayName;
  const ReadinessSheet({super.key, required this.dayName});
  @override
  ConsumerState<ReadinessSheet> createState() => _ReadinessSheetState();
}

class _ReadinessSheetState extends ConsumerState<ReadinessSheet> {
  double _sleep = 7;
  int _fatigue = 2, _soreness = 2, _motivation = 4;
  bool _pain = false;
  JointArea? _area;
  RecoveryResult? _result;
  RecoveryInput? _input;
  bool _busy = false;

  Widget _scale(String label, String low, String high, int v, ValueChanged<int> on) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            const Spacer(),
            Text('$low ← → $high', style: const TextStyle(color: GymColors.textDim, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 6),
        SegmentedButton<int>(
          showSelectedIcon: false,
          segments: [for (var i = 1; i <= 5; i++) ButtonSegment(value: i, label: Text('$i'))],
          selected: {v},
          onSelectionChanged: (s) => setState(() {
            on(s.first);
            _result = null;
          }),
        ),
      ],
    ),
  );

  Future<void> _analyze() async {
    setState(() => _busy = true);
    final repo = ref.read(repositoryProvider);
    final now = DateTime.now();
    final recent = await repo.completedSessions(since: now.subtract(const Duration(days: 7)));
    final stats = StatsEngine(repo.exercises);
    var drops = 0;
    final seen = <String>{};
    for (final s in recent) {
      for (final e in s.exercises) {
        if (!seen.add(e.exercise.id)) continue;
        if (stats.performanceDropped(await repo.performanceHistory(e.exercise.id, limit: 2))) drops++;
      }
    }
    final last = recent.firstOrNull;
    _input = RecoveryInput(
      sleepHours: _sleep,
      fatigue: _fatigue,
      soreness: _soreness,
      motivation: _motivation,
      jointPain: _pain,
      painArea: _pain ? _area : null,
      recentPerformanceDrops: drops,
      hoursSinceLastSession: last == null ? null : now.difference(last.row.finishedAt ?? last.row.startedAt).inMinutes / 60,
    );
    setState(() {
      _result = const RecoveryEngine().analyze(_input!);
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = _result;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      builder: (_, sc) => ListView(
        controller: sc,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Text('오늘의 상태 · ${widget.dayName}', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('수면 시간', style: TextStyle(fontWeight: FontWeight.w700)),
              const Spacer(),
              SizedBox(
                width: 180,
                child: NumberStepper(
                  label: '시간',
                  value: _sleep,
                  step: 0.5,
                  max: 14,
                  decimals: 1,
                  onChanged: (v) => setState(() {
                    _sleep = v;
                    _result = null;
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _scale('피로도', '낮음', '높음', _fatigue, (v) => _fatigue = v),
          _scale('근육통', '없음', '심함', _soreness, (v) => _soreness = v),
          _scale('운동 의욕', '낮음', '높음', _motivation, (v) => _motivation = v),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('관절 통증', style: TextStyle(fontWeight: FontWeight.w700)),
            value: _pain,
            onChanged: (v) => setState(() {
              _pain = v;
              _result = null;
            }),
          ),
          if (_pain)
            Wrap(
              spacing: 6,
              children: [for (final a in JointArea.values) ChoiceChip(label: Text(a.ko), selected: _area == a, onSelected: (_) => setState(() => _area = a))],
            ),
          const SizedBox(height: 16),
          if (r == null)
            FilledButton(onPressed: _busy ? null : _analyze, child: Text(_busy ? '분석 중…' : '상태 분석'))
          else ...[
            SectionCard(
              color:
                  (r.readiness == Readiness.good
                          ? GymColors.accent
                          : r.readiness == Readiness.caution
                          ? GymColors.warn
                          : GymColors.danger)
                      .withValues(alpha: 0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('운동 준비 상태: ${r.label}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                      const Spacer(),
                      Text('${r.score}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(r.recommendation, style: const TextStyle(height: 1.4)),
                  if (r.factors.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    for (final f in r.factors) Text('· $f', style: const TextStyle(color: GymColors.textDim)),
                  ],
                  if (r.setMultiplier < 1 || r.rirOffset > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      '적용: 세트 ×${r.setMultiplier.toStringAsFixed(2)}, 목표 RIR +${r.rirOffset}${r.readiness != Readiness.good ? ', 중량 증가 보류' : ''}',
                      style: const TextStyle(color: GymColors.warn, fontWeight: FontWeight.w700),
                    ),
                  ],
                  if (r.avoidArea != null) Text('${r.avoidArea!.ko} 부담이 큰 운동은 [대체] 버튼으로 바꾸는 것을 고려하세요.', style: const TextStyle(color: GymColors.warn)),
                  const SizedBox(height: 8),
                  const Text(RecoveryResult.disclaimer, style: TextStyle(color: GymColors.textDim, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () async {
                final id = await ref.read(repositoryProvider).saveRecovery(_input!, r);
                if (context.mounted) Navigator.pop(context, (r, id));
              },
              child: Text(r.readiness == Readiness.rest ? '그래도 가볍게 시작' : '이대로 시작'),
            ),
          ],
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('건너뛰기')),
        ],
      ),
    );
  }
}

String readinessKo(String? r) => switch (r) {
  'good' => '양호',
  'caution' => '주의',
  'low' => '회복 부족 가능성',
  'rest' => '회복 권장',
  _ => '-',
};

String recSummary(ProgressionRecommendation r, Exercise e) => r.summary(timed: e.timed, assisted: e.assisted);
