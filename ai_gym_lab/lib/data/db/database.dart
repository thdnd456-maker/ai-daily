// SQLite(Drift) 스키마
//
// 비즈니스 로직은 domain/ 에 있으며, 이 파일은 저장 구조만 정의합니다.
// 단일 사용자 로컬 앱이지만 user_id를 유지해 향후 계정/클라우드 동기화를 쉽게 추가할 수 있게 했습니다.
import 'package:drift/drift.dart';

part 'database.g.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('UserProfileRow')
class UserProfiles extends Table {
  IntColumn get userId => integer().references(Users, #id)();
  TextColumn get sex => text()();
  IntColumn get age => integer()();
  RealColumn get heightCm => real()();
  RealColumn get weightKg => real()();
  RealColumn get targetWeightKg => real().nullable()();
  RealColumn get bodyFatPct => real().nullable()();
  RealColumn get skeletalMuscleKg => real().nullable()();
  TextColumn get experience => text()();
  IntColumn get daysPerWeek => integer()();
  IntColumn get sessionMinutes => integer()();
  TextColumn get environment => text()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {userId};
}

class UserGoals extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  TextColumn get goal => text()();
  IntColumn get priority => integer()();
}

class UserEquipment extends Table {
  IntColumn get userId => integer().references(Users, #id)();
  TextColumn get equipment => text()();
  @override
  Set<Column> get primaryKey => {userId, equipment};
}

class UserLimitations extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  TextColumn get area => text()();
  IntColumn get severity => integer()();
  TextColumn get timing => text().withDefault(const Constant(''))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
}

@DataClassName('ExerciseRow')
class Exercises extends Table {
  TextColumn get id => text()();
  TextColumn get nameKo => text()();
  TextColumn get nameEn => text()();
  TextColumn get equipment => text()(); // 쉼표 구분
  TextColumn get type => text()();
  TextColumn get pattern => text()();
  IntColumn get difficulty => integer()();
  IntColumn get repMin => integer()();
  IntColumn get repMax => integer()();
  IntColumn get restSec => integer()();
  TextColumn get description => text()();
  TextColumn get cues => text()(); // JSON 배열
  TextColumn get mistakes => text()();
  TextColumn get cautions => text()();
  TextColumn get jointStress => text()(); // JSON 객체
  TextColumn get referenceIds => text()();
  TextColumn get videoUrl => text().nullable()();
  BoolColumn get assisted => boolean().withDefault(const Constant(false))();
  BoolColumn get bodyweight => boolean().withDefault(const Constant(false))();
  BoolColumn get timed => boolean().withDefault(const Constant(false))();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {id};
}

