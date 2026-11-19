import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../app/widgets.dart';
import '../../domain/engines/progression_engine.dart';
import '../program/program_review_screen.dart' show weekdayKo;
import '../settings/settings_screen.dart';
import '../workout/start_flow.dart';

/// 다음 운동의 운동별 오늘 추천 (미리보기)
final nextPreviewProvider = FutureProvider<List<(String, String, String)>>((ref) async {
  final summary = await ref.watch(homeSummaryProvider.future);
  final day = summary.nextDay;
  if (day == null) return [];
  final repo = ref.read(repositoryProvider);
  final out = <(String, String, String)>[];
  for (final x in day.exercises) {
    final e = repo.exercises[x.exerciseId]!;
    final r = await repo.recommendFor(
      e,
      sets: x.sets,
      repMin: x.repMin,
      repMax: x.repMax,
      targetRir: x.targetRir,
      startWeight: x.startWeight,
      incrementOverride: x.incrementKg,
    );
    out.add((e.nameKo, r.summary(timed: e.timed, assisted: e.assisted), r.action.ko));
  }
  return out;
});

class HomeScreen extends ConsumerWidget {
  final ValueChanged<int> onNavigate;
  const HomeScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(homeSummaryProvider);
    final preview = ref.watch(nextPreviewProvider);
    final now = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('M월 d일 EEEE', 'ko_KR').format(now), style: const TextStyle(fontSize: 13, color: GymColors.textDim)),
            const Text('AI GYM LAB', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: summary.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (s) {
          final day = s.nextDay;
          return RefreshIndicator(
            onRefresh: () async => ref.refreshData(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                if (s.inProgress != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SectionCard(
                      color: GymColors.accent.withValues(alpha: 0.12),
                      onTap: () => startWorkoutFlow(context, ref),
                      child: Row(
                        children: [
                          const Icon(Icons.play_circle_fill, color: GymColors.accent, size: 34),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('진행 중인 운동', style: TextStyle(color: GymColors.textDim, fontSize: 12)),
                                Text('${s.inProgress!.dayName} 이어하기', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                if (day != null)
                  SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('오늘의 운동', style: TextStyle(color: GymColors.textDim)),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(day.row.name, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
                            ),
                            Text('예상 ${s.estimatedMinutes}분', style: const TextStyle(color: GymColors.textDim, fontSize: 15)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        preview.when(
                          skipLoadingOnReload: true,
                          loading: () => const LinearProgressIndicator(),
                          error: (e, _) => Text('$e'),
                          data: (items) => Column(
                            children: [
                              for (final (name, sum, action) in items)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(name, style: const TextStyle(fontSize: 15))),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(sum, style: const TextStyle(fontWeight: FontWeight.w800)),
                                          Text(action, style: TextStyle(fontSize: 11, color: _actionColor(action))),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (s.consecutiveWarning != null) ...[
                          const SizedBox(height: 8),
                          Text(s.consecutiveWarning!, style: const TextStyle(color: GymColors.warn, fontSize: 12)),
                        ],
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: FilledButton.icon(
                            onPressed: () => startWorkoutFlow(context, ref),
                            icon: const Icon(Icons.play_arrow_rounded, size: 28),
                            label: Text(s.inProgress != null ? '진행 중인 운동 이어하기' : '오늘의 운동 시작', style: const TextStyle(fontSize: 18)),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SectionCard(
                        child: StatTile(
                          label: '이번 주 운동',
                          value: '${s.week.done}/${s.week.planned}회',
                          color: s.week.done >= s.week.planned ? GymColors.accent : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SectionCard(
                        child: StatTile(label: '이번 주 총 세트', value: '${s.weekSets}세트'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SectionCard(
                  onTap: () => onNavigate(3),
                  child: Row(
                    children: [
                      const Icon(Icons.trending_up, color: GymColors.accent),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatTile(label: '최근 운동 성과', value: s.recentGain ?? '기록이 쌓이면 표시됩니다'),
                      ),
                      const Icon(Icons.chevron_right, color: GymColors.textDim),
                    ],
                  ),
                ),
                if (s.plan.isNotEmpty && s.program != null) ...[
                  const SectionTitle('이번 주 남은 일정'),
                  SectionCard(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      children: [
                        for (final w in s.plan)
                          ListTile(
                            dense: true,
                            leading: Text(weekdayKo[w.date.weekday], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                            title: Text(s.program!.days[w.dayIndex].row.name),
                            trailing: Text(DateFormat('M/d').format(w.date), style: const TextStyle(color: GymColors.textDim)),
                          ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text('운동을 건너뛰어도 순서는 유지되고 남은 날짜에 다시 배치됩니다.', style: TextStyle(color: GymColors.textDim, fontSize: 12)),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  static Color _actionColor(String a) {
    if (a == ProgressionAction.increaseWeight.ko) return GymColors.accent;
    if (a == ProgressionAction.decreaseWeight.ko || a == ProgressionAction.recover.ko) return GymColors.warn;
    if (a == ProgressionAction.establishBaseline.ko) return GymColors.info;
    return GymColors.textDim;
  }
}
