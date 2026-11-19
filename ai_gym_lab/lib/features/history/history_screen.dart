import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/exercise_visuals.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../app/widgets.dart';
import '../../data/repository.dart';
import '../../domain/engines/progression_engine.dart';
import '../workout/start_flow.dart';

/// 기록 탭: 운동 기록 / 신체 변화 기록
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => DefaultTabController(
    length: 2,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('기록'),
        bottom: const TabBar(
          indicatorColor: GymColors.accent,
          labelColor: GymColors.accent,
          tabs: [
            Tab(text: '운동 기록'),
            Tab(text: '신체 변화'),
          ],
        ),
      ),
      body: const TabBarView(children: [_SessionList(), BodyMeasurementsView()]),
    ),
  );
}

class _SessionList extends ConsumerWidget {
  const _SessionList();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(completedSessionsProvider);
    return s.when(
      skipLoadingOnReload: true,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (list) {
        if (list.isEmpty) return const EmptyState(icon: Icons.event_note, title: '아직 완료한 운동이 없습니다', message: '홈에서 오늘의 운동을 시작하세요.');
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: list.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final v = list[i];
            return SectionCard(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SessionDetailScreen(sessionId: v.row.id))),
              child: Row(
                children: [
                  Column(
                    children: [
                      Text(DateFormat('M/d').format(v.row.startedAt), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
                      Text(DateFormat('E', 'ko_KR').format(v.row.startedAt), style: const TextStyle(color: GymColors.textDim)),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(v.row.dayName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        Text('${v.durationMin}분 · ${v.totalCompletedSets}세트 · 볼륨 ${fmtKg(v.volume)}kg', style: const TextStyle(color: GymColors.textDim)),
                        if (v.row.readiness != null)
                          Text('준비 상태: ${readinessKo(v.row.readiness)}', style: const TextStyle(color: GymColors.textDim, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: GymColors.textDim),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class SessionDetailScreen extends ConsumerWidget {
  final int sessionId;
  const SessionDetailScreen({super.key, required this.sessionId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(repositoryProvider);
    return FutureBuilder<SessionView?>(
      future: repo.getSession(sessionId),
      builder: (_, snap) {
        final s = snap.data;
        return Scaffold(
          appBar: AppBar(
            title: Text(s?.row.dayName ?? '운동 기록'),
            actions: [
              if (s != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    if (await confirm(context, '기록 삭제', '이 운동 기록을 삭제할까요? 다음 운동 추천에도 반영됩니다.', ok: '삭제', danger: true)) {
                      await repo.deleteSession(sessionId);
                      ref.refreshData();
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                ),
            ],
          ),
          body: s == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    Text(
                      '${DateFormat('yyyy.M.d (E) HH:mm', 'ko_KR').format(s.row.startedAt)} · ${s.durationMin}분',
                      style: const TextStyle(color: GymColors.textDim),
                    ),
                    const SizedBox(height: 8),
                    for (final e in s.exercises)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ExercisePhoto(exercise: e.exercise, width: 44, height: 44, radius: 10),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(e.exercise.nameKo, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                                  ),
                                  if (e.row.pain) const Pill('통증', color: GymColors.danger),
                                  if (e.row.formUnstable) const Pill('자세 불안정', color: GymColors.warn),
                                ],
                              ),
                              const SizedBox(height: 6),
                              for (final x in e.sets)
                                Text(
                                  '${x.setNumber}세트  ${x.completed ? '${fmtKg(x.actualWeight ?? 0)}kg × ${x.actualReps}${e.exercise.timed ? '초' : '회'}${x.rir != null ? '  RIR ${x.rir}' : ''}' : '미완료'}',
                                  style: TextStyle(color: x.completed ? GymColors.text : GymColors.textDim),
                                ),
                              if (e.recommendation != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  '당일 추천: ${recSummary(e.recommendation!, e.exercise)} (${e.recommendation!.action.ko})',
                                  style: const TextStyle(color: GymColors.textDim, fontSize: 12),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
        );
      },
    );
  }
}

class BodyMeasurementsView extends ConsumerWidget {
  const BodyMeasurementsView({super.key});

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final w = TextEditingController(), f = TextEditingController(), m = TextEditingController(), wa = TextEditingController(), n = TextEditingController();
    var date = DateTime.now();
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: GymColors.surface,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('신체 변화 기록', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              Row(
                children: [
                  IconButton(onPressed: () => setS(() => date = date.subtract(const Duration(days: 1))), icon: const Icon(Icons.chevron_left)),
                  Expanded(
                    child: Text(
                      DateFormat('yyyy.M.d (E)', 'ko_KR').format(date),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  IconButton(
                    onPressed: date.isBefore(DateTime.now().subtract(const Duration(hours: 12)))
                        ? () => setS(() => date = date.add(const Duration(days: 1)))
                        : null,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
              for (final (c, l, u) in [(w, '체중', 'kg'), (f, '체지방률 (선택)', '%'), (m, '골격근량 (선택)', 'kg'), (wa, '허리둘레 (선택)', 'cm')])
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: c,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: l, suffixText: u),
                  ),
                ),
              TextField(
                controller: n,
                decoration: const InputDecoration(labelText: '메모 (선택)'),
              ),
              const SizedBox(height: 12),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('저장')),
            ],
          ),
        ),
      ),
    );
    if (ok != true) return;
    final weight = double.tryParse(w.text);
    if (weight == null && f.text.isEmpty && m.text.isEmpty && wa.text.isEmpty) return;
    await ref
        .read(repositoryProvider)
        .addMeasurement(
          date: date,
          weight: weight,
          bodyFat: double.tryParse(f.text),
          smm: double.tryParse(m.text),
          waist: double.tryParse(wa.text),
          notes: n.text,
        );
    ref.refreshData();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ms = ref.watch(measurementsProvider);
    final profile = ref.watch(profileProvider).value;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: GymColors.accent,
        foregroundColor: Colors.black,
        onPressed: () => _add(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('기록 추가'),
      ),
      body: ms.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) {
          if (list.isEmpty) return const EmptyState(icon: Icons.monitor_weight_outlined, title: '신체 기록이 없습니다', message: '체중·체지방률을 기록하면 통계에서 변화를 볼 수 있어요.');
          final rev = list.reversed.toList();
          final first = list.firstWhere((x) => x.weightKg != null, orElse: () => list.first);
          final last = rev.firstWhere((x) => x.weightKg != null, orElse: () => rev.first);
          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
            children: [
              if (first.weightKg != null && last.weightKg != null)
                SectionCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: StatTile(label: '현재 체중', value: '${fmtKg(last.weightKg!)}kg'),
                      ),
                      Expanded(
                        child: StatTile(
                          label: '첫 기록 대비',
                          value: '${last.weightKg! - first.weightKg! >= 0 ? '+' : ''}${(last.weightKg! - first.weightKg!).toStringAsFixed(1)}kg',
                        ),
                      ),
                      if (profile?.targetWeightKg != null)
                        Expanded(
                          child: StatTile(label: '목표까지', value: '${(profile!.targetWeightKg! - last.weightKg!).toStringAsFixed(1)}kg'),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              for (final x in rev)
                Dismissible(
                  key: ValueKey(x.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: GymColors.danger),
                  ),
                  confirmDismiss: (_) => confirm(context, '삭제', '이 기록을 삭제할까요?', ok: '삭제', danger: true),
                  onDismissed: (_) async {
                    await ref.read(repositoryProvider).deleteMeasurement(x.id);
                    ref.refreshData();
                  },
                  child: ListTile(
                    title: Text(DateFormat('yyyy.M.d (E)', 'ko_KR').format(x.date)),
                    subtitle: Text(
                      [
                        if (x.bodyFatPct != null) '체지방 ${x.bodyFatPct}%',
                        if (x.skeletalMuscleKg != null) '골격근 ${x.skeletalMuscleKg}kg',
                        if (x.waistCm != null) '허리 ${x.waistCm}cm',
                        if (x.notes.isNotEmpty) x.notes,
                      ].join(' · '),
                    ),
                    trailing: Text(x.weightKg == null ? '-' : '${fmtKg(x.weightKg!)}kg', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
