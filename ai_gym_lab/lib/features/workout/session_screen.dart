import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../app/rest_timer.dart';
import '../../app/theme.dart';
import '../../app/widgets.dart';
import '../../data/db/database.dart';
import '../../data/repository.dart';
import '../../domain/engines/progression_engine.dart';
import '../../domain/models.dart';
import '../../app/exercise_visuals.dart';
import '../exercise/exercise_library_screen.dart';
import '../exercise/substitution_sheet.dart';

final sessionProvider = FutureProvider.family<SessionView?, int>((ref, id) {
  ref.watch(dataVersionProvider);
  return ref.read(repositoryProvider).getSession(id);
});

/// 지난 운동 기록 (이번 세션 제외)
final lastPerformanceProvider = FutureProvider.family<ExercisePerformance?, (String, int)>((ref, key) async {
  ref.watch(dataVersionProvider);
  final h = await ref.read(repositoryProvider).performanceHistory(key.$1, limit: 2, excludeSessionId: key.$2);
  return h.firstOrNull;
});

final incrementProvider = FutureProvider.family<double, String>((ref, exerciseId) async {
  ref.watch(dataVersionProvider);
  final repo = ref.read(repositoryProvider);
  return repo.incrementFor(repo.exercises[exerciseId]!);
});

/// 실시간 운동 기록 화면. 모든 입력은 즉시 DB에 저장되어 앱이 종료돼도 유지됩니다.
class SessionScreen extends ConsumerStatefulWidget {
  final int sessionId;
  const SessionScreen({super.key, required this.sessionId});
  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  Timer? _clock;

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(seconds: 15), (_) => mounted ? setState(() {}) : null);
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  GymRepository get repo => ref.read(repositoryProvider);

  Future<void> _act(Future<void> Function() f) async {
    await f();
    ref.refreshData();
  }

  Future<void> _finish(SessionView s) async {
    final incomplete = s.exercises.fold(0, (a, e) => a + e.sets.where((x) => !x.completed).length);
    final ok = await confirm(context, '운동 완료', incomplete > 0 ? '완료하지 않은 세트 $incomplete개는 기록에서 제외됩니다. 운동을 마칠까요?' : '오늘 운동을 마칠까요?', ok: '완료');
    if (!ok) return;
    await repo.finishSession(s.row.id);
    await ref.read(restTimerProvider.notifier).stop();
    ref.refreshData();
    final done = (await repo.getSession(s.row.id))!;
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('수고했어요! 💪'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${done.row.dayName} · ${done.durationMin}분'),
            const SizedBox(height: 8),
            Text('완료 세트: ${done.totalCompletedSets}세트'),
            Text('총 볼륨: ${fmtKg(done.volume)}kg'),
            const SizedBox(height: 8),
            const Text('오늘 기록을 바탕으로 다음 운동의 중량·반복이 자동 조정됩니다.', style: TextStyle(color: GymColors.textDim, fontSize: 13)),
            const Text('총 볼륨(중량×반복)은 근육 성장량을 직접 의미하지 않습니다.', style: TextStyle(color: GymColors.textDim, fontSize: 11)),
          ],
        ),
        actions: [FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('확인'))],
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  Future<void> _abandon(SessionView s) async {
    if (await confirm(context, '운동 취소', '이 세션의 기록을 모두 삭제할까요? 되돌릴 수 없습니다.', ok: '삭제', danger: true)) {
      await repo.abandonSession(s.row.id);
      await ref.read(restTimerProvider.notifier).stop();
      ref.refreshData();
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(sessionProvider(widget.sessionId));
    return async.when(
      skipLoadingOnReload: true,
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('오류: $e')),
      ),
      data: (s) {
        if (s == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyState(icon: Icons.info_outline, title: '세션을 찾을 수 없습니다'),
          );
        }
        final elapsed = DateTime.now().difference(s.row.startedAt).inMinutes;
        final total = s.exercises.fold(0, (a, e) => a + e.sets.length);
        final done = s.totalCompletedSets;
        final readOnly = s.row.status != 'in_progress';
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.row.dayName, style: const TextStyle(fontWeight: FontWeight.w900)),
                Text('$elapsed분 경과 · $done/$total세트', style: const TextStyle(fontSize: 12, color: GymColors.textDim)),
              ],
            ),
            actions: [
              if (!readOnly)
                TextButton(
                  onPressed: () => _finish(s),
                  child: const Text('완료', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                ),
              PopupMenuButton<String>(
                onSelected: (v) => v == 'abandon' ? _abandon(s) : null,
                itemBuilder: (_) => const [PopupMenuItem(value: 'abandon', child: Text('운동 취소(기록 삭제)'))],
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(3),
              child: LinearProgressIndicator(value: total == 0 ? 0 : done / total, minHeight: 3, color: GymColors.accent, backgroundColor: GymColors.line),
            ),
          ),
          body: Column(
            children: [
              const _RestBanner(),
              if (s.row.readiness != null && s.row.readiness != 'good')
                Container(
                  width: double.infinity,
                  color: GymColors.warn.withValues(alpha: 0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    '오늘 준비 상태(자체 추정 ${s.row.readinessScore}점)를 반영해 세트·RIR을 조정했고 중량 증가는 보류했습니다.',
                    style: const TextStyle(color: GymColors.warn, fontSize: 12),
                  ),
                ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 120),
                  children: [
                    for (final e in s.exercises)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ExerciseCard(session: s, item: e, act: _act, readOnly: readOnly),
                      ),
                    if (!readOnly) FilledButton(onPressed: () => _finish(s), child: const Text('운동 완료')),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RestBanner extends ConsumerWidget {
  const _RestBanner();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(restTimerProvider);
    final ctl = ref.read(restTimerProvider.notifier);
    if (!t.running) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: Row(
          children: [
            const Icon(Icons.timer_outlined, size: 18, color: GymColors.textDim),
            const SizedBox(width: 6),
            const Text('휴식', style: TextStyle(color: GymColors.textDim)),
            const SizedBox(width: 6),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final sec in [30, 60, 90, 120, 180])
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ActionChip(label: Text(sec < 60 ? '$sec초' : '${sec ~/ 60}분${sec % 60 > 0 ? '30초' : ''}'), onPressed: () => ctl.start(sec)),
                      ),
                    ActionChip(
                      label: const Text('직접 설정'),
                      onPressed: () async {
                        final c = TextEditingController();
                        final v = await showDialog<int>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('휴식 시간(초)'),
                            content: TextField(controller: c, autofocus: true, keyboardType: TextInputType.number),
                            actions: [FilledButton(onPressed: () => Navigator.pop(ctx, int.tryParse(c.text)), child: const Text('시작'))],
                          ),
                        );
                        if (v != null && v > 0) ctl.start(v.clamp(5, 1800));
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
    final m = t.remaining ~/ 60, sec = t.remaining % 60;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      decoration: BoxDecoration(color: GymColors.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(value: 1 - t.progress, strokeWidth: 5, color: GymColors.accent, backgroundColor: GymColors.line),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '$m:${sec.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, fontFeatures: [FontFeature.tabularFigures()]),
              ),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(minimumSize: const Size(44, 44), padding: const EdgeInsets.symmetric(horizontal: 6)),
            onPressed: () => ctl.add(-15),
            child: const Text(
              '-15',
              style: TextStyle(fontWeight: FontWeight.w800, color: GymColors.text),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(minimumSize: const Size(44, 44), padding: const EdgeInsets.symmetric(horizontal: 6)),
            onPressed: () => ctl.add(30),
            child: const Text(
              '+30',
              style: TextStyle(fontWeight: FontWeight.w800, color: GymColors.text),
            ),
          ),
          IconButton(onPressed: ctl.stop, icon: const Icon(Icons.skip_next_rounded, size: 30), tooltip: '휴식 종료'),
        ],
      ),
    );
  }
}

