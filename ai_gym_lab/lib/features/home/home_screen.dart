import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/exercise_visuals.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../app/widgets.dart';
import '../../domain/engines/progression_engine.dart';
import '../../domain/models.dart';
import '../exercise/exercise_library_screen.dart';
import '../settings/settings_screen.dart';
import '../workout/start_flow.dart';

/// 다음 운동의 운동별 오늘 추천
final nextPreviewProvider = FutureProvider<List<(Exercise, ProgressionRecommendation, String)>>((ref) async {
  final summary = await ref.watch(homeSummaryProvider.future);
  final day = summary.nextDay;
  if (day == null) return [];
  final repo = ref.read(repositoryProvider);
  final out = <(Exercise, ProgressionRecommendation, String)>[];
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
    out.add((e, r, '${x.sets}세트 · ${x.repMin}~${x.repMax}${e.timed ? '초' : '회'}'));
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
      body: SafeArea(
        child: summary.when(
          skipLoadingOnReload: true,
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('오류: $e')),
          data: (s) {
            final day = s.nextDay;
            final items = preview.value ?? const [];
            return RefreshIndicator(
              onRefresh: () async => ref.refreshData(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  // 헤더
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DateFormat('M월 d일 EEEE', 'ko_KR').format(now), style: const TextStyle(color: GymColors.textDim, fontSize: 14)),
                            const SizedBox(height: 2),
                            const Text('오늘도 한 세트씩', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ),
                      IconButton.filledTonal(
                        style: IconButton.styleFrom(backgroundColor: GymColors.surface),
                        icon: const Icon(Icons.settings_outlined),
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _WeekStrip(s: s, now: now),
                  const SizedBox(height: 16),
                  if (day != null) _HeroCard(s: s, items: items, onStart: () => startWorkoutFlow(context, ref)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _MiniStat(icon: Icons.local_fire_department, label: '이번 주', value: '${s.week.done}/${s.week.planned}회'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MiniStat(icon: Icons.stacked_bar_chart, label: '총 세트', value: '${s.weekSets}'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MiniStat(
                          icon: Icons.trending_up,
                          label: '최근 성과',
                          value: s.recentGain == null ? '-' : s.recentGain!.split(' ').last,
                          onTap: () => onNavigate(3),
                        ),
                      ),
                    ],
                  ),
                  if (s.recentGain != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 4),
                      child: Text('최근 성과: ${s.recentGain}', style: const TextStyle(color: GymColors.textDim, fontSize: 12.5)),
                    ),
                  if (items.isNotEmpty) ...[
                    const SectionTitle('오늘 추천 중량'),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          children: [
                            for (final (e, r, presc) in items)
                              ExerciseTile(
                                exercise: e,
                                subtitle: presc,
                                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ExerciseDetailScreen(exercise: e))),
                                trailing: _RecBadge(rec: r, exercise: e),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (s.consecutiveWarning != null) ...[const SizedBox(height: 12), _Notice(text: s.consecutiveWarning!)],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  final HomeSummary s;
  final DateTime now;
  const _WeekStrip({required this.s, required this.now});
  @override
  Widget build(BuildContext context) {
    const names = ['월', '화', '수', '목', '금', '토', '일'];
    final planned = {for (final w in s.plan) w.date.weekday};
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var d = 1; d <= 7; d++)
          Column(
            children: [
              Text(
                names[d - 1],
                style: TextStyle(fontSize: 12, color: d == now.weekday ? GymColors.text : GymColors.textDim, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: s.trainedWeekdays.contains(d)
                      ? GymColors.accent
                      : (planned.contains(d) ? GymColors.accent.withValues(alpha: 0.12) : GymColors.surface),
                  border: d == now.weekday ? Border.all(color: GymColors.accent, width: 2) : null,
                ),
                child: s.trainedWeekdays.contains(d)
                    ? const Icon(Icons.check_rounded, size: 20, color: Colors.black)
                    : planned.contains(d)
                    ? const Icon(Icons.fitness_center, size: 15, color: GymColors.accent)
                    : null,
              ),
            ],
          ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final HomeSummary s;
  final List<(Exercise, ProgressionRecommendation, String)> items;
  final VoidCallback onStart;
  const _HeroCard({required this.s, required this.items, required this.onStart});

  @override
  Widget build(BuildContext context) {
    final day = s.nextDay!;
    final resuming = s.inProgress != null;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF26301A), GymColors.surface]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            resuming ? '진행 중인 운동' : '오늘의 운동',
            style: const TextStyle(color: GymColors.accent, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(resuming ? s.inProgress!.dayName : day.row.name, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, height: 1.1)),
          const SizedBox(height: 6),
          Text('${day.exercises.length}개 운동 · 약 ${s.estimatedMinutes}분', style: const TextStyle(color: GymColors.textDim)),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 14),
            SizedBox(
              height: 64,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => showExercisePhotoViewer(context, items[i].$1),
                  child: ExercisePhoto(exercise: items[i].$1, width: 64, height: 64, radius: 14),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              onPressed: onStart,
              icon: Icon(resuming ? Icons.play_circle_fill : Icons.play_arrow_rounded, size: 28),
              label: Text(resuming ? '이어하기' : '운동 시작', style: const TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  const _MiniStat({required this.icon, required this.label, required this.value, this.onTap});
  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: GymColors.accent),
            const SizedBox(height: 8),
            FittedBox(
              child: Text(value, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
            ),
            Text(label, style: const TextStyle(color: GymColors.textDim, fontSize: 12)),
          ],
        ),
      ),
    ),
  );
}

class _RecBadge extends StatelessWidget {
  final ProgressionRecommendation rec;
  final Exercise exercise;
  const _RecBadge({required this.rec, required this.exercise});
  @override
  Widget build(BuildContext context) {
    final up = rec.action == ProgressionAction.increaseWeight;
    final down = rec.action == ProgressionAction.decreaseWeight || rec.action == ProgressionAction.recover;
    final color = up ? GymColors.accent : (down ? GymColors.warn : GymColors.text);
    final text = rec.weight == null ? '기준 찾기' : '${fmtKg(rec.weight!)}kg';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          text,
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: rec.weight == null ? GymColors.info : color),
        ),
        if (up)
          const Text(
            '▲ 증가',
            style: TextStyle(color: GymColors.accent, fontSize: 11, fontWeight: FontWeight.w700),
          )
        else if (down)
          Text(
            '▼ ${rec.action.ko}',
            style: const TextStyle(color: GymColors.warn, fontSize: 11, fontWeight: FontWeight.w700),
          ),
      ],
    );
  }
}

class _Notice extends StatelessWidget {
  final String text;
  const _Notice({required this.text});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: GymColors.warn.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16)),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline, size: 18, color: GymColors.warn),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 12.5, height: 1.4))),
      ],
    ),
  );
}
