// 저장소 계층: DB 행 ↔ 도메인 모델 변환과 트랜잭션을 담당합니다.
// 화면(UI)은 DB를 직접 다루지 않고 이 클래스만 사용합니다.
import 'dart:convert';

import 'package:drift/drift.dart';

import '../domain/catalog/exercise_catalog.dart';
import '../domain/catalog/research.dart';
import '../domain/engines/progression_engine.dart';
import '../domain/engines/recovery_engine.dart';
import '../domain/engines/schedule_engine.dart';
import '../domain/models.dart';
import 'db/database.dart';

const int localUserId = 1;
const int seedVersion = 1;

class ProgramView {
  final WorkoutProgram row;
  final List<DayView> days;
  const ProgramView(this.row, this.days);

  SplitType get split => SplitType.values.byName(row.split);
  List<Rationale> get rationale => (jsonDecode(row.rationale) as List).map((e) => Rationale.fromJson(e as Map<String, dynamic>)).toList();

  ProgramPlan toPlan() => ProgramPlan(
    name: row.name,
    split: split,
    rationale: rationale,
    days: [
      for (final d in days)
        PlannedDay(
          name: d.row.name,
          weekday: d.row.weekday,
          exercises: [
            for (final x in d.exercises)
              PlannedExercise(
                exerciseId: x.exerciseId,
                sets: x.sets,
                repMin: x.repMin,
                repMax: x.repMax,
                targetRir: x.targetRir,
                restSec: x.restSec,
                startWeight: x.startWeight,
                notes: x.notes,
              ),
          ],
        ),
    ],
  );
}

class DayView {
  final WorkoutDay row;
  final List<WorkoutExercise> exercises;
  const DayView(this.row, this.exercises);
}

class SessionExerciseView {
  final SessionExercise row;
  final Exercise exercise;
  final List<WorkoutSet> sets;
  final ProgressionRecommendation? recommendation;
  const SessionExerciseView(this.row, this.exercise, this.sets, this.recommendation);

  int get completedSets => sets.where((s) => s.completed).length;
}

class SessionView {
  final WorkoutSession row;
  final List<SessionExerciseView> exercises;
  const SessionView(this.row, this.exercises);

  int get totalCompletedSets => exercises.fold(0, (a, e) => a + e.completedSets);
  double get volume => exercises.fold(0.0, (a, e) => a + e.sets.where((s) => s.completed).fold(0.0, (b, s) => b + (s.actualWeight ?? 0) * (s.actualReps ?? 0)));
  int get durationMin => row.finishedAt == null ? 0 : row.finishedAt!.difference(row.startedAt).inMinutes;
}

class GymRepository {
  final AppDatabase db;
  Map<String, Exercise> _exercises = exerciseById;
  final ProgressionEngine progression = const ProgressionEngine();

  GymRepository(this.db);

  Map<String, Exercise> get exercises => _exercises;
  List<Exercise> get exerciseList => _exercises.values.toList();

  // ───────────────────────── 초기화 / 시드 ─────────────────────────

  Future<void> init() async {
    await _ensureUser();
    final v = await getSetting('seed.version');
    final count = await db.exercises.count().getSingle();
    if (v != '$seedVersion' || count < exerciseCatalog.length) {
      await _seed();
      await setSetting('seed.version', '$seedVersion');
    }
    _exercises = await _loadExercises();
  }

  Future<void> _ensureUser() async {
    final u = await (db.select(db.users)..where((t) => t.id.equals(localUserId))).getSingleOrNull();
    if (u == null) await db.into(db.users).insert(UsersCompanion.insert(id: const Value(localUserId)));
  }

  Future<void> _seed() async {
    await db.batch((b) {
      b.insertAllOnConflictUpdate(db.exercises, [for (final e in exerciseCatalog) _exerciseCompanion(e)]);
      b.insertAllOnConflictUpdate(db.exerciseMuscles, [
        for (final e in exerciseCatalog) ...[
          for (final m in e.primary) ExerciseMusclesCompanion.insert(exerciseId: e.id, muscle: m.name, role: 'primary'),
          for (final m in e.secondary) ExerciseMusclesCompanion.insert(exerciseId: e.id, muscle: m.name, role: 'secondary'),
        ],
      ]);
      b.insertAllOnConflictUpdate(db.exerciseAlternatives, [
        for (final e in exerciseCatalog)
          for (var i = 0; i < e.alternatives.length; i++) ExerciseAlternativesCompanion.insert(exerciseId: e.id, alternativeId: e.alternatives[i], rank: i),
      ]);
      b.insertAllOnConflictUpdate(db.researchReferences, [
        for (final r in researchReferences)
          ResearchReferencesCompanion.insert(
            id: r.id,
            title: r.title,
            authors: r.authors,
            year: r.year,
            journal: r.journal,
            studyType: r.studyType,
            population: r.population,
            keyFindings: r.keyFindings,
            limitations: r.limitations,
            appliedIn: r.appliedIn,
          ),
      ]);
    });
  }

  ExercisesCompanion _exerciseCompanion(Exercise e) => ExercisesCompanion.insert(
    id: e.id,
    nameKo: e.nameKo,
    nameEn: e.nameEn,
    equipment: e.equipment.map((q) => q.name).join(','),
    type: e.type.name,
    pattern: e.pattern.name,
    difficulty: e.difficulty,
    repMin: e.repMin,
    repMax: e.repMax,
    restSec: e.restSec,
    description: e.description,
    cues: jsonEncode(e.cues),
    mistakes: jsonEncode(e.mistakes),
    cautions: jsonEncode(e.cautions),
    jointStress: jsonEncode({for (final kv in e.jointStress.entries) kv.key.name: kv.value}),
    referenceIds: jsonEncode(e.referenceIds),
    videoUrl: Value(e.videoUrl),
    assisted: Value(e.assisted),
    bodyweight: Value(e.bodyweight),
    timed: Value(e.timed),
    isCustom: Value(e.isCustom),
  );

