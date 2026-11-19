// 운동 일정 재조정 엔진
//
// 프로그램은 '순환 방식'으로 진행됩니다. 요일을 놓쳐도 다음 운동은 마지막으로 완료한
// 운동의 다음 순서이므로, 건너뛴 운동이 사라지지 않고 일정이 자연스럽게 밀립니다.
import '../models.dart';

class ScheduledWorkout {
  final DateTime date;
  final int dayIndex;
  const ScheduledWorkout(this.date, this.dayIndex);
}

class WeekProgress {
  final int done;
  final int planned;
  const WeekProgress(this.done, this.planned);
}

class ScheduleEngine {
  const ScheduleEngine();

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
  static DateTime weekStart(DateTime d) => dateOnly(d).subtract(Duration(days: d.weekday - 1));

  /// 다음에 할 운동 순서
  int nextDayIndex({required int dayCount, int? lastCompletedDayIndex}) {
    if (dayCount <= 0) return 0;
    if (lastCompletedDayIndex == null) return 0;
    return (lastCompletedDayIndex + 1) % dayCount;
  }

  WeekProgress weekProgress(List<DateTime> completedDates, DateTime now, int daysPerWeek) {
    final ws = weekStart(now);
    final we = ws.add(const Duration(days: 7));
    final done = completedDates.where((d) => !d.isBefore(ws) && d.isBefore(we)).map(dateOnly).toSet().length;
    return WeekProgress(done, daysPerWeek);
  }

  /// 이번 주 남은 운동을 남은 날짜에 배치합니다.
  /// - 오늘 이미 운동했다면 내일부터 배치
  /// - 남은 날보다 운동이 많으면 가능한 만큼만 배치(나머지는 다음 주로 이월)
  /// - 가능하면 연속일을 피해 고르게 분산
  List<ScheduledWorkout> planRemainingWeek({
    required List<PlannedDay> days,
    required List<DateTime> completedDates,
    required int? lastCompletedDayIndex,
    required DateTime now,
    required int daysPerWeek,
  }) {
    if (days.isEmpty) return [];
    final today = dateOnly(now);
    final trainedToday = completedDates.any((d) => dateOnly(d) == today);
    final progress = weekProgress(completedDates, now, daysPerWeek);
    final remaining = (daysPerWeek - progress.done).clamp(0, 7);
    final we = weekStart(now).add(const Duration(days: 7));
    final available = <DateTime>[];
    for (var d = trainedToday ? today.add(const Duration(days: 1)) : today; d.isBefore(we); d = d.add(const Duration(days: 1))) {
      available.add(d);
    }
    final n = remaining < available.length ? remaining : available.length;
    if (n == 0) return [];
    // 고르게 분산: 선호 요일과 맞는 날을 먼저 고려하고, 부족하면 균등 간격
    final chosen = <DateTime>[];
    if (n == available.length) {
      chosen.addAll(available);
    } else {
      final step = available.length / n;
      for (var k = 0; k < n; k++) {
        chosen.add(available[(k * step).floor()]);
      }
    }
    var idx = nextDayIndex(dayCount: days.length, lastCompletedDayIndex: lastCompletedDayIndex);
    final out = <ScheduledWorkout>[];
    for (final d in chosen) {
      out.add(ScheduledWorkout(d, idx));
      idx = (idx + 1) % days.length;
    }
    return out;
  }

  /// 같은 부위를 연속으로 운동하려 할 때 경고 문구 (null이면 문제 없음)
  String? consecutiveWarning({required Set<Muscle> lastSessionMuscles, required Set<Muscle> nextMuscles, required double hoursSinceLast}) {
    if (hoursSinceLast >= 36) return null;
    final overlap = lastSessionMuscles.intersection(nextMuscles).where(trackedMuscles.contains).toList();
    if (overlap.length < 3) return null;
    return '마지막 운동(${hoursSinceLast.round()}시간 전)과 ${overlap.take(4).map((m) => m.ko).join('·')} 등이 겹칩니다. '
        '근육통이 크다면 운동량을 줄이거나 다른 순서의 운동을 먼저 하는 것을 고려하세요.';
  }
}
