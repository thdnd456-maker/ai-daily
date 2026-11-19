// 운동 통계 분석 엔진
//
// - 추정 1RM: Epley 공식(중량 × (1 + 반복/30)). 실제 1RM 측정값이 아닌 추정치이며,
//   반복 수가 많을수록(12회 초과) 오차가 커서 신뢰도 낮음으로 표시합니다.
// - 총 운동 볼륨: 중량 × 반복 (완료 세트 합계). 근육 성장량을 직접 의미하지 않습니다.
import '../models.dart';
import 'progression_engine.dart' show fmtKg;
import 'volume_engine.dart';

class E1rm {
  final double value;
  final bool reliable;
  const E1rm(this.value, this.reliable);
}

E1rm estimate1rm(double weight, int reps) {
  if (reps <= 0 || weight <= 0) return const E1rm(0, false);
  if (reps == 1) return E1rm(weight, true);
  return E1rm(weight * (1 + reps / 30), reps <= 12);
}

double setVolume(SetRecord s) => s.completed ? s.weight * s.reps : 0;

class SessionSummary {
  final DateTime date;
  final int durationMin;
  final double volume;
  final int sets;
  const SessionSummary(this.date, this.durationMin, this.volume, this.sets);
}

class Plateau {
  final String exerciseId;
  final int sessions;
  final double weight;
  const Plateau(this.exerciseId, this.sessions, this.weight);
}

class ExerciseTrend {
  final String exerciseId;
  final double startWeight;
  final double endWeight;
  final double startE1rm;
  final double endE1rm;
  const ExerciseTrend(this.exerciseId, this.startWeight, this.endWeight, this.startE1rm, this.endE1rm);
}

class WeeklyReview {
  final double attendanceRate;
  final int completedSessions;
  final int plannedSessions;
  final List<ExerciseTrend> improving;
  final List<Plateau> plateaus;
  final List<String> insights;
  final List<String> plateauCauses;
  const WeeklyReview({
    required this.attendanceRate,
    required this.completedSessions,
    required this.plannedSessions,
    required this.improving,
    required this.plateaus,
    required this.insights,
    required this.plateauCauses,
  });
}

class StatsEngine {
  final Map<String, Exercise> exercises;
  const StatsEngine(this.exercises);

  double bestE1rm(ExercisePerformance p) {
    var best = 0.0;
    for (final s in p.completedSets) {
      final e = estimate1rm(s.weight, s.reps).value;
      if (e > best) best = e;
    }
    return best;
  }

  /// 같은 중량에서 3회 이상, 추정 1RM이 1% 넘게 오르지 않으면 정체로 봅니다(앱 기본값).
  Plateau? detectPlateau(List<ExercisePerformance> historyNewestFirst) {
    final h = historyNewestFirst.where((p) => p.completedSets.isNotEmpty).toList();
    if (h.length < 3) return null;
    final w = h.first.workingWeight;
    var n = 0;
    for (final p in h) {
      if (p.workingWeight != w) break;
      n++;
    }
    if (n < 3) return null;
    final newest = bestE1rm(h.first), oldest = bestE1rm(h[n - 1]);
    if (newest > oldest * 1.01) return null;
    final span = h.first.date.difference(h[n - 1].date).inDays;
    if (span < 10) return null;
    return Plateau(h.first.exerciseId, n, w);
  }

  /// 최근 수행 능력 하락 여부(최근 2회 비교, 추정 1RM 5% 이상 하락)
  bool performanceDropped(List<ExercisePerformance> historyNewestFirst) {
    final h = historyNewestFirst.where((p) => p.completedSets.isNotEmpty).toList();
    if (h.length < 2) return false;
    return bestE1rm(h[0]) < bestE1rm(h[1]) * 0.95;
  }