  Future<Map<String, Exercise>> _loadExercises() async {
    final rows = await db.select(db.exercises).get();
    final muscles = await db.select(db.exerciseMuscles).get();
    final alts = await (db.select(db.exerciseAlternatives)..orderBy([(t) => OrderingTerm(expression: t.rank)])).get();
    final pm = <String, List<Muscle>>{}, sm = <String, List<Muscle>>{}, am = <String, List<String>>{};
    for (final m in muscles) {
      (m.role == 'primary' ? pm : sm).putIfAbsent(m.exerciseId, () => []).add(Muscle.values.byName(m.muscle));
    }
    for (final a in alts) {
      am.putIfAbsent(a.exerciseId, () => []).add(a.alternativeId);
    }
    List<String> sl(String s) => (jsonDecode(s) as List).cast<String>();
    // 시드 순서(카탈로그 순서)를 유지하기 위해 원본 순서대로 정렬
    final order = {for (var i = 0; i < exerciseCatalog.length; i++) exerciseCatalog[i].id: i};
    rows.sort((a, b) => (order[a.id] ?? 9999).compareTo(order[b.id] ?? 9999));
    return {
      for (final r in rows)
        r.id: Exercise(
          id: r.id,
          nameKo: r.nameKo,
          nameEn: r.nameEn,
          primary: pm[r.id] ?? const [],
          secondary: sm[r.id] ?? const [],
          equipment: r.equipment.split(',').where((s) => s.isNotEmpty).map(Equipment.values.byName).toList(),
          type: ExerciseType.values.byName(r.type),
          pattern: MovementPattern.values.byName(r.pattern),
          difficulty: r.difficulty,
          repMin: r.repMin,
          repMax: r.repMax,
          restSec: r.restSec,
          description: r.description,
          cues: sl(r.cues),
          mistakes: sl(r.mistakes),
          cautions: sl(r.cautions),
          jointStress: {for (final kv in (jsonDecode(r.jointStress) as Map<String, dynamic>).entries) JointArea.values.byName(kv.key): kv.value as int},
          alternatives: am[r.id] ?? const [],
          referenceIds: sl(r.referenceIds),
          videoUrl: r.videoUrl,
          assisted: r.assisted,
          bodyweight: r.bodyweight,
          timed: r.timed,
          isCustom: r.isCustom,
        ),
    };
  }

  // ───────────────────────── 설정 ─────────────────────────

  Future<String?> getSetting(String key) async => (await (db.select(db.appSettings)..where((t) => t.key.equals(key))).getSingleOrNull())?.value;

  Future<void> setSetting(String key, String? value) async {
    if (value == null) {
      await (db.delete(db.appSettings)..where((t) => t.key.equals(key))).go();
    } else {
      await db.into(db.appSettings).insertOnConflictUpdate(AppSettingsCompanion.insert(key: key, value: value));
    }
  }

  Future<double> incrementFor(Exercise e, {double? override}) async {
    if (override != null && override > 0) return override;
    final s = await getSetting('increment.${e.primaryEquipment.name}');
    return double.tryParse(s ?? '') ?? e.primaryEquipment.defaultIncrementKg;
  }

  // ───────────────────────── 프로필 ─────────────────────────

  Future<UserProfile?> getProfile() async {
    final p = await (db.select(db.userProfiles)..where((t) => t.userId.equals(localUserId))).getSingleOrNull();
    if (p == null) return null;
    final goals =
        await (db.select(db.userGoals)
              ..where((t) => t.userId.equals(localUserId))
              ..orderBy([(t) => OrderingTerm(expression: t.priority)]))
            .get();
    final eq = await (db.select(db.userEquipment)..where((t) => t.userId.equals(localUserId))).get();
    final lim = await (db.select(db.userLimitations)..where((t) => t.userId.equals(localUserId) & t.active.equals(true))).get();
    return UserProfile(
      sex: Sex.values.byName(p.sex),
      age: p.age,
      heightCm: p.heightCm,
      weightKg: p.weightKg,
      targetWeightKg: p.targetWeightKg,
      bodyFatPct: p.bodyFatPct,
      skeletalMuscleKg: p.skeletalMuscleKg,
      goals: goals.map((g) => Goal.values.byName(g.goal)).toList(),
      experience: Experience.values.byName(p.experience),
      daysPerWeek: p.daysPerWeek,
      sessionMinutes: p.sessionMinutes,
      environment: GymEnvironment.values.byName(p.environment),
      equipment: eq.map((e) => Equipment.values.byName(e.equipment)).toSet(),
      limitations: [for (final l in lim) Limitation(area: JointArea.values.byName(l.area), severity: l.severity, timing: l.timing, notes: l.notes)],
    );
  }

