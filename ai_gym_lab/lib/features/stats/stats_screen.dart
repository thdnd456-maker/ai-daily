import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../app/widgets.dart';
import '../../data/db/database.dart';
import '../../data/repository.dart';
import '../../domain/engines/progression_engine.dart';
import '../../domain/engines/schedule_engine.dart';
import '../../domain/engines/stats_engine.dart';
import '../../domain/engines/volume_engine.dart';
import '../../domain/models.dart';

class StatsData {
  final List<SessionView> sessions; // 최신순
  final List<BodyMeasurement> measurements;
  final Map<String, List<ExercisePerformance>> history; // 최신순
  final Map<Muscle, MuscleVolume> weekVolume;
  final VolumeTarget target;
  final WeeklyReview review;
  final int daysPerWeek;
  const StatsData(this.sessions, this.measurements, this.history, this.weekVolume, this.target, this.review, this.daysPerWeek);
}

final statsProvider = FutureProvider<StatsData>((ref) async {
  ref.watch(dataVersionProvider);
  final repo = ref.read(repositoryProvider);
  final now = DateTime.now();
  final sessions = await repo.completedSessions();
  final ms = await repo.measurements();
  final profile = await repo.getProfile() ?? const UserProfile();
  final history = <String, List<ExercisePerformance>>{};
  for (final s in sessions) {
    for (final e in s.exercises) {
      final sets = [
        for (final x in e.sets) SetRecord(weight: x.actualWeight ?? 0, reps: x.actualReps ?? 0, rir: x.rir, completed: x.completed && (x.actualReps ?? 0) > 0),
      ];
      if (!sets.any((x) => x.completed)) continue;
      history
          .putIfAbsent(e.exercise.id, () => [])
          .add(
            ExercisePerformance(
              date: s.row.startedAt,
              exerciseId: e.exercise.id,
              sets: sets,
              pain: e.row.pain,
              formUnstable: e.row.formUnstable,
              targetSets: e.row.targetSets,
              repMin: e.row.repMin,
              repMax: e.row.repMax,
            ),
          );
    }
  }
  final ws = ScheduleEngine.weekStart(now);
  final engine = VolumeEngine(repo.exercises);
  final weekVol = engine.compute([
    for (final s in sessions.where((s) => !s.row.startedAt.isBefore(ws)))
      for (final e in s.exercises) (e.exercise.id, e.completedSets),
  ]);
  final lastWeek = engine.compute([
    for (final s in sessions.where((s) => !s.row.startedAt.isBefore(ws.subtract(const Duration(days: 7))) && s.row.startedAt.isBefore(ws)))
      for (final e in s.exercises) (e.exercise.id, e.completedSets),
  ]);
  final logs = await repo.recoveryLogs(since: now.subtract(const Duration(days: 28)));
  final weights = ms.where((m) => m.weightKg != null && m.date.isAfter(now.subtract(const Duration(days: 28)))).toList();
  final target = weeklyVolumeTarget(profile);
  final review = StatsEngine(repo.exercises).review(
    historyByExercise: history,
    sessionDates: sessions.map((s) => s.row.startedAt).toList(),
    daysPerWeek: profile.daysPerWeek,
    now: now,
    lastWeekVolume: lastWeek,
    target: target,
    avgSleep: logs.isEmpty ? null : logs.map((l) => l.sleepHours).reduce((a, b) => a + b) / logs.length,
    avgFatigue: logs.isEmpty ? null : logs.map((l) => l.fatigue).reduce((a, b) => a + b) / logs.length,
    painCount: sessions
        .where((s) => s.row.startedAt.isAfter(now.subtract(const Duration(days: 28))))
        .fold(0, (a, s) => a + s.exercises.where((e) => e.row.pain).length),
    weightChangeKg: weights.length >= 2 ? weights.last.weightKg! - weights.first.weightKg! : null,
  );
  return StatsData(sessions, ms, history, weekVol, target, review, profile.daysPerWeek);
});

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});
  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  String? _exercise;

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(statsProvider);
    final repo = ref.read(repositoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('통계')),
      body: data.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (d) {
          if (d.sessions.isEmpty && d.measurements.isEmpty) {
            return const EmptyState(icon: Icons.insights, title: '통계를 만들 기록이 없습니다', message: '운동을 완료하거나 체중을 기록하면 그래프가 표시됩니다.');
          }
          final exIds = d.history.keys.toList()..sort((a, b) => d.history[b]!.length.compareTo(d.history[a]!.length));
          final sel = _exercise != null && d.history.containsKey(_exercise) ? _exercise! : exIds.firstOrNull;
          final stats = StatsEngine(repo.exercises);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _ReviewCard(review: d.review, repo: repo),
              const SectionTitle('근육별 주간 세트 (이번 주)'),
              SectionCard(child: _MuscleBars(d.weekVolume, d.target)),
              const SectionTitle('주간 운동 횟수 (최근 8주)'),
              SectionCard(child: _weeklyCount(d)),
              const SectionTitle('월간 운동 달성률'),
              SectionCard(child: _monthly(d)),
              if (sel != null) ...[
                SectionTitle(
                  '운동별 변화',
                  trailing: DropdownButton<String>(
                    value: sel,
                    underline: const SizedBox.shrink(),
                    onChanged: (v) => setState(() => _exercise = v),
                    items: [
                      for (final id in exIds)
                        DropdownMenuItem(
                          value: id,
                          child: Text(repo.exercises[id]!.nameKo, style: const TextStyle(fontSize: 14)),
                        ),
                    ],
                  ),
                ),
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('작업 중량 (kg)', style: TextStyle(color: GymColors.textDim)),
                      const SizedBox(height: 8),
                      _line([for (final p in d.history[sel]!.reversed) (p.date, p.workingWeight)], GymColors.accent),
                      const SizedBox(height: 16),
                      const Text('추정 1RM (kg)', style: TextStyle(color: GymColors.textDim)),
                      const SizedBox(height: 8),
                      _line([for (final p in d.history[sel]!.reversed) (p.date, stats.bestE1rm(p))], GymColors.info),
                      const SizedBox(height: 6),
                      const Text('추정 1RM은 Epley 공식에 따른 추정치이며 실제 최대근력 측정값이 아닙니다. 12회 초과 세트는 오차가 큽니다.', style: TextStyle(color: GymColors.textDim, fontSize: 11)),
                    ],
                  ),
                ),
              ],
              if (d.sessions.isNotEmpty) ...[
                const SectionTitle('총 운동 볼륨 (세션별)'),
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _line([for (final s in d.sessions.reversed.take(30)) (s.row.startedAt, s.volume)], GymColors.warn),
                      const SizedBox(height: 6),
                      const Text(
                        '총 볼륨 = 중량 × 반복 횟수 × 세트 수. 근육 성장량을 직접 의미하지 않으며, 같은 운동끼리 비교할 때만 참고하세요.',
                        style: TextStyle(color: GymColors.textDim, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SectionTitle('운동 시간 변화 (분)'),
                SectionCard(child: _line([for (final s in d.sessions.reversed.take(30)) (s.row.startedAt, s.durationMin.toDouble())], GymColors.research)),
              ],
              const SectionTitle('체중 변화'),
              SectionCard(
                child: d.measurements.where((m) => m.weightKg != null).length < 2
                    ? const Text('체중 기록이 2개 이상이면 그래프가 표시됩니다. (기록 탭 → 신체 변화)', style: TextStyle(color: GymColors.textDim))
                    : _line([for (final m in d.measurements.where((m) => m.weightKg != null)) (m.date, m.weightKg!)], GymColors.accent),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _weeklyCount(StatsData d) {
    final ws = ScheduleEngine.weekStart(DateTime.now());
    final counts = <int>[];
    for (var i = 7; i >= 0; i--) {
      final s = ws.subtract(Duration(days: 7 * i)), e = s.add(const Duration(days: 7));
      counts.add(d.sessions.where((x) => !x.row.startedAt.isBefore(s) && x.row.startedAt.isBefore(e)).length);
    }
    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          maxY: [d.daysPerWeek, ...counts].reduce((a, b) => a > b ? a : b).toDouble() + 1,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: _titles(bottom: (v) => i2label(v.toInt())),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(y: d.daysPerWeek.toDouble(), color: GymColors.accent.withValues(alpha: 0.5), dashArray: [4, 4]),
            ],
          ),
          barGroups: [
            for (var i = 0; i < counts.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: counts[i].toDouble(),
                    color: counts[i] >= d.daysPerWeek ? GymColors.accent : GymColors.accentDim,
                    width: 16,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  static String i2label(int i) => i == 7 ? '이번주' : '-${7 - i}주';

  Widget _monthly(StatsData d) {
    final now = DateTime.now();
    final rows = <Widget>[];
    for (var k = 5; k >= 0; k--) {
      final m = DateTime(now.year, now.month - k, 1);
      final next = DateTime(m.year, m.month + 1, 1);
      final end = next.isAfter(now) ? now : next;
      final days = end.difference(m).inDays.clamp(1, 31);
      final planned = (d.daysPerWeek * days / 7).round().clamp(1, 31);
      final done = d.sessions.where((s) => !s.row.startedAt.isBefore(m) && s.row.startedAt.isBefore(next)).length;
      final rate = (done / planned).clamp(0, 1).toDouble();
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(width: 50, child: Text(DateFormat('M월').format(m))),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(value: rate, minHeight: 12, color: GymColors.accent, backgroundColor: GymColors.surface2),
                ),
              ),
              SizedBox(
                width: 92,
                child: Text(' $done/$planned회 ${(rate * 100).round()}%', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      children: [
        ...rows,
        const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Text('계획 횟수 = 주당 운동일 × 해당 월의 주 수 (이번 달은 오늘까지)', style: TextStyle(color: GymColors.textDim, fontSize: 11)),
        ),
      ],
    );
  }

  FlTitlesData _titles({String Function(double)? bottom, bool showLeft = true}) => FlTitlesData(
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: showLeft,
        reservedSize: 40,
        getTitlesWidget: (v, meta) => SideTitleWidget(
          meta: meta,
          child: Text(fmtKg(v), style: const TextStyle(color: GymColors.textDim, fontSize: 10)),
        ),
      ),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: bottom != null,
        reservedSize: 24,
        getTitlesWidget: (v, meta) => SideTitleWidget(
          meta: meta,
          child: Text(bottom?.call(v) ?? '', style: const TextStyle(color: GymColors.textDim, fontSize: 10)),
        ),
      ),
    ),
  );

  Widget _line(List<(DateTime, double)> pts, Color color) {
    if (pts.isEmpty) return const Text('데이터 없음', style: TextStyle(color: GymColors.textDim));
    if (pts.length == 1) {
      return Text('${DateFormat('M/d').format(pts.first.$1)}: ${fmtKg(pts.first.$2)} (기록이 2개 이상이면 그래프 표시)', style: const TextStyle(color: GymColors.textDim));
    }
    final ys = pts.map((p) => p.$2);
    final minY = ys.reduce((a, b) => a < b ? a : b), maxY = ys.reduce((a, b) => a > b ? a : b);
    final pad = (maxY - minY).abs() < 1 ? 2.0 : (maxY - minY) * 0.15;
    return SizedBox(
      height: 170,
      child: LineChart(
        LineChartData(
          minY: (minY - pad).clamp(0, double.infinity).toDouble(),
          maxY: maxY + pad,
          gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => const FlLine(color: GymColors.line, strokeWidth: 0.5)),
          borderData: FlBorderData(show: false),
          titlesData: _titles(
            bottom: (v) {
              final i = v.round();
              if (i < 0 || i >= pts.length || v != i.toDouble()) return '';
              final step = (pts.length / 5).ceil();
              return i % step == 0 || i == pts.length - 1 ? DateFormat('M/d').format(pts[i].$1) : '';
            },
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => GymColors.surface2,
              getTooltipItems: (spots) => [
                for (final s in spots)
                  LineTooltipItem('${DateFormat('M/d').format(pts[s.x.toInt()].$1)}\n${fmtKg(s.y)}', const TextStyle(color: GymColors.text, fontSize: 12)),
              ],
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [for (var i = 0; i < pts.length; i++) FlSpot(i.toDouble(), double.parse(pts[i].$2.toStringAsFixed(2)))],
              isCurved: true,
              preventCurveOverShooting: true,
              color: color,
              barWidth: 3,
              dotData: FlDotData(show: pts.length <= 20),
              belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.08)),
            ),
          ],
        ),
      ),
    );
  }
}

