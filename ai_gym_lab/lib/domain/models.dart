// AI GYM LAB — 도메인 모델 (순수 Dart, Flutter/DB 의존성 없음)
//
// 비즈니스 로직(엔진)은 이 파일의 타입만 사용하며, 데이터베이스 계층은
// repository에서 이 타입으로 변환합니다. 덕분에 엔진을 독립적으로 테스트할 수 있습니다.

enum Sex { male, female, other }

extension SexKo on Sex {
  String get ko => const {Sex.male: '남성', Sex.female: '여성', Sex.other: '기타/응답 안 함'}[this]!;
}

enum Goal { hypertrophy, strength, fatLoss, weightLoss, fitness, health, posture }

extension GoalKo on Goal {
  String get ko => const {
    Goal.hypertrophy: '근육량 증가',
    Goal.strength: '최대근력 향상',
    Goal.fatLoss: '체지방 감소',
    Goal.weightLoss: '체중 감량',
    Goal.fitness: '체력 향상',
    Goal.health: '건강 유지',
    Goal.posture: '자세 및 신체 균형 개선',
  }[this]!;
}

enum Experience { none, under3m, m3to6, m6to12, y1to3, y3plus }

extension ExperienceX on Experience {
  String get ko => const {
    Experience.none: '완전 초보',
    Experience.under3m: '3개월 미만',
    Experience.m3to6: '3~6개월',
    Experience.m6to12: '6개월~1년',
    Experience.y1to3: '1~3년',
    Experience.y3plus: '3년 이상',
  }[this]!;

  /// 초보자 판정(완전 초보 ~ 3개월 미만)
  bool get isNovice => index <= Experience.under3m.index;

  /// 운동 선택 시 허용할 최대 난이도(1~3)
  int get maxDifficulty => switch (this) {
    Experience.none || Experience.under3m => 1,
    Experience.m3to6 || Experience.m6to12 => 2,
    _ => 3,
  };
}

enum GymEnvironment { fullGym, standardGym, smallGym, home }

extension GymEnvironmentX on GymEnvironment {
  String get ko => const {
    GymEnvironment.fullGym: '모든 기구가 있는 헬스장',
    GymEnvironment.standardGym: '일반 헬스장',
    GymEnvironment.smallGym: '소규모 헬스장',
    GymEnvironment.home: '홈트레이닝',
  }[this]!;

  /// 환경별 기본 사용 가능 기구 (사용자가 직접 수정 가능)
  Set<Equipment> get defaultEquipment => switch (this) {
    GymEnvironment.fullGym => Equipment.values.toSet(),
    GymEnvironment.standardGym => Equipment.values.toSet()..removeAll({Equipment.specialtyMachine}),
    GymEnvironment.smallGym => {
      Equipment.barbell,
      Equipment.dumbbell,
      Equipment.bench,
      Equipment.cable,
      Equipment.pullupBar,
      Equipment.bodyweight,
      Equipment.smith,
      Equipment.machine,
      Equipment.ezBar,
    },
    GymEnvironment.home => {Equipment.dumbbell, Equipment.bodyweight, Equipment.band, Equipment.pullupBar, Equipment.bench},
  };
}

enum Equipment {
  barbell,
  dumbbell,
  machine,
  cable,
  smith,
  bench,
  pullupBar,
  dipStation,
  bodyweight,
  kettlebell,
  band,
  ezBar,
  legPress,
  hackSquat,
  specialtyMachine,
}

extension EquipmentX on Equipment {
  String get ko => const {
    Equipment.barbell: '바벨',
    Equipment.dumbbell: '덤벨',
    Equipment.machine: '머신(일반)',
    Equipment.cable: '케이블',
    Equipment.smith: '스미스머신',
    Equipment.bench: '벤치',
    Equipment.pullupBar: '풀업바',
    Equipment.dipStation: '딥스대',
    Equipment.bodyweight: '맨몸',
    Equipment.kettlebell: '케틀벨',
    Equipment.band: '밴드',
    Equipment.ezBar: 'EZ바',
    Equipment.legPress: '레그프레스 머신',
    Equipment.hackSquat: '핵스쿼트 머신',
    Equipment.specialtyMachine: '특수 머신(펜듈럼 등)',
  }[this]!;