class ExerciseMuscles extends Table {
  TextColumn get exerciseId => text().references(Exercises, #id)();
  TextColumn get muscle => text()();
  TextColumn get role => text()(); // primary | secondary
  @override
  Set<Column> get primaryKey => {exerciseId, muscle, role};
}

class ExerciseAlternatives extends Table {
  TextColumn get exerciseId => text().references(Exercises, #id)();
  @ReferenceName('alternativeOf')
  TextColumn get alternativeId => text().references(Exercises, #id)();
  IntColumn get rank => integer()();
  @override
  Set<Column> get primaryKey => {exerciseId, alternativeId};
}

class WorkoutPrograms extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  TextColumn get name => text()();
  TextColumn get split => text()();
  TextColumn get source => text()(); // ai | user
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();
  IntColumn get basedOnProgramId => integer().nullable()();
  TextColumn get rationale => text().withDefault(const Constant('[]'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class WorkoutDays extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get programId => integer().references(WorkoutPrograms, #id, onDelete: KeyAction.cascade)();
  IntColumn get dayIndex => integer()();
  IntColumn get weekday => integer()();
  TextColumn get name => text()();
}

class WorkoutExercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get dayId => integer().references(WorkoutDays, #id, onDelete: KeyAction.cascade)();
  TextColumn get exerciseId => text().references(Exercises, #id)();
  IntColumn get orderIndex => integer()();
  IntColumn get sets => integer()();
  IntColumn get repMin => integer()();
  IntColumn get repMax => integer()();
  IntColumn get targetRir => integer()();
  IntColumn get restSec => integer()();
  RealColumn get startWeight => real().nullable()();
  RealColumn get incrementKg => real().nullable()();
  TextColumn get notes => text().withDefault(const Constant(''))();
}

class WorkoutSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get programId => integer().nullable()();
  IntColumn get dayIndex => integer().nullable()();
  TextColumn get dayName => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  TextColumn get status => text()(); // in_progress | completed | abandoned
  IntColumn get readinessScore => integer().nullable()();
  TextColumn get readiness => text().nullable()();
  TextColumn get notes => text().withDefault(const Constant(''))();
}

@DataClassName('SessionExercise')
class WorkoutSessionExercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(WorkoutSessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get workoutExerciseId => integer().nullable()();
  TextColumn get exerciseId => text().references(Exercises, #id)();
  IntColumn get orderIndex => integer()();
  IntColumn get targetSets => integer()();
  IntColumn get repMin => integer()();
  IntColumn get repMax => integer()();
  IntColumn get targetRir => integer()();
  IntColumn get restSec => integer()();
  TextColumn get substitutedFrom => text().nullable()();
  BoolColumn get pain => boolean().withDefault(const Constant(false))();
  BoolColumn get formUnstable => boolean().withDefault(const Constant(false))();
  IntColumn get recommendationId => integer().nullable()();
}

@TableIndex(name: 'idx_sets_exercise', columns: {#exerciseId})
class WorkoutSets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(WorkoutSessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get sessionExerciseId => integer().references(WorkoutSessionExercises, #id, onDelete: KeyAction.cascade)();
  TextColumn get exerciseId => text()();
  IntColumn get setNumber => integer()();
  RealColumn get targetWeight => real().nullable()();
  RealColumn get actualWeight => real().nullable()();
  IntColumn get targetReps => integer().nullable()();
  IntColumn get actualReps => integer().nullable()();
  IntColumn get rir => integer().nullable()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  // 같은 운동의 같은 세트 번호는 한 번만 저장(중복 저장 방지)
  @override
  List<Set<Column>> get uniqueKeys => [
    {sessionExerciseId, setNumber},
  ];
}

class BodyMeasurements extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  RealColumn get weightKg => real().nullable()();
  RealColumn get bodyFatPct => real().nullable()();
  RealColumn get skeletalMuscleKg => real().nullable()();
  RealColumn get waistCm => real().nullable()();
  TextColumn get notes => text().withDefault(const Constant(''))();
}

/// 식사 기록 (식단 탭). 영양값은 기록할 때의 값(양 반영)을 그대로 저장합니다.
class MealLogs extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// 먹은 날 (자정 기준 날짜)
  DateTimeColumn get date => dateTime()();

  /// breakfast | lunch | dinner | snack
  TextColumn get meal => text()();
  TextColumn get name => text()();

  /// 예: '100g × 1.5'
  TextColumn get amount => text().withDefault(const Constant(''))();
  RealColumn get kcal => real()();
  RealColumn get proteinG => real().withDefault(const Constant(0))();
  RealColumn get carbsG => real().withDefault(const Constant(0))();
  RealColumn get fatG => real().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class RecoveryLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  RealColumn get sleepHours => real()();
  IntColumn get fatigue => integer()();
  IntColumn get soreness => integer()();
  IntColumn get motivation => integer()();
  BoolColumn get jointPain => boolean()();
  TextColumn get painArea => text().nullable()();
  IntColumn get score => integer()();
  TextColumn get readiness => text()();
  IntColumn get sessionId => integer().nullable()();
}

@DataClassName('ProgressionRecommendationRow')
class ProgressionRecommendations extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer()();
  TextColumn get exerciseId => text()();
  IntColumn get sessionId => integer().nullable()();
  RealColumn get previousWeight => real().nullable()();
  RealColumn get recommendedWeight => real().nullable()();
  TextColumn get recommendedReps => text()(); // "6,6,6"
  IntColumn get recommendedSets => integer()();
  TextColumn get action => text()();
  TextColumn get reason => text()(); // JSON 배열
  TextColumn get confidenceLevel => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get accepted => boolean().nullable()();
}

class AiRecommendations extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get kind => text()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  TextColumn get payload => text()(); // JSON
  TextColumn get status => text().withDefault(const Constant('pending'))(); // pending | accepted | rejected
}

@DataClassName('ResearchReferenceRow')
class ResearchReferences extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get authors => text()();
  IntColumn get year => integer()();
  TextColumn get journal => text()();
  TextColumn get studyType => text()();
  TextColumn get population => text()();
  TextColumn get keyFindings => text()();
  TextColumn get limitations => text()();
  TextColumn get appliedIn => text()();
  @override
  Set<Column> get primaryKey => {id};
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  @override
  Set<Column> get primaryKey => {key};
}

class ChatMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get role => text()(); // user | assistant
  TextColumn get content => text()();
  TextColumn get provider => text().nullable()();
  IntColumn get recommendationId => integer().nullable()();
}

class AiUsageLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get provider => text()();
  TextColumn get model => text()();
  IntColumn get inputTokens => integer().withDefault(const Constant(0))();
  IntColumn get outputTokens => integer().withDefault(const Constant(0))();
}

@DriftDatabase(
  tables: [
    Users,
    UserProfiles,
    UserGoals,
    UserEquipment,
    UserLimitations,
    Exercises,
    ExerciseMuscles,
    ExerciseAlternatives,
    WorkoutPrograms,
    WorkoutDays,
    WorkoutExercises,
    WorkoutSessions,
    WorkoutSessionExercises,
    WorkoutSets,
    BodyMeasurements,
    MealLogs,
    RecoveryLogs,
    ProgressionRecommendations,
    AiRecommendations,
    ResearchReferences,
    AppSettings,
    ChatMessages,
    AiUsageLogs,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // 2: 식사 기록 추가 (기존 기록은 그대로)
      if (from < 2) await m.createTable(mealLogs);
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
