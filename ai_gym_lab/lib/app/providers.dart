import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ai/trainer_service.dart';
import '../data/db/database.dart';
import '../data/repository.dart';
import '../domain/engines/program_generator.dart';
import '../domain/engines/schedule_engine.dart';
import '../domain/engines/stats_engine.dart';
import '../domain/models.dart';

/// main()에서 실제 저장소로 override
final repositoryProvider = Provider<GymRepository>((ref) => throw UnimplementedError('repository not initialized'));

/// 데이터가 바뀔 때마다 증가 → 이를 watch하는 Provider들이 다시 로드됩니다.
class DataVersion extends Notifier<int> {
  @override
  int build() => 0;
  void bump() => state++;
}

final dataVersionProvider = NotifierProvider<DataVersion, int>(DataVersion.new);

extension RefreshX on WidgetRef {
  void refreshData() => read(dataVersionProvider.notifier).bump();
}

final profileProvider = FutureProvider<UserProfile?>((ref) {
  ref.watch(dataVersionProvider);
  return ref.read(repositoryProvider).getProfile();
});

final gateProvider = FutureProvider<(UserProfile?, ProgramView?)>((ref) async {
  ref.watch(dataVersionProvider);
  final repo = ref.read(repositoryProvider);
  return (await repo.getProfile(), await repo.getActiveProgram());
});

final activeProgramProvider = FutureProvider<ProgramView?>((ref) {
  ref.watch(dataVersionProvider);
  return ref.read(repositoryProvider).getActiveProgram();
});

final inProgressSessionProvider = FutureProvider<WorkoutSession?>((ref) {
  ref.watch(dataVersionProvider);
  return ref.read(repositoryProvider).inProgressSession();
});

final completedSessionsProvider = FutureProvider<List<SessionView>>((ref) {
  ref.watch(dataVersionProvider);
  return ref.read(repositoryProvider).completedSessions();
});

final programsProvider = FutureProvider<List<WorkoutProgram>>((ref) {
  ref.watch(dataVersionProvider);
  return ref.read(repositoryProvider).listPrograms();
});

final measurementsProvider = FutureProvider<List<BodyMeasurement>>((ref) {
  ref.watch(dataVersionProvider);
  return ref.read(repositoryProvider).measurements();
});

final trainerServiceProvider = Provider<TrainerService>((ref) => TrainerService(ref.read(repositoryProvider)));

class HomeSummary {
  final UserProfile? profile;
  final ProgramView? program;
  final int nextIndex;
  final WorkoutSession? inProgress;
  final int estimatedMinutes;
  final WeekProgress week;
  final int weekSets;
  final String? recentGain;
  final List<ScheduledWorkout> plan;
  final String? consecutiveWarning;

  /// 이번 주 운동한 요일(1=월~7=일)
  final Set<int> trainedWeekdays;
  const HomeSummary({
    this.trainedWeekdays = const {},
    required this.profile,
    required this.program,
    required this.nextIndex,
    required this.inProgress,
    required this.estimatedMinutes,
    required this.week,
    required this.weekSets,
    required this.recentGain,
    required this.plan,
    required this.consecutiveWarning,
  });

  DayView? get nextDay => program == null || program!.days.isEmpty ? null : program!.days[nextIndex];
}

final homeSummaryProvider = FutureProvider<HomeSummary>((ref) async {
  ref.watch(dataVersionProvider);
  final repo = ref.read(repositoryProvider);
  final now = DateTime.now();
  final profile = await repo.getProfile();
  final program = await repo.getActiveProgram();
  final inProgress = await repo.inProgressSession();
  final sessions = await repo.completedSessions(since: now.subtract(const Duration(days: 60)));
  final next = program == null ? 0 : await repo.nextDayIndex(program);
  final days = profile?.daysPerWeek ?? program?.days.length ?? 4;
  const se = ScheduleEngine();
  final week = se.weekProgress(sessions.map((s) => s.row.startedAt).toList(), now, days);
  final ws = ScheduleEngine.weekStart(now);
  final weekSets = sessions.where((s) => !s.row.startedAt.isBefore(ws)).fold(0, (a, s) => a + s.totalCompletedSets);
  var est = 0;
  if (program != null && program.days.isNotEmpty) {
    est = ProgramGenerator.estimateMinutes([
      for (final x in program.days[next].exercises)
        PlannedExercise(exerciseId: x.exerciseId, sets: x.sets, repMin: x.repMin, repMax: x.repMax, restSec: x.restSec),
    ]);
  }
  // 최근 운동 성과: 가장 최근 세션에서 이전보다 중량이 오른 운동
  String? gain;
  final stats = StatsEngine(repo.exercises);
  for (final s in sessions.take(3)) {
    for (final e in s.exercises.where((e) => e.completedSets > 0)) {
      final h = await repo.performanceHistory(e.exercise.id, limit: 6);
      final idx = h.indexWhere((p) => p.date == s.row.startedAt);
      if (idx < 0 || idx + 1 >= h.length) continue;
      final cur = h[idx], prev = h[idx + 1];
      final dw = e.exercise.assisted ? prev.workingWeight - cur.workingWeight : cur.workingWeight - prev.workingWeight;
      if (dw > 0) {
        gain = '${e.exercise.nameKo} +${_kg(dw)}kg';
        break;
      }
      if (stats.bestE1rm(cur) > stats.bestE1rm(prev) * 1.01 && gain == null) {
        gain = '${e.exercise.nameKo} 반복 수 향상';
      }
    }
    if (gain != null) break;
  }
  final plan = program == null
      ? <ScheduledWorkout>[]
      : se.planRemainingWeek(
          days: program.toPlan().days,
          completedDates: sessions.map((s) => s.row.startedAt).toList(),
          lastCompletedDayIndex: sessions.where((s) => s.row.programId == program.row.id).firstOrNull?.row.dayIndex,
          now: now,
          daysPerWeek: days,
        );
  String? warn;
  if (program != null && program.days.isNotEmpty && sessions.isNotEmpty) {
    final last = sessions.first;
    final lastM = {for (final e in last.exercises.where((e) => e.completedSets > 0)) ...e.exercise.primary};
    final nextM = {for (final x in program.days[next].exercises) ...repo.exercises[x.exerciseId]!.primary};
    warn = se.consecutiveWarning(
      lastSessionMuscles: lastM,
      nextMuscles: nextM,
      hoursSinceLast: now.difference(last.row.finishedAt ?? last.row.startedAt).inMinutes / 60,
    );
  }
  return HomeSummary(
    profile: profile,
    program: program,
    nextIndex: next,
    inProgress: inProgress,
    estimatedMinutes: est,
    week: week,
    weekSets: weekSets,
    recentGain: gain,
    plan: plan,
    consecutiveWarning: warn,
    trainedWeekdays: {for (final x in sessions.where((x) => !x.row.startedAt.isBefore(ws))) x.row.startedAt.weekday},
  );
});

String _kg(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