  /// 기구별 기본 중량 증가 단위(kg). 개발자 실용 권장값이며 설정에서 변경 가능.
  double get defaultIncrementKg => switch (this) {
    Equipment.barbell || Equipment.smith || Equipment.ezBar => 2.5,
    Equipment.dumbbell => 2.0,
    Equipment.kettlebell => 4.0,
    Equipment.cable => 2.5,
    Equipment.machine || Equipment.legPress || Equipment.hackSquat || Equipment.specialtyMachine => 5.0,
    Equipment.bodyweight || Equipment.band || Equipment.pullupBar || Equipment.dipStation || Equipment.bench => 2.5,
  };
}

enum Muscle { chest, lats, upperBack, frontDelt, sideDelt, rearDelt, biceps, triceps, quads, hamstrings, glutes, calves, abs, lowerBack, forearms, adductors }

extension MuscleX on Muscle {
  String get ko => const {
    Muscle.chest: '가슴',
    Muscle.lats: '광배근',
    Muscle.upperBack: '등 상부',
    Muscle.frontDelt: '전면 삼각근',
    Muscle.sideDelt: '측면 삼각근',
    Muscle.rearDelt: '후면 삼각근',
    Muscle.biceps: '이두근',
    Muscle.triceps: '삼두근',
    Muscle.quads: '대퇴사두근',
    Muscle.hamstrings: '햄스트링',
    Muscle.glutes: '둔근',
    Muscle.calves: '종아리',
    Muscle.abs: '복근',
    Muscle.lowerBack: '척추기립근',
    Muscle.forearms: '전완',
    Muscle.adductors: '내전근',
  }[this]!;

  bool get isUpper => const {
    Muscle.chest,
    Muscle.lats,
    Muscle.upperBack,
    Muscle.frontDelt,
    Muscle.sideDelt,
    Muscle.rearDelt,
    Muscle.biceps,
    Muscle.triceps,
    Muscle.forearms,
  }.contains(this);
}

/// 주간 운동량 분석 대상(요구사항 9의 13개 근육)
const trackedMuscles = [
  Muscle.chest,
  Muscle.lats,
  Muscle.upperBack,
  Muscle.frontDelt,
  Muscle.sideDelt,
  Muscle.rearDelt,
  Muscle.biceps,
  Muscle.triceps,
  Muscle.quads,
  Muscle.hamstrings,
  Muscle.glutes,
  Muscle.calves,
  Muscle.abs,
];

enum MovementPattern {
  horizontalPush,
  inclinePush,
  verticalPush,
  chestFly,
  horizontalPull,
  verticalPull,
  pullover,
  lateralRaise,
  rearDeltFly,
  shrug,
  elbowFlexion,
  elbowExtension,
  squat,
  lunge,
  legPress,
  kneeExtension,
  hinge,
  kneeFlexion,
  hipThrust,
  hipAbduction,
  hipAdduction,
  calfRaise,
  coreFlexion,
  coreAntiExtension,
  coreRotation,
  carry,
  wrist,
}