  Future<void> saveProfile(UserProfile p) async {
    await db.transaction(() async {
      await db
          .into(db.userProfiles)
          .insertOnConflictUpdate(
            UserProfilesCompanion.insert(
              userId: const Value(localUserId),
              sex: p.sex.name,
              age: p.age,
              heightCm: p.heightCm,
              weightKg: p.weightKg,
              targetWeightKg: Value(p.targetWeightKg),
              bodyFatPct: Value(p.bodyFatPct),
              skeletalMuscleKg: Value(p.skeletalMuscleKg),
              experience: p.experience.name,
              daysPerWeek: p.daysPerWeek,
              sessionMinutes: p.sessionMinutes,
              environment: p.environment.name,
              updatedAt: Value(DateTime.now()),
            ),
          );
      await (db.delete(db.userGoals)..where((t) => t.userId.equals(localUserId))).go();
      for (var i = 0; i < p.goals.length; i++) {
        await db.into(db.userGoals).insert(UserGoalsCompanion.insert(userId: localUserId, goal: p.goals[i].name, priority: i));
      }
      await (db.delete(db.userEquipment)..where((t) => t.userId.equals(localUserId))).go();
      for (final e in p.equipment) {
        await db.into(db.userEquipment).insert(UserEquipmentCompanion.insert(userId: localUserId, equipment: e.name));
      }
      await (db.delete(db.userLimitations)..where((t) => t.userId.equals(localUserId))).go();
      for (final l in p.limitations) {
        await db
            .into(db.userLimitations)
            .insert(
              UserLimitationsCompanion.insert(userId: localUserId, area: l.area.name, severity: l.severity, timing: Value(l.timing), notes: Value(l.notes)),
            );
      }
    });
  }

  // ───────────────────────── 프로그램 ─────────────────────────

  Future<int> saveProgram(ProgramPlan plan, {required String source, bool activate = true, int? basedOn}) async {
    return db.transaction(() async {
      if (activate) await db.update(db.workoutPrograms).write(const WorkoutProgramsCompanion(isActive: Value(false)));
      final id = await db
          .into(db.workoutPrograms)
          .insert(
            WorkoutProgramsCompanion.insert(
              userId: localUserId,
              name: plan.name,
              split: plan.split.name,
              source: source,
              isActive: Value(activate),
              basedOnProgramId: Value(basedOn),
              rationale: Value(jsonEncode(plan.rationale.map((r) => r.toJson()).toList())),
            ),
          );
      await _writeDays(id, plan.days);
      return id;
    });
  }

  Future<void> _writeDays(int programId, List<PlannedDay> days) async {
    for (var i = 0; i < days.length; i++) {
      final d = days[i];
      final dayId = await db.into(db.workoutDays).insert(WorkoutDaysCompanion.insert(programId: programId, dayIndex: i, weekday: d.weekday, name: d.name));
      for (var j = 0; j < d.exercises.length; j++) {
        final x = d.exercises[j];
        await db
            .into(db.workoutExercises)
            .insert(
              WorkoutExercisesCompanion.insert(
                dayId: dayId,
                exerciseId: x.exerciseId,
                orderIndex: j,
                sets: x.sets,
                repMin: x.repMin,
                repMax: x.repMax,
                targetRir: x.targetRir,
                restSec: x.restSec,
                startWeight: Value(x.startWeight),
                notes: Value(x.notes),
              ),
            );
      }
    }
  }

  /// 사용자 수정 저장. AI가 만든 프로그램을 수정하면 원본은 보존하고 사용자 버전을 새로 저장합니다.
  Future<int> updateProgram(int programId, ProgramPlan plan) async {
    final row = await (db.select(db.workoutPrograms)..where((t) => t.id.equals(programId))).getSingle();
    if (row.source == 'ai') {
      final name = plan.name.endsWith('(내 수정)') ? plan.name : '${plan.name} (내 수정)';
      return saveProgram(
        ProgramPlan(name: name, split: plan.split, days: plan.days, rationale: plan.rationale),
        source: 'user',
        activate: row.isActive,
        basedOn: programId,
      );
    }
    await db.transaction(() async {
      await (db.update(db.workoutPrograms)..where((t) => t.id.equals(programId))).write(
        WorkoutProgramsCompanion(name: Value(plan.name), split: Value(plan.split.name), updatedAt: Value(DateTime.now())),
      );
      await (db.delete(db.workoutDays)..where((t) => t.programId.equals(programId))).go();
      await _writeDays(programId, plan.days);
    });
    return programId;
  }

  Future<int> copyProgram(int programId) async {
    final p = await getProgram(programId);
    final plan = p!.toPlan();
    return saveProgram(
      ProgramPlan(name: '${plan.name} 복사본', split: plan.split, days: plan.days, rationale: plan.rationale),
      source: 'user',
      activate: false,
      basedOn: programId,
    );
  }

  Future<void> activateProgram(int id) async {
    await db.transaction(() async {
      await db.update(db.workoutPrograms).write(const WorkoutProgramsCompanion(isActive: Value(false)));
      await (db.update(db.workoutPrograms)..where((t) => t.id.equals(id))).write(const WorkoutProgramsCompanion(isActive: Value(true)));
    });
  }

  Future<void> deleteProgram(int id) async {
    await (db.delete(db.workoutPrograms)..where((t) => t.id.equals(id))).go();
  }

  Future<List<WorkoutProgram>> listPrograms() =>
      (db.select(db.workoutPrograms)..orderBy([(t) => OrderingTerm.desc(t.createdAt), (t) => OrderingTerm.desc(t.id)])).get();