class _ExerciseCard extends ConsumerWidget {
  final SessionView session;
  final SessionExerciseView item;
  final Future<void> Function(Future<void> Function()) act;
  final bool readOnly;
  const _ExerciseCard({required this.session, required this.item, required this.act, required this.readOnly});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(repositoryProvider);
    final e = item.exercise;
    final row = item.row;
    final unit = e.timed ? '초' : '회';
    final last = ref.watch(lastPerformanceProvider((e.id, session.row.id))).value;
    final inc = ref.watch(incrementProvider(e.id)).value ?? e.primaryEquipment.defaultIncrementKg;
    final rec = item.recommendation;
    final allDone = item.sets.isNotEmpty && item.sets.every((s) => s.completed);
    final rest = row.restSec >= 60 ? '${row.restSec ~/ 60}분${row.restSec % 60 > 0 ? ' ${row.restSec % 60}초' : ''}' : '${row.restSec}초';
    final menu = readOnly
        ? null
        : PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: GymColors.textDim),
            onSelected: (v) async {
              switch (v) {
                case 'sub':
                  final id = await showSubstitutionSheet(context, ref, e);
                  if (id != null) await act(() => repo.substitute(row.id, id));
                case 'pain':
                  await act(() => repo.setFlags(row.id, pain: !row.pain));
                case 'form':
                  await act(() => repo.setFlags(row.id, formUnstable: !row.formUnstable));
                case 'detail':
                  if (context.mounted) Navigator.of(context).push(MaterialPageRoute(builder: (_) => ExerciseDetailScreen(exercise: e)));
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'sub',
                child: ListTile(leading: Icon(Icons.swap_horiz), title: Text('다른 운동으로 바꾸기')),
              ),
              PopupMenuItem(
                value: 'pain',
                child: ListTile(leading: const Icon(Icons.healing), title: Text(row.pain ? '통증 표시 해제' : '통증 있었음')),
              ),
              PopupMenuItem(
                value: 'form',
                child: ListTile(leading: const Icon(Icons.accessibility_new), title: Text(row.formUnstable ? '자세 불안정 해제' : '자세가 불안정했음')),
              ),
              const PopupMenuItem(
                value: 'detail',
                child: ListTile(leading: Icon(Icons.menu_book_outlined), title: Text('자세 설명 보기')),
              ),
            ],
          );
    return Card(
      color: allDone ? const Color(0xFF1C2318) : null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => showExercisePhotoViewer(context, e),
                  child: Stack(
                    children: [
                      ExercisePhoto(exercise: e, width: 92, height: 92, radius: 16, animate: !allDone),
                      if (allDone)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(16)),
                            child: const Icon(Icons.check_circle, color: GymColors.accent, size: 36),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.nameKo, maxLines: 2, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, height: 1.2)),
                      const SizedBox(height: 3),
                      Text('${row.targetSets}세트 · ${row.repMin}~${row.repMax}$unit · 휴식 $rest', style: const TextStyle(color: GymColors.textDim, fontSize: 13)),
                      if (row.substitutedFrom != null)
                        Text(
                          '${repo.exercises[row.substitutedFrom]?.nameKo ?? row.substitutedFrom} 대신',
                          style: const TextStyle(color: GymColors.info, fontSize: 12),
                        ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (rec != null)
                            InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => _showWhy(context, rec, e),
                              child: _Chip(
                                icon: rec.action == ProgressionAction.increaseWeight ? Icons.arrow_upward_rounded : Icons.flag_outlined,
                                text: rec.weight == null ? '오늘: 기준 찾기' : '오늘 ${fmtKg(rec.weight!)}kg',
                                color: rec.weight == null ? GymColors.info : GymColors.accent,
                                trailingHelp: true,
                              ),
                            ),
                          _Chip(
                            icon: Icons.history,
                            text: last == null ? '첫 기록' : '지난 ${fmtKg(last.workingWeight)}kg × ${last.completedSets.map((x) => x.reps).join('·')}',
                            color: GymColors.textDim,
                          ),
                          if (row.pain) const _Chip(icon: Icons.healing, text: '통증', color: GymColors.danger),
                          if (row.formUnstable) const _Chip(icon: Icons.accessibility_new, text: '자세', color: GymColors.warn),
                        ],
                      ),
                    ],
                  ),
                ),
                ?menu,
              ],
            ),
            const SizedBox(height: 12),
            for (final set in item.sets) _SetRow(set: set, exercise: e, increment: inc, restSec: row.restSec, act: act, readOnly: readOnly),
            if (!readOnly)
              Row(
                children: [
                  TextButton.icon(onPressed: () => act(() => repo.addSet(row.id)), icon: const Icon(Icons.add, size: 18), label: const Text('세트')),
                  if (item.sets.length > 1)
                    TextButton.icon(
                      onPressed: () => act(() => repo.removeLastSet(row.id)),
                      icon: const Icon(Icons.remove, size: 18),
                      label: const Text('세트'),
                      style: TextButton.styleFrom(foregroundColor: GymColors.textDim),
                    ),
                  const Spacer(),
                  Text('목표 RIR ${row.targetRir}', style: const TextStyle(color: GymColors.textDim, fontSize: 12)),
                  const SizedBox(width: 8),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showWhy(BuildContext context, ProgressionRecommendation rec, Exercise e) {
    showModalBottomSheet(
      context: context,
      backgroundColor: GymColors.surface,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${e.nameKo} · ${rec.action.ko}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(
              '추천: ${rec.summary(timed: e.timed, assisted: e.assisted)} · 신뢰도 ${rec.confidence.ko}',
              style: const TextStyle(color: GymColors.accent),
            ),
            const SizedBox(height: 12),
            for (final r in rec.reasons)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(r, style: const TextStyle(height: 1.35))),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            const EvidenceBadge(EvidenceKind.userData),
            const SizedBox(height: 4),
            const Text('규칙 기반 엔진(더블 프로그레션 + RIR + 안전장치)이 내 기록으로 계산했습니다. 공백·감량 비율 등 일부 수치는 앱 기본값입니다.', style: TextStyle(color: GymColors.textDim, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _SetRow extends ConsumerWidget {
  final WorkoutSet set;
  final Exercise exercise;
  final double increment;
  final int restSec;
  final Future<void> Function(Future<void> Function()) act;
  final bool readOnly;
  const _SetRow({required this.set, required this.exercise, required this.increment, required this.restSec, required this.act, required this.readOnly});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(repositoryProvider);
    final done = set.completed;
    final enabled = !readOnly && !done;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            child: Text(
              '${set.setNumber}',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: done ? GymColors.accent : GymColors.textDim),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            flex: 5,
            child: NumberStepper(
              label: exercise.assisted ? '보조 kg' : 'kg',
              value: set.actualWeight,
              step: increment,
              decimals: 2,
              placeholder: exercise.bodyweight ? '맨몸' : '입력',
              enabled: enabled,
              onChanged: (v) => act(() => repo.updateSet(set.id, weight: v)),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 4,
            child: NumberStepper(
              label: exercise.timed ? '초' : '회',
              value: set.actualReps?.toDouble(),
              step: exercise.timed ? 5 : 1,
              enabled: enabled,
              onChanged: (v) => act(() => repo.updateSet(set.id, reps: v.round())),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 3,
            child: NumberStepper(
              label: 'RIR',
              value: set.rir?.toDouble(),
              max: 5,
              enabled: enabled,
              onChanged: (v) => act(() => repo.updateSet(set.id, rir: v.round())),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 52,
            height: 52,
            child: IconButton.filled(
              style: IconButton.styleFrom(
                backgroundColor: done ? GymColors.accent : GymColors.surface2,
                foregroundColor: done ? Colors.black : GymColors.text,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: readOnly
                  ? null
                  : () async {
                      if (!done && (set.actualReps ?? 0) <= 0) {
                        showSnack(context, '반복 횟수를 입력하세요.');
                        return;
                      }
                      if (!done && set.actualWeight == null && !exercise.bodyweight) {
                        showSnack(context, '중량을 입력하세요. 첫 기록이라면 가벼운 중량으로 시작하세요.');
                        return;
                      }
                      HapticFeedback.mediumImpact();
                      await act(() async {
                        if (!done && set.actualWeight == null) await repo.updateSet(set.id, weight: 0);
                        await repo.setCompleted(set.id, !done);
                      });
                      if (!done) await ref.read(restTimerProvider.notifier).start(restSec);
                    },
              icon: Icon(done ? Icons.check_rounded : Icons.check_rounded, size: 28),
              tooltip: done ? '완료 취소' : '세트 완료',
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final bool trailingHelp;
  const _Chip({required this.icon, required this.text, required this.color, this.trailingHelp = false});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color, fontSize: 12.5, fontWeight: FontWeight.w700),
          ),
        ),
        if (trailingHelp) ...[const SizedBox(width: 3), Icon(Icons.help_outline, size: 13, color: color)],
      ],
    ),
  );
}