extension MovementPatternKo on MovementPattern {
  String get ko => const {
    MovementPattern.horizontalPush: '수평 밀기',
    MovementPattern.inclinePush: '인클라인 밀기',
    MovementPattern.verticalPush: '수직 밀기',
    MovementPattern.chestFly: '가슴 플라이',
    MovementPattern.horizontalPull: '수평 당기기',
    MovementPattern.verticalPull: '수직 당기기',
    MovementPattern.pullover: '풀오버',
    MovementPattern.lateralRaise: '측면 거상',
    MovementPattern.rearDeltFly: '후면 플라이',
    MovementPattern.shrug: '슈러그',
    MovementPattern.elbowFlexion: '팔꿈치 굴곡',
    MovementPattern.elbowExtension: '팔꿈치 신전',
    MovementPattern.squat: '스쿼트',
    MovementPattern.lunge: '런지/편측 하체',
    MovementPattern.legPress: '레그프레스',
    MovementPattern.kneeExtension: '무릎 신전',
    MovementPattern.hinge: '힙 힌지',
    MovementPattern.kneeFlexion: '무릎 굴곡',
    MovementPattern.hipThrust: '고관절 신전(쓰러스트)',
    MovementPattern.hipAbduction: '고관절 외전',
    MovementPattern.hipAdduction: '고관절 내전',
    MovementPattern.calfRaise: '발목 저측굴곡',
    MovementPattern.coreFlexion: '몸통 굴곡',
    MovementPattern.coreAntiExtension: '몸통 안정화',
    MovementPattern.coreRotation: '몸통 회전/항회전',
    MovementPattern.carry: '캐리',
    MovementPattern.wrist: '손목',
  }[this]!;
}

enum ExerciseType { compound, isolation }

/// 관절/부위 (통증 입력과 운동별 관절 부담 표시에 공통 사용)
enum JointArea { shoulder, lowBack, knee, wrist, elbow, other }

extension JointAreaKo on JointArea {
  String get ko => const {
    JointArea.shoulder: '어깨',
    JointArea.lowBack: '허리',
    JointArea.knee: '무릎',
    JointArea.wrist: '손목',
    JointArea.elbow: '팔꿈치',
    JointArea.other: '기타',
  }[this]!;
}

/// 운동 정의
class Exercise {
  final String id;
  final String nameKo;
  final String nameEn;
  final List<Muscle> primary;
  final List<Muscle> secondary;

  /// 수행에 필요한 기구(모두 있어야 함)
  final List<Equipment> equipment;
  final ExerciseType type;
  final MovementPattern pattern;

  /// 1=초급, 2=중급, 3=고급
  final int difficulty;
  final int repMin;
  final int repMax;
  final int restSec;
  final String description;
  final List<String> cues;
  final List<String> mistakes;
  final List<String> cautions;

  /// 관절 부담(0=낮음, 1=보통, 2=높음). 개발자 추정값이며 의학적 판정이 아님.
  final Map<JointArea, int> jointStress;

  /// 명시적 대체 운동 ID (대체 엔진이 점수로 보완)
  final List<String> alternatives;

  /// 보조(어시스트) 운동: 기록하는 중량이 보조 중량이므로 낮을수록 어려움
  final bool assisted;

  /// 맨몸 운동(외부 중량 0에서 시작 가능)
  final bool bodyweight;

  /// 시간 기반 운동(플랭크 등): '반복' 칸에 초 단위를 기록
  final bool timed;

  /// 관련 연구 ID
  final List<String> referenceIds;

  /// 저작권 확인된 영상 URL만 등록. 미확보 시 null.
  final String? videoUrl;
  final bool isCustom;

  const Exercise({
    required this.id,
    required this.nameKo,
    required this.nameEn,
    required this.primary,
    this.secondary = const [],
    required this.equipment,
    required this.type,
    required this.pattern,
    this.difficulty = 1,
    required this.repMin,
    required this.repMax,
    required this.restSec,
    this.description = '',
    this.cues = const [],
    this.mistakes = const [],
    this.cautions = const [],
    this.jointStress = const {},
    this.alternatives = const [],
    this.assisted = false,
    this.bodyweight = false,
    this.timed = false,
    this.referenceIds = const [],
    this.videoUrl,
    this.isCustom = false,
  });