class _MuscleBars extends StatelessWidget {
  final Map<Muscle, MuscleVolume> v;
  final VolumeTarget t;
  const _MuscleBars(this.v, this.t);
  @override
  Widget build(BuildContext context) {
    final maxV = [t.max.toDouble(), ...trackedMuscles.map((m) => v[m]!.total)].reduce((a, b) => a > b ? a : b);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final m in trackedMuscles)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(width: 82, child: Text(m.ko, style: const TextStyle(fontSize: 13))),
                Expanded(
                  child: LayoutBuilder(
                    builder: (_, c) {
                      final w = c.maxWidth;
                      return Stack(
                        children: [
                          Container(
                            height: 14,
                            decoration: BoxDecoration(color: GymColors.surface2, borderRadius: BorderRadius.circular(4)),
                          ),
                          Container(
                            height: 14,
                            width: w * (v[m]!.total / maxV).clamp(0, 1),
                            decoration: BoxDecoration(color: GymColors.info.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(4)),
                          ),
                          Container(
                            height: 14,
                            width: w * (v[m]!.direct / maxV).clamp(0, 1),
                            decoration: BoxDecoration(
                              color: v[m]!.direct >= t.min && v[m]!.direct <= t.max ? GymColors.accent : GymColors.warn,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Positioned(
                            left: w * t.min / maxV,
                            child: Container(width: 1.5, height: 14, color: Colors.white54),
                          ),
                          Positioned(
                            left: (w * t.max / maxV).clamp(0, w - 1.5),
                            child: Container(width: 1.5, height: 14, color: Colors.white54),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: 64,
                  child: Text(
                    ' ${v[m]!.direct.toInt()}${v[m]!.indirect > 0 ? ' +${v[m]!.indirect.toStringAsFixed(1)}' : ''}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        Text('진한 막대: 직접 세트 · 연한 막대: 간접 세트(보조 근육 × 0.5) · 흰 선: 시작 목표 ${t.min}~${t.max}세트', style: const TextStyle(color: GymColors.textDim, fontSize: 11)),
        const Text('간접 세트 가중치 0.5는 연구로 확정된 값이 아닌 앱의 추정 모델입니다. 세트가 많다고 반드시 더 좋은 운동은 아닙니다.', style: TextStyle(color: GymColors.textDim, fontSize: 11)),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final WeeklyReview review;
  final GymRepository repo;
  const _ReviewCard({required this.review, required this.repo});
  @override
  Widget build(BuildContext context) => SectionCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.auto_graph, color: GymColors.accent),
            SizedBox(width: 8),
            Text('최근 4주 분석', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 10),
        for (final i in review.insights)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text('• $i', style: const TextStyle(height: 1.35)),
          ),
        if (review.plateaus.isNotEmpty) ...[
          const SizedBox(height: 10),
          const Text(
            '정체 가능성',
            style: TextStyle(fontWeight: FontWeight.w800, color: GymColors.warn),
          ),
          for (final p in review.plateaus) Text('• ${repo.exercises[p.exerciseId]?.nameKo}: ${fmtKg(p.weight)}kg에서 ${p.sessions}회 연속 변화 없음'),
          const SizedBox(height: 6),
          const Text('가능한 원인과 조정 방안 (단정하지 않음)', style: TextStyle(color: GymColors.textDim, fontSize: 12)),
          for (final c in review.plateauCauses) Text('· $c', style: const TextStyle(fontSize: 13, height: 1.35)),
        ],
      ],
    ),
  );
}