  /// 주간(최근 4주) 분석
  WeeklyReview review({
    required Map<String, List<ExercisePerformance>> historyByExercise, // 최신순
    required List<DateTime> sessionDates,
    required int daysPerWeek,
    required DateTime now,
    required Map<Muscle, MuscleVolume> lastWeekVolume,
    required VolumeTarget target,
    double? avgSleep,
    double? avgFatigue,
    int painCount = 0,
    double? weightChangeKg,
  }) {
    final from = now.subtract(const Duration(days: 28));
    final done = sessionDates.where((d) => d.isAfter(from)).length;
    final planned = daysPerWeek * 4;
    final rate = planned == 0 ? 0.0 : (done / planned).clamp(0, 1).toDouble();
    final improving = <ExerciseTrend>[];
    final plateaus = <Plateau>[];
    for (final entry in historyByExercise.entries) {
      final recent = entry.value.where((p) => p.date.isAfter(from) && p.completedSets.isNotEmpty).toList();
      if (recent.length >= 2) {
        final first = recent.last, last = recent.first;
        final t = ExerciseTrend(entry.key, first.workingWeight, last.workingWeight, bestE1rm(first), bestE1rm(last));
        if (t.endE1rm > t.startE1rm * 1.01 || t.endWeight > t.startWeight) improving.add(t);
      }
      final p = detectPlateau(entry.value);
      if (p != null) plateaus.add(p);
    }
    improving.sort((a, b) => (b.endE1rm / (b.startE1rm == 0 ? 1 : b.startE1rm)).compareTo(a.endE1rm / (a.startE1rm == 0 ? 1 : a.startE1rm)));

    final insights = <String>['최근 4주 출석: $done/$planned회 (${(rate * 100).round()}%)'];
    for (final t in improving.take(3)) {
      final name = exercises[t.exerciseId]?.nameKo ?? t.exerciseId;
      insights.add('$name: ${fmtKg(t.startWeight)}kg → ${fmtKg(t.endWeight)}kg (추정 1RM ${fmtKg(_r(t.startE1rm))} → ${fmtKg(_r(t.endE1rm))}kg)');
    }
    if (improving.isNotEmpty && plateaus.isEmpty && rate >= 0.75) {
      insights.add('수행 능력이 꾸준히 향상되고 있습니다. 현재 프로그램을 유지하는 것을 추천합니다.');
    }
    if (weightChangeKg != null) {
      insights.add('체중 변화(최근 기록 기준): ${weightChangeKg >= 0 ? '+' : ''}${weightChangeKg.toStringAsFixed(1)}kg');
    }
    if (painCount > 0) insights.add('최근 4주 통증 기록 $painCount회 — 해당 운동은 자동 중량 증가가 제한됩니다.');

    // 정체 원인 후보 (단정하지 않음)
    final causes = <String>[];
    if (plateaus.isNotEmpty) {
      final lowMuscles = <String>{};
      for (final p in plateaus) {
        final e = exercises[p.exerciseId];
        if (e == null) continue;
        for (final m in e.primary) {
          final v = lastWeekVolume[m]?.direct ?? 0;
          if (v < target.min) lowMuscles.add(m.ko);
        }
      }
      if (lowMuscles.isNotEmpty) causes.add('운동량 부족 가능성: ${lowMuscles.join('·')}의 지난주 직접 세트가 시작 목표보다 적었습니다.');
      if (avgFatigue != null && avgFatigue >= 3.5) causes.add('과도한 피로 가능성: 최근 평균 피로도 ${avgFatigue.toStringAsFixed(1)}/5.');
      if (avgSleep != null && avgSleep < 6.5) causes.add('수면 부족 가능성: 최근 평균 수면 ${avgSleep.toStringAsFixed(1)}시간.');
      if (rate < 0.75) causes.add('운동 수행의 일관성: 최근 4주 출석률이 ${(rate * 100).round()}%입니다.');
      causes.add('운동 빈도: 해당 근육을 주 2회 정도 자극하고 있는지 확인하세요.');
      causes.add('식사 상태: 체중이 줄고 있다면 정체가 자연스러울 수 있으며, 단백질 섭취량도 확인해 보세요(앱은 식사 기록을 받지 않습니다).');
      causes.add('운동 자세: 가동범위나 템포가 바뀌면 기록이 정체된 것처럼 보일 수 있습니다.');
      causes.add('조정 방안 예시: 해당 근육 주간 세트 +2, 1주간 운동량을 줄인 회복 주, 비슷한 패턴의 대체 운동으로 변경.');
    }
    return WeeklyReview(
      attendanceRate: rate,
      completedSessions: done,
      plannedSessions: planned,
      improving: improving,
      plateaus: plateaus,
      insights: insights,
      plateauCauses: causes,
    );
  }

  static double _r(double v) => (v * 2).round() / 2;
}