  /// 중량 증가 단위 결정에 사용되는 대표 기구
  Equipment get primaryEquipment {
    const priority = [
      Equipment.barbell,
      Equipment.smith,
      Equipment.ezBar,
      Equipment.hackSquat,
      Equipment.legPress,
      Equipment.specialtyMachine,
      Equipment.machine,
      Equipment.cable,
      Equipment.dumbbell,
      Equipment.kettlebell,
      Equipment.band,
      Equipment.bodyweight,
    ];
    for (final e in priority) {
      if (equipment.contains(e)) return e;
    }
    return equipment.isEmpty ? Equipment.bodyweight : equipment.first;
  }

  int stressOn(JointArea a) => jointStress[a] ?? 0;
}

class Limitation {
  final JointArea area;

  /// 통증 강도 0~10
  final int severity;
  final String timing;
  final String notes;

  const Limitation({required this.area, this.severity = 3, this.timing = '', this.notes = ''});
}

class UserProfile {
  final Sex sex;
  final int age;
  final double heightCm;
  final double weightKg;
  final double? targetWeightKg;
  final double? bodyFatPct;
  final double? skeletalMuscleKg;

  /// 우선순위 순으로 정렬된 목표(첫 번째가 최우선)
  final List<Goal> goals;
  final Experience experience;
  final int daysPerWeek;
  final int sessionMinutes;
  final GymEnvironment environment;
  final Set<Equipment> equipment;
  final List<Limitation> limitations;

  const UserProfile({
    this.sex = Sex.other,
    this.age = 30,
    this.heightCm = 170,
    this.weightKg = 70,
    this.targetWeightKg,
    this.bodyFatPct,
    this.skeletalMuscleKg,
    this.goals = const [Goal.hypertrophy],
    this.experience = Experience.m6to12,
    this.daysPerWeek = 4,
    this.sessionMinutes = 60,
    this.environment = GymEnvironment.standardGym,
    this.equipment = const {},
    this.limitations = const [],
  });

  Goal get primaryGoal => goals.isEmpty ? Goal.health : goals.first;

  int? severityFor(JointArea a) {
    int? s;
    for (final l in limitations) {
      if (l.area == a) s = (s == null || l.severity > s) ? l.severity : s;
    }
    return s;
  }

  UserProfile copyWith({
    Sex? sex,
    int? age,
    double? heightCm,
    double? weightKg,
    double? targetWeightKg,
    double? bodyFatPct,
    double? skeletalMuscleKg,
    List<Goal>? goals,
    Experience? experience,
    int? daysPerWeek,
    int? sessionMinutes,
    GymEnvironment? environment,
    Set<Equipment>? equipment,
    List<Limitation>? limitations,
  }) => UserProfile(
    sex: sex ?? this.sex,
    age: age ?? this.age,
    heightCm: heightCm ?? this.heightCm,
    weightKg: weightKg ?? this.weightKg,
    targetWeightKg: targetWeightKg ?? this.targetWeightKg,
    bodyFatPct: bodyFatPct ?? this.bodyFatPct,
    skeletalMuscleKg: skeletalMuscleKg ?? this.skeletalMuscleKg,
    goals: goals ?? this.goals,
    experience: experience ?? this.experience,
    daysPerWeek: daysPerWeek ?? this.daysPerWeek,
    sessionMinutes: sessionMinutes ?? this.sessionMinutes,
    environment: environment ?? this.environment,
    equipment: equipment ?? this.equipment,
    limitations: limitations ?? this.limitations,
  );
}

enum SplitType { fullBody, upperLower, ppl, threeSplit, fourSplit, fiveSplit, upperLowerFull, custom }

extension SplitTypeKo on SplitType {
  String get ko => const {
    SplitType.fullBody: '전신운동(Full Body)',
    SplitType.upperLower: '상체·하체 2분할',
    SplitType.ppl: '밀기·당기기·하체(PPL)',
    SplitType.threeSplit: '3분할',
    SplitType.fourSplit: '4분할',
    SplitType.fiveSplit: '5분할',
    SplitType.upperLowerFull: '상체·하체 + 전신 조합',
    SplitType.custom: '사용자 직접 구성',
  }[this]!;
}