  Future<ProgramView?> getProgram(int id) async {
    final row = await (db.select(db.workoutPrograms)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    final days =
        await (db.select(db.workoutDays)
              ..where((t) => t.programId.equals(id))
              ..orderBy([(t) => OrderingTerm(expression: t.dayIndex)]))
            .get();
    final out = <DayView>[];
    for (final d in days) {
      final xs =
          await (db.select(db.workoutExercises)
                ..where((t) => t.dayId.equals(d.id))
                ..orderBy([(t) => OrderingTerm(expression: t.orderIndex)]))
              .get();
      out.add(DayView(d, xs));
    }
    return ProgramView(row, out);
  }

  Future<ProgramView?> getActiveProgram() async {
    final row = await (db.select(db.workoutPrograms)..where((t) => t.isActive.equals(true))).getSingleOrNull();
    return row == null ? null : getProgram(row.id);
  }

  // ───────────────────────── 세션(운동 기록) ─────────────────────────

  Future<WorkoutSession?> lastCompletedSession({int? programId}) {
    final q = db.select(db.workoutSessions)
      ..where((t) => t.status.equals('completed') & (programId == null ? const Constant(true) : t.programId.equals(programId)))
      ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
      ..limit(1);
    return q.getSingleOrNull();
  }

  Future<int> nextDayIndex(ProgramView program) async {
    final last = await lastCompletedSession(programId: program.row.id);
    return const ScheduleEngine().nextDayIndex(dayCount: program.days.length, lastCompletedDayIndex: last?.dayIndex);
  }

  Future<WorkoutSession?> inProgressSession() =>
      (db.select(db.workoutSessions)
            ..where((t) => t.status.equals('in_progress'))
            ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
            ..limit(1))
          .getSingleOrNull();

  /// 운동별 수행 이력(완료된 세션, 최신순)
  Future<List<ExercisePerformance>> performanceHistory(String exerciseId, {int limit = 8, int? excludeSessionId}) async {
    final q = db.select(db.workoutSessionExercises).join([innerJoin(db.workoutSessions, db.workoutSessions.id.equalsExp(db.workoutSessionExercises.sessionId))])
      ..where(db.workoutSessionExercises.exerciseId.equals(exerciseId) & db.workoutSessions.status.equals('completed'))
      ..orderBy([OrderingTerm.desc(db.workoutSessions.startedAt)])
      ..limit(limit);
    final rows = await q.get();
    final out = <ExercisePerformance>[];
    for (final r in rows) {
      final se = r.readTable(db.workoutSessionExercises);
      final s = r.readTable(db.workoutSessions);
      if (s.id == excludeSessionId) continue;
      final sets =
          await (db.select(db.workoutSets)
                ..where((t) => t.sessionExerciseId.equals(se.id))
                ..orderBy([(t) => OrderingTerm(expression: t.setNumber)]))
              .get();
      out.add(_toPerformance(s, se, sets));
    }
    return out;
  }

  ExercisePerformance _toPerformance(WorkoutSession s, SessionExercise se, List<WorkoutSet> sets) => ExercisePerformance(
    date: s.startedAt,
    exerciseId: se.exerciseId,
    sets: [
      for (final x in sets) SetRecord(weight: x.actualWeight ?? 0, reps: x.actualReps ?? 0, rir: x.rir, completed: x.completed && (x.actualReps ?? 0) > 0),
    ],
    pain: se.pain,
    formUnstable: se.formUnstable,
    targetSets: se.targetSets,
    repMin: se.repMin,
    repMax: se.repMax,
  );

  Future<ProgressionRecommendation> recommendFor(
    Exercise ex, {
    required int sets,
    required int repMin,
    required int repMax,
    required int targetRir,
    double? startWeight,
    double? incrementOverride,
    Readiness readiness = Readiness.good,
    int? excludeSessionId,
    DateTime? now,
  }) async {
    final hist = await performanceHistory(ex.id, excludeSessionId: excludeSessionId);
    final profile = await getProfile();
    return progression.recommend(
      exercise: ex,
      targetSets: sets,
      repMin: repMin,
      repMax: repMax,
      targetRir: targetRir,
      history: hist,
      increment: await incrementFor(ex, override: incrementOverride),
      now: now ?? DateTime.now(),
      userStartWeight: startWeight,
      experience: profile?.experience ?? Experience.m6to12,
      readiness: readiness,
    );
  }

  /// 오늘의 운동 시작: 진행 엔진의 추천으로 세트를 미리 채워 저장합니다(앱이 종료돼도 유지).
  Future<int> startSession({required ProgramView program, required int dayIndex, RecoveryResult? recovery, int? recoveryLogId, DateTime? now}) async {
    final existing = await inProgressSession();
    if (existing != null) return existing.id;
    final day = program.days[dayIndex];
    final ts = now ?? DateTime.now();
    final readiness = recovery?.readiness ?? Readiness.good;
    final mult = recovery?.setMultiplier ?? 1.0;
    final rirOff = recovery?.rirOffset ?? 0;
    // 진행 추천은 트랜잭션 밖에서 계산(읽기 전용)
    final recs = <ProgressionRecommendation>[];
    for (final x in day.exercises) {
      final ex = _exercises[x.exerciseId]!;
      recs.add(
        await recommendFor(
          ex,
          sets: x.sets,
          repMin: x.repMin,
          repMax: x.repMax,
          targetRir: x.targetRir,
          startWeight: x.startWeight,
          incrementOverride: x.incrementKg,
          readiness: readiness,
          now: ts,
        ),
      );
    }
    return db.transaction(() async {
      final sid = await db
          .into(db.workoutSessions)
          .insert(
            WorkoutSessionsCompanion.insert(
              programId: Value(program.row.id),
              dayIndex: Value(dayIndex),
              dayName: day.row.name,
              startedAt: ts,
              status: 'in_progress',
              readinessScore: Value(recovery?.score),
              readiness: Value(recovery?.readiness.name),
            ),
          );
      if (recoveryLogId != null) {
        await (db.update(db.recoveryLogs)..where((t) => t.id.equals(recoveryLogId))).write(RecoveryLogsCompanion(sessionId: Value(sid)));
      }
      for (var i = 0; i < day.exercises.length; i++) {
        final x = day.exercises[i];
        final rec = recs[i];
        final sets = (rec.sets * mult).round().clamp(1, 10);
        final recId = await _insertRecommendation(rec, x.exerciseId, sid);
        final seId = await db
            .into(db.workoutSessionExercises)
            .insert(
              WorkoutSessionExercisesCompanion.insert(
                sessionId: sid,
                workoutExerciseId: Value(x.id),
                exerciseId: x.exerciseId,
                orderIndex: i,
                targetSets: sets,
                repMin: x.repMin,
                repMax: x.repMax,
                targetRir: (x.targetRir + rirOff).clamp(0, 5),
                restSec: x.restSec,
                recommendationId: Value(recId),
              ),
            );
        for (var n = 0; n < sets; n++) {
          final reps = n < rec.targetReps.length ? rec.targetReps[n] : rec.targetReps.last;
          await db
              .into(db.workoutSets)
              .insert(
                WorkoutSetsCompanion.insert(
                  sessionId: sid,
                  sessionExerciseId: seId,
                  exerciseId: x.exerciseId,
                  setNumber: n + 1,
                  targetWeight: Value(rec.weight),
                  actualWeight: Value(rec.weight),
                  targetReps: Value(reps),
                  actualReps: Value(reps),
                ),
              );
        }
      }
      return sid;
    });
  }

  Future<int> _insertRecommendation(ProgressionRecommendation rec, String exerciseId, int? sessionId) => db
      .into(db.progressionRecommendations)
      .insert(
        ProgressionRecommendationsCompanion.insert(
          userId: localUserId,
          exerciseId: exerciseId,
          sessionId: Value(sessionId),
          previousWeight: Value(rec.previousWeight),
          recommendedWeight: Value(rec.weight),
          recommendedReps: rec.targetReps.join(','),
          recommendedSets: rec.sets,
          action: rec.action.name,
          reason: jsonEncode(rec.reasons),
          confidenceLevel: rec.confidence.name,
        ),
      );

  ProgressionRecommendation _recFromRow(ProgressionRecommendationRow r) => ProgressionRecommendation(
    action: ProgressionAction.values.byName(r.action),
    weight: r.recommendedWeight,
    previousWeight: r.previousWeight,
    sets: r.recommendedSets,
    targetReps: r.recommendedReps.split(',').where((s) => s.isNotEmpty).map(int.parse).toList(),
    reasons: (jsonDecode(r.reason) as List).cast<String>(),
    confidence: Confidence.values.byName(r.confidenceLevel),
  );

  Future<SessionView?> getSession(int id) async {
    final s = await (db.select(db.workoutSessions)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (s == null) return null;
    final ses =
        await (db.select(db.workoutSessionExercises)
              ..where((t) => t.sessionId.equals(id))
              ..orderBy([(t) => OrderingTerm(expression: t.orderIndex)]))
            .get();
    final sets =
        await (db.select(db.workoutSets)
              ..where((t) => t.sessionId.equals(id))
              ..orderBy([(t) => OrderingTerm(expression: t.setNumber)]))
            .get();
    final recIds = ses.map((e) => e.recommendationId).whereType<int>().toList();
    final recs = recIds.isEmpty ? <ProgressionRecommendationRow>[] : await (db.select(db.progressionRecommendations)..where((t) => t.id.isIn(recIds))).get();
    final recById = {for (final r in recs) r.id: r};
    return SessionView(s, [
      for (final se in ses)
        SessionExerciseView(
          se,
          _exercises[se.exerciseId] ?? exerciseById[se.exerciseId]!,
          sets.where((x) => x.sessionExerciseId == se.id).toList(),
          se.recommendationId != null && recById[se.recommendationId] != null ? _recFromRow(recById[se.recommendationId]!) : null,
        ),
    ]);
  }

  /// 세트 값 수정. 중량을 바꾸면 같은 운동의 **뒤 세트 중 아직 완료하지 않은 세트**에도 같은 중량을 채웁니다.
  /// 단, 뒤 세트에 따로 다른 중량을 넣어 둔 경우(예: 드롭 세트)는 건드리지 않습니다
  /// (비어 있거나 이 세트의 이전 중량과 같던 세트만 따라 바뀜).
  Future<void> updateSet(int setId, {double? weight, int? reps, int? rir, bool clearRir = false}) async {
    await db.transaction(() async {
      final before = weight == null ? null : await (db.select(db.workoutSets)..where((t) => t.id.equals(setId))).getSingleOrNull();
      await (db.update(db.workoutSets)..where((t) => t.id.equals(setId))).write(
        WorkoutSetsCompanion(
          actualWeight: weight == null ? const Value.absent() : Value(weight),
          actualReps: reps == null ? const Value.absent() : Value(reps),
          rir: clearRir ? const Value(null) : (rir == null ? const Value.absent() : Value(rir)),
        ),
      );
      if (before == null || before.completed) return;
      final old = before.actualWeight;
      await (db.update(db.workoutSets)..where(
            (t) =>
                t.sessionExerciseId.equals(before.sessionExerciseId) &
                t.setNumber.isBiggerThanValue(before.setNumber) &
                t.completed.equals(false) &
                (old == null ? t.actualWeight.isNull() : (t.actualWeight.isNull() | t.actualWeight.equals(old))),
          ))
          .write(WorkoutSetsCompanion(actualWeight: Value(weight)));
    });
  }

  /// 세트 완료 토글. 같은 세트를 여러 번 눌러도 행은 하나만 유지됩니다.
  /// 완료로 바꿀 때는 이 세트의 중량을 같은 운동의 **뒤쪽 미완료 세트 전부**에 그대로 채웁니다.
  Future<void> setCompleted(int setId, bool completed) async {
    await db.transaction(() async {
      await (db.update(
        db.workoutSets,
      )..where((t) => t.id.equals(setId))).write(WorkoutSetsCompanion(completed: Value(completed), completedAt: Value(completed ? DateTime.now() : null)));
      if (!completed) return;
      final s = await (db.select(db.workoutSets)..where((t) => t.id.equals(setId))).getSingleOrNull();
      if (s == null || s.actualWeight == null) return;
      await (db.update(db.workoutSets)..where(
            (t) => t.sessionExerciseId.equals(s.sessionExerciseId) & t.setNumber.isBiggerThanValue(s.setNumber) & t.completed.equals(false),
          ))
          .write(WorkoutSetsCompanion(actualWeight: Value(s.actualWeight)));
    });
  }

  Future<void> addSet(int sessionExerciseId) async {
    final sets =
        await (db.select(db.workoutSets)
              ..where((t) => t.sessionExerciseId.equals(sessionExerciseId))
              ..orderBy([(t) => OrderingTerm.desc(t.setNumber)]))
            .get();
    final se = await (db.select(db.workoutSessionExercises)..where((t) => t.id.equals(sessionExerciseId))).getSingle();
    final last = sets.firstOrNull;
    await db
        .into(db.workoutSets)
        .insert(
          WorkoutSetsCompanion.insert(
            sessionId: se.sessionId,
            sessionExerciseId: sessionExerciseId,
            exerciseId: se.exerciseId,
            setNumber: (last?.setNumber ?? 0) + 1,
            targetWeight: Value(last?.targetWeight),
            actualWeight: Value(last?.actualWeight),
            targetReps: Value(last?.targetReps ?? se.repMin),
            actualReps: Value(last?.actualReps ?? se.repMin),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> removeLastSet(int sessionExerciseId) async {
    final last =
        await (db.select(db.workoutSets)
              ..where((t) => t.sessionExerciseId.equals(sessionExerciseId))
              ..orderBy([(t) => OrderingTerm.desc(t.setNumber)])
              ..limit(1))
            .getSingleOrNull();
    if (last != null) await (db.delete(db.workoutSets)..where((t) => t.id.equals(last.id))).go();
  }

  Future<void> setFlags(int sessionExerciseId, {bool? pain, bool? formUnstable}) async {
    await (db.update(db.workoutSessionExercises)..where((t) => t.id.equals(sessionExerciseId))).write(
      WorkoutSessionExercisesCompanion(
        pain: pain == null ? const Value.absent() : Value(pain),
        formUnstable: formUnstable == null ? const Value.absent() : Value(formUnstable),
      ),
    );
  }

  /// 운동 중 대체: 기존 중량을 그대로 쓰지 않고 새 운동의 기록(없으면 기준 중량 찾기)으로 다시 추천합니다.
  Future<void> substitute(int sessionExerciseId, String newExerciseId) async {
    final se = await (db.select(db.workoutSessionExercises)..where((t) => t.id.equals(sessionExerciseId))).getSingle();
    final ex = _exercises[newExerciseId]!;
    final repMin = ex.timed ? ex.repMin : se.repMin;
    final repMax = ex.timed ? ex.repMax : se.repMax;
    final rec = await recommendFor(ex, sets: se.targetSets, repMin: repMin, repMax: repMax, targetRir: se.targetRir);
    await db.transaction(() async {
      final recId = await _insertRecommendation(rec, ex.id, se.sessionId);
      await (db.update(db.workoutSessionExercises)..where((t) => t.id.equals(se.id))).write(
        WorkoutSessionExercisesCompanion(
          exerciseId: Value(ex.id),
          substitutedFrom: Value(se.substitutedFrom ?? se.exerciseId),
          repMin: Value(repMin),
          repMax: Value(repMax),
          restSec: Value(ex.restSec),
          recommendationId: Value(recId),
          pain: const Value(false),
          formUnstable: const Value(false),
        ),
      );
      // 완료된 세트는 원래 운동 기록이므로 제거하고 새 운동 세트로 다시 채움
      await (db.delete(db.workoutSets)..where((t) => t.sessionExerciseId.equals(se.id))).go();
      for (var n = 0; n < se.targetSets; n++) {
        final reps = n < rec.targetReps.length ? rec.targetReps[n] : rec.targetReps.last;
        await db
            .into(db.workoutSets)
            .insert(
              WorkoutSetsCompanion.insert(
                sessionId: se.sessionId,
                sessionExerciseId: se.id,
                exerciseId: ex.id,
                setNumber: n + 1,
                targetWeight: Value(rec.weight),
                actualWeight: Value(rec.weight),
                targetReps: Value(reps),
                actualReps: Value(reps),
              ),
            );
      }
    });
  }

  Future<void> finishSession(int sessionId, {DateTime? at}) async {
    final s = await getSession(sessionId);
    if (s == null) return;
    await db.transaction(() async {
      await (db.update(
        db.workoutSessions,
      )..where((t) => t.id.equals(sessionId))).write(WorkoutSessionsCompanion(status: const Value('completed'), finishedAt: Value(at ?? DateTime.now())));
      for (final e in s.exercises) {
        final recId = e.row.recommendationId;
        if (recId == null || e.recommendation?.weight == null) continue;
        final done = e.sets.where((x) => x.completed).toList();
        if (done.isEmpty) continue;
        final w = done.map((x) => x.actualWeight ?? 0).reduce((a, b) => a > b ? a : b);
        await (db.update(
          db.progressionRecommendations,
        )..where((t) => t.id.equals(recId))).write(ProgressionRecommendationsCompanion(accepted: Value(w == e.recommendation!.weight)));
      }
    });
  }

  Future<void> abandonSession(int sessionId) async {
    await (db.delete(db.workoutSessions)..where((t) => t.id.equals(sessionId))).go();
  }

  Future<List<SessionView>> completedSessions({DateTime? since, int? limit}) async {
    final q = db.select(db.workoutSessions)
      ..where((t) => t.status.equals('completed') & (since == null ? const Constant(true) : t.startedAt.isBiggerOrEqualValue(since)))
      ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]);
    if (limit != null) q.limit(limit);
    final rows = await q.get();
    return [for (final r in rows) (await getSession(r.id))!];
  }

  Future<void> deleteSession(int id) => (db.delete(db.workoutSessions)..where((t) => t.id.equals(id))).go();

  // ───────────────────────── 회복 / 신체 ─────────────────────────

  Future<int> saveRecovery(RecoveryInput i, RecoveryResult r, {DateTime? at}) => db
      .into(db.recoveryLogs)
      .insert(
        RecoveryLogsCompanion.insert(
          date: at ?? DateTime.now(),
          sleepHours: i.sleepHours,
          fatigue: i.fatigue,
          soreness: i.soreness,
          motivation: i.motivation,
          jointPain: i.jointPain,
          painArea: Value(i.painArea?.name),
          score: r.score,
          readiness: r.readiness.name,
        ),
      );

  Future<List<RecoveryLog>> recoveryLogs({DateTime? since}) =>
      (db.select(db.recoveryLogs)
            ..where((t) => since == null ? const Constant(true) : t.date.isBiggerOrEqualValue(since))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .get();

  Future<void> addMeasurement({required DateTime date, double? weight, double? bodyFat, double? smm, double? waist, String notes = ''}) async {
    await db
        .into(db.bodyMeasurements)
        .insert(
          BodyMeasurementsCompanion.insert(
            date: date,
            weightKg: Value(weight),
            bodyFatPct: Value(bodyFat),
            skeletalMuscleKg: Value(smm),
            waistCm: Value(waist),
            notes: Value(notes),
          ),
        );
  }

  Future<List<BodyMeasurement>> measurements() => (db.select(db.bodyMeasurements)..orderBy([(t) => OrderingTerm(expression: t.date)])).get();

  Future<void> deleteMeasurement(int id) => (db.delete(db.bodyMeasurements)..where((t) => t.id.equals(id))).go();

  // ───────────────────────── AI 관련 ─────────────────────────

  Future<List<ChatMessage>> chatHistory({int limit = 100}) async {
    final rows =
        await (db.select(db.chatMessages)
              ..orderBy([(t) => OrderingTerm.desc(t.id)])
              ..limit(limit))
            .get();
    return rows.reversed.toList();
  }

  Future<int> addChat(String role, String content, {String? provider, int? recommendationId}) => db
      .into(db.chatMessages)
      .insert(ChatMessagesCompanion.insert(role: role, content: content, provider: Value(provider), recommendationId: Value(recommendationId)));

  Future<void> clearChat() => db.delete(db.chatMessages).go();

  Future<int> addAiRecommendation({required String kind, required String title, required String body, required Map<String, dynamic> payload}) =>
      db.into(db.aiRecommendations).insert(AiRecommendationsCompanion.insert(kind: kind, title: title, body: body, payload: jsonEncode(payload)));

  Future<AiRecommendation?> aiRecommendation(int id) => (db.select(db.aiRecommendations)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> setAiRecommendationStatus(int id, String status) =>
      (db.update(db.aiRecommendations)..where((t) => t.id.equals(id))).write(AiRecommendationsCompanion(status: Value(status)));

  Future<void> logAiUsage(String provider, String model, int inTok, int outTok) =>
      db.into(db.aiUsageLogs).insert(AiUsageLogsCompanion.insert(provider: provider, model: model, inputTokens: Value(inTok), outputTokens: Value(outTok)));

  Future<int> aiRequestsToday() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    return (db.select(db.aiUsageLogs)..where((t) => t.createdAt.isBiggerOrEqualValue(start))).get().then((r) => r.length);
  }

  Future<List<ResearchReference>> researchLibrary() async {
    final rows = await (db.select(db.researchReferences)..orderBy([(t) => OrderingTerm.desc(t.year)])).get();
    return [
      for (final r in rows)
        ResearchReference(
          id: r.id,
          title: r.title,
          authors: r.authors,
          year: r.year,
          journal: r.journal,
          studyType: r.studyType,
          population: r.population,
          keyFindings: r.keyFindings,
          limitations: r.limitations,
          appliedIn: r.appliedIn,
        ),
    ];
  }

  // ───────────────────────── 내보내기 / 삭제 ─────────────────────────

  Future<Map<String, dynamic>> exportAll() async {
    Future<List<Map<String, dynamic>>> dump<T extends Table, D extends DataClass>(TableInfo<T, D> t) async =>
        (await db.select(t).get()).map((r) => r.toJson()).toList();
    final settings = await db.select(db.appSettings).get();
    return {
      'app': 'AI GYM LAB',
      'exportedAt': DateTime.now().toIso8601String(),
      'schemaVersion': db.schemaVersion,
      'user_profiles': await dump(db.userProfiles),
      'user_goals': await dump(db.userGoals),
      'user_equipment': await dump(db.userEquipment),
      'user_limitations': await dump(db.userLimitations),
      'workout_programs': await dump(db.workoutPrograms),
      'workout_days': await dump(db.workoutDays),
      'workout_exercises': await dump(db.workoutExercises),
      'workout_sessions': await dump(db.workoutSessions),
      'workout_session_exercises': await dump(db.workoutSessionExercises),
      'workout_sets': await dump(db.workoutSets),
      'body_measurements': await dump(db.bodyMeasurements),
      'recovery_logs': await dump(db.recoveryLogs),
      'progression_recommendations': await dump(db.progressionRecommendations),
      'ai_recommendations': await dump(db.aiRecommendations),
      'chat_messages': await dump(db.chatMessages),
      // API 키 등 비밀 값은 내보내지 않음
      'app_settings': [
        for (final s in settings)
          if (!s.key.contains('apiKey')) s.toJson(),
      ],
    };
  }

  /// [exportAll]로 내보낸 JSON을 다시 불러옵니다(다른 기기·재설치 후 기록 옮기기).
  /// 현재 기기의 개인 데이터는 모두 지우고 내보낸 내용으로 바꿉니다. 전부 성공하거나 전부 취소됩니다.
  /// 이 기기 운동 목록에 없는 운동을 가리키는 기록은 건너뛰고 [ImportResult.skipped]에 셉니다.
  Future<ImportResult> importAll(Map<String, dynamic> data) async {
    if (data['app'] != 'AI GYM LAB' || data['user_profiles'] is! List) {
      throw const FormatException('AI GYM LAB에서 내보낸 데이터가 아닙니다.');
    }
    final schema = data['schemaVersion'];
    if (schema is int && schema > db.schemaVersion) {
      throw const FormatException('더 새로운 버전의 앱에서 내보낸 데이터입니다. 앱을 먼저 업데이트하세요.');
    }
    List<Map<String, dynamic>> rows(String key) => [
      for (final r in (data[key] as List?) ?? const []) Map<String, dynamic>.from(r as Map),
    ];
    final known = {for (final r in await db.select(db.exercises).get()) r.id};
    var skipped = 0;
    late int sessions, sets;

    await db.transaction(() async {
      await deleteAllUserData();
      await _ensureUser();
      Future<void> put<T extends Table, D extends DataClass>(TableInfo<T, D> t, Iterable<Insertable<D>> items) async {
        for (final i in items) {
          await db.into(t).insert(i, mode: InsertMode.insertOrReplace);
        }
      }

      final userIds = {
        for (final k in ['user_profiles', 'user_goals', 'user_equipment', 'user_limitations', 'workout_programs'])
          for (final r in rows(k))
            if (r['userId'] is int) r['userId'] as int,
      };
      await put(db.users, [for (final id in userIds) UsersCompanion.insert(id: Value(id))]);
      await put(db.userProfiles, rows('user_profiles').map(UserProfileRow.fromJson));
      await put(db.userGoals, rows('user_goals').map(UserGoal.fromJson));
      await put(db.userEquipment, rows('user_equipment').map(UserEquipmentData.fromJson));
      await put(db.userLimitations, rows('user_limitations').map(UserLimitation.fromJson));
      await put(db.workoutPrograms, rows('workout_programs').map(WorkoutProgram.fromJson));
      await put(db.workoutDays, rows('workout_days').map(WorkoutDay.fromJson));

      final wex = rows('workout_exercises').map(WorkoutExercise.fromJson).toList();
      skipped += wex.where((e) => !known.contains(e.exerciseId)).length;
      await put(db.workoutExercises, wex.where((e) => known.contains(e.exerciseId)));

      final ses = rows('workout_sessions').map(WorkoutSession.fromJson).toList();
      sessions = ses.length;
      await put(db.workoutSessions, ses);

      final sex = rows('workout_session_exercises').map(SessionExercise.fromJson).toList();
      final keptSex = {for (final e in sex) if (known.contains(e.exerciseId)) e.id};
      skipped += sex.length - keptSex.length;
      await put(db.workoutSessionExercises, sex.where((e) => keptSex.contains(e.id)));

      final st = rows('workout_sets').map(WorkoutSet.fromJson).toList();
      final keptSets = st.where((s) => keptSex.contains(s.sessionExerciseId)).toList();
      skipped += st.length - keptSets.length;
      sets = keptSets.length;
      await put(db.workoutSets, keptSets);

      await put(db.bodyMeasurements, rows('body_measurements').map(BodyMeasurement.fromJson));
      await put(db.recoveryLogs, rows('recovery_logs').map(RecoveryLog.fromJson));
      await put(db.progressionRecommendations, rows('progression_recommendations').map(ProgressionRecommendationRow.fromJson));
      await put(db.aiRecommendations, rows('ai_recommendations').map(AiRecommendation.fromJson));
      await put(db.chatMessages, rows('chat_messages').map(ChatMessage.fromJson));
      // 운동 목록 버전(seed.version)은 이 기기 값을 유지
      await put(db.appSettings, rows('app_settings').map(AppSetting.fromJson).where((s) => s.key != 'seed.version' && !s.key.contains('apiKey')));
    });
    return ImportResult(sessions: sessions, sets: sets, skipped: skipped);
  }

  Future<void> deleteAllUserData() async {
    await db.transaction(() async {
      for (final TableInfo t in <TableInfo>[
        db.workoutSets,
        db.workoutSessionExercises,
        db.workoutSessions,
        db.workoutExercises,
        db.workoutDays,
        db.workoutPrograms,
        db.progressionRecommendations,
        db.aiRecommendations,
        db.chatMessages,
        db.aiUsageLogs,
        db.bodyMeasurements,
        db.recoveryLogs,
        db.userLimitations,
        db.userEquipment,
        db.userGoals,
        db.userProfiles,
      ]) {
        await db.delete(t).go();
      }
      await (db.delete(db.appSettings)..where((t) => t.key.equals('seed.version').not())).go();
    });
  }
}

class ImportResult {
  final int sessions;
  final int sets;
  final int skipped;
  const ImportResult({required this.sessions, required this.sets, required this.skipped});
}