/// 근거 수준: 연구 근거 vs 개발자 실용 권장값을 명확히 구분
enum EvidenceKind { research, appDefault, userData }

extension EvidenceKindKo on EvidenceKind {
  String get ko => const {EvidenceKind.research: '연구 근거', EvidenceKind.appDefault: '앱 기본값(개발자 실용 권장값)', EvidenceKind.userData: '내 운동 기록'}[this]!;
}

class Rationale {
  final String text;
  final EvidenceKind kind;
  final List<String> referenceIds;
  const Rationale(this.text, this.kind, [this.referenceIds = const []]);

  Map<String, dynamic> toJson() => {'text': text, 'kind': kind.name, 'refs': referenceIds};
  factory Rationale.fromJson(Map<String, dynamic> j) =>
      Rationale(j['text'] as String, EvidenceKind.values.byName(j['kind'] as String), (j['refs'] as List?)?.cast<String>() ?? const []);
}

/// 프로그램 계획(생성 엔진 출력 / 편집기 입력)
class PlannedExercise {
  final String exerciseId;
  final int sets;
  final int repMin;
  final int repMax;
  final int targetRir;
  final int restSec;
  final double? startWeight;
  final String notes;

  const PlannedExercise({
    required this.exerciseId,
    required this.sets,
    required this.repMin,
    required this.repMax,
    this.targetRir = 2,
    required this.restSec,
    this.startWeight,
    this.notes = '',
  });

  PlannedExercise copyWith({String? exerciseId, int? sets, int? repMin, int? repMax, int? targetRir, int? restSec, double? startWeight, String? notes}) =>
      PlannedExercise(
        exerciseId: exerciseId ?? this.exerciseId,
        sets: sets ?? this.sets,
        repMin: repMin ?? this.repMin,
        repMax: repMax ?? this.repMax,
        targetRir: targetRir ?? this.targetRir,
        restSec: restSec ?? this.restSec,
        startWeight: startWeight ?? this.startWeight,
        notes: notes ?? this.notes,
      );
}

class PlannedDay {
  final String name;

  /// 선호 요일(1=월 ~ 7=일). 실제 진행은 순환 방식(건너뛰어도 순서 유지)
  final int weekday;
  final List<PlannedExercise> exercises;
  const PlannedDay({required this.name, required this.weekday, required this.exercises});

  PlannedDay copyWith({String? name, int? weekday, List<PlannedExercise>? exercises}) =>
      PlannedDay(name: name ?? this.name, weekday: weekday ?? this.weekday, exercises: exercises ?? this.exercises);
}

class ProgramPlan {
  final String name;
  final SplitType split;
  final List<PlannedDay> days;
  final List<Rationale> rationale;
  const ProgramPlan({required this.name, required this.split, required this.days, this.rationale = const []});
}

/// 기록된 세트 (엔진 입력용)
class SetRecord {
  final double weight;
  final int reps;
  final int? rir;
  final bool completed;
  const SetRecord({required this.weight, required this.reps, this.rir, this.completed = true});
}

/// 한 세션에서 특정 운동의 수행 결과
class ExercisePerformance {
  final DateTime date;
  final String exerciseId;
  final List<SetRecord> sets;
  final bool pain;
  final bool formUnstable;
  final int targetSets;
  final int repMin;
  final int repMax;

  const ExercisePerformance({
    required this.date,
    required this.exerciseId,
    required this.sets,
    this.pain = false,
    this.formUnstable = false,
    required this.targetSets,
    required this.repMin,
    required this.repMax,
  });

  List<SetRecord> get completedSets => sets.where((s) => s.completed).toList();

  /// 대표 작업 중량(완료 세트의 최빈 최대값)
  double get workingWeight {
    final c = completedSets;
    if (c.isEmpty) return 0;
    return c.map((s) => s.weight).reduce((a, b) => a > b ? a : b);
  }
}
