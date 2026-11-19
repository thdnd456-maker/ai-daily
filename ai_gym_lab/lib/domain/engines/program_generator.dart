// 운동 프로그램 생성 엔진 (규칙 기반, AI 언어모델 미사용)
//
// 절차
// 1) 주당 운동일 + 경험으로 분할 방식 결정 (지속 가능성 우선)
// 2) 분할별 요일 템플릿 선택 (주 4일 = 요구사항의 기본 상체/하체 템플릿)
// 3) 기구·난이도·통증에 맞지 않는 운동은 대체 엔진으로 교체
// 4) 목표에 맞게 반복/휴식/RIR 조정
// 5) 근육별 주간 세트를 목표 범위로 조정
// 6) 1회 운동 시간에 맞게 세트/운동 수 조정
import '../models.dart';
import 'substitution_engine.dart';
import 'volume_engine.dart';

class _Slot {
  final String id;
  final int sets;
  final int repMin;
  final int repMax;
  const _Slot(this.id, this.sets, this.repMin, this.repMax);
}

// ── 요일 템플릿 ──
const _upperA = [
  _Slot('barbell_bench_press', 3, 6, 8),
  _Slot('lat_pulldown', 3, 8, 12),
  _Slot('incline_dumbbell_press', 3, 8, 12),
  _Slot('chest_supported_row', 3, 8, 12),
  _Slot('dumbbell_lateral_raise', 3, 12, 15),
  _Slot('cable_pushdown', 2, 10, 15),
  _Slot('dumbbell_curl', 2, 10, 15),
];
const _lowerA = [
  _Slot('hack_squat', 3, 6, 10),
  _Slot('leg_press', 3, 10, 12),
  _Slot('seated_leg_curl', 3, 10, 15),
  _Slot('leg_extension', 2, 12, 15),
  _Slot('standing_calf_raise', 3, 10, 15),
  _Slot('cable_crunch', 3, 12, 15),
];
const _upperB = [
  _Slot('assisted_pull_up', 3, 6, 10),
  _Slot('machine_chest_press', 3, 8, 12),
  _Slot('seated_cable_row', 3, 8, 12),
  _Slot('machine_shoulder_press', 2, 8, 12),
  _Slot('cable_fly', 2, 12, 15),
  _Slot('reverse_pec_deck', 3, 12, 15),
  _Slot('incline_dumbbell_curl', 2, 10, 15),
  _Slot('overhead_triceps_extension', 2, 10, 15),
];
const _lowerB = [
  _Slot('romanian_deadlift', 3, 6, 10),
  _Slot('hip_thrust', 3, 8, 12),
  _Slot('leg_press', 3, 10, 12),
  _Slot('lying_leg_curl', 3, 10, 15),
  _Slot('seated_calf_raise', 3, 12, 15),
  _Slot('hanging_knee_raise', 3, 10, 15),
];
const _fullA = [
  _Slot('hack_squat', 3, 6, 10),
  _Slot('barbell_bench_press', 3, 6, 8),
  _Slot('lat_pulldown', 3, 8, 12),
  _Slot('seated_leg_curl', 2, 10, 15),
  _Slot('dumbbell_lateral_raise', 2, 12, 15),
  _Slot('cable_pushdown', 2, 10, 15),
  _Slot('cable_crunch', 2, 12, 15),
];
const _fullB = [
  _Slot('romanian_deadlift', 3, 6, 10),
  _Slot('incline_dumbbell_press', 3, 8, 12),
  _Slot('chest_supported_row', 3, 8, 12),
  _Slot('leg_press', 2, 10, 12),
  _Slot('dumbbell_curl', 2, 10, 15),
  _Slot('standing_calf_raise', 2, 10, 15),
  _Slot('reverse_pec_deck', 2, 12, 15),
];
const _fullC = [
  _Slot('leg_press', 3, 8, 12),
  _Slot('machine_chest_press', 3, 8, 12),
  _Slot('seated_cable_row', 3, 8, 12),
  _Slot('hip_thrust', 2, 8, 12),
  _Slot('machine_shoulder_press', 2, 8, 12),
  _Slot('overhead_triceps_extension', 2, 10, 15),
  _Slot('hanging_knee_raise', 2, 10, 15),
];
const _pushA = [
  _Slot('barbell_bench_press', 3, 6, 8),
  _Slot('incline_dumbbell_press', 3, 8, 12),
  _Slot('machine_shoulder_press', 2, 8, 12),
  _Slot('cable_fly', 2, 12, 15),
  _Slot('dumbbell_lateral_raise', 3, 12, 15),
  _Slot('cable_pushdown', 2, 10, 15),
  _Slot('overhead_triceps_extension', 2, 10, 15),
];
const _pullA = [
  _Slot('lat_pulldown', 3, 8, 12),
  _Slot('chest_supported_row', 3, 8, 12),
  _Slot('seated_cable_row', 2, 8, 12),
  _Slot('reverse_pec_deck', 3, 12, 15),
  _Slot('dumbbell_curl', 2, 10, 15),
  _Slot('hammer_curl', 2, 10, 15),
];
const _legsA = [
  _Slot('hack_squat', 3, 6, 10),
  _Slot('romanian_deadlift', 3, 6, 10),
  _Slot('leg_extension', 2, 12, 15),
  _Slot('seated_leg_curl', 3, 10, 15),
  _Slot('standing_calf_raise', 3, 10, 15),
  _Slot('cable_crunch', 2, 12, 15),
];
const _pushB = [
  _Slot('machine_chest_press', 3, 8, 12),
  _Slot('incline_smith_press', 3, 8, 12),
  _Slot('seated_db_shoulder_press', 2, 8, 12),
  _Slot('pec_deck', 2, 12, 15),
  _Slot('cable_lateral_raise', 3, 12, 15),
  _Slot('rope_pushdown', 2, 10, 15),
];
const _pullB = [
  _Slot('assisted_pull_up', 3, 6, 10),
  _Slot('machine_row', 3, 8, 12),
  _Slot('face_pull', 3, 12, 15),
  _Slot('straight_arm_pulldown', 2, 10, 15),
  _Slot('cable_curl', 2, 10, 15),
  _Slot('incline_dumbbell_curl', 2, 10, 15),
];
const _legsB = [
  _Slot('leg_press', 3, 10, 12),
  _Slot('hip_thrust', 3, 8, 12),
  _Slot('lying_leg_curl', 3, 10, 15),
  _Slot('bulgarian_split_squat', 2, 8, 12),
  _Slot('seated_calf_raise', 3, 12, 15),
  _Slot('hanging_knee_raise', 2, 10, 15),
];

class _DayTemplate {
  final String name;
  final int weekday;
  final List<_Slot> slots;
  const _DayTemplate(this.name, this.weekday, this.slots);
}

class ProgramGenerator {
  final List<Exercise> catalog;
  final Map<String, Exercise> byId;
  late final SubstitutionEngine _sub = SubstitutionEngine(catalog);

  ProgramGenerator(this.catalog) : byId = {for (final e in catalog) e.id: e};

  /// 세트당 작업 시간(초) — 시간 추정용 앱 기본값
  static const workSecPerSet = 40;

  static int estimateMinutes(List<PlannedExercise> xs) {
    var sec = 5 * 60; // 워밍업
    for (final x in xs) {
      sec += x.sets * (workSecPerSet + x.restSec) + 60; // +60: 운동 간 이동/세팅
    }
    return (sec / 60).round();
  }

  ProgramPlan generate(UserProfile p) {
    final rationale = <Rationale>[];
    final equipment = p.equipment.isEmpty ? p.environment.defaultEquipment : p.equipment;

    // 1) 분할 결정
    var days = p.daysPerWeek.clamp(2, 6);
    if (p.experience.isNovice && days > 4) {
      rationale.add(
        Rationale('운동 경험이 3개월 미만이므로 주 ${p.daysPerWeek}일 대신 주 4일로 시작합니다. 회복과 동작 학습을 위한 앱 기본값이며, 원하면 프로그램 편집에서 날짜를 추가할 수 있습니다.', EvidenceKind.appDefault),
      );
      days = 4;
    }
    final (split, templates) = _templatesFor(days, p);
    rationale.add(
      Rationale('주 $days일 → ${split.ko}. 같은 근육을 주 2회 정도 자극하면서도 지속하기 쉬운 구성을 우선했습니다.', EvidenceKind.research, [
        'schoenfeld_2016_frequency',
        'schoenfeld_2019_frequency',
      ]),
    );
    rationale.add(
      const Rationale('운동량을 맞추면 빈도 자체의 차이는 크지 않으므로, 복잡한 분할보다 주간 운동량 확보와 지속 가능성을 기준으로 선택했습니다.', EvidenceKind.research, [
        'schoenfeld_2019_frequency',
        'currier_2023_nma',
      ]),
    );

    // 2~4) 요일별 운동 구성
    final changes = <String>[];
    final planned = <PlannedDay>[];
    for (final t in templates) {
      final used = <String>{};
      final xs = <PlannedExercise>[];
      for (var i = 0; i < t.slots.length; i++) {
        final s = t.slots[i];
        final ex = _resolve(s.id, p, equipment, used, changes);
        if (ex == null) continue;
        used.add(ex.id);
        xs.add(_prescribe(ex, s, p, isMain: i == 0));
      }
      planned.add(PlannedDay(name: t.name, weekday: t.weekday, exercises: xs));
    }
    if (changes.isNotEmpty) {
      rationale.add(
        Rationale('사용 가능한 기구·숙련도·통증 정보에 맞춰 일부 운동을 교체했습니다: ${changes.take(8).join(', ')}${changes.length > 8 ? ' 외' : ''}.', EvidenceKind.appDefault),
      );
    }
    _goalRationale(p, rationale);

    // 5) 주간 운동량 조정
    final target = weeklyVolumeTarget(p);
    rationale.addAll(target.rationale);
    var adjusted = _adjustVolume(planned, target);

    // 6) 시간 제약
    final (fitted, trimmed) = _fitTime(adjusted, p.sessionMinutes);
    adjusted = fitted;
    if (trimmed) {
      rationale.add(Rationale('1회 운동 시간(${p.sessionMinutes}분)에 맞추기 위해 일부 세트/운동을 줄였습니다. 이 경우 일부 근육의 주간 세트가 목표보다 적을 수 있습니다.', EvidenceKind.appDefault));
    }

    rationale.add(
      const Rationale('대부분의 세트는 실패 지점 전(RIR 1~3)에서 마칩니다. 실패까지 하는 것과 실패 전 종료의 근비대 차이는 크지 않은 것으로 보고되었습니다.', EvidenceKind.research, [
        'grgic_2022_failure',
        'refalo_2023_proximity',
      ]),
    );
    rationale.add(const Rationale('복합운동 휴식 2~3분, 고립운동 1~2분을 기본값으로 사용합니다.', EvidenceKind.research, ['schoenfeld_2016_rest', 'singer_2024_rest']));
    rationale.add(const Rationale('이 프로그램은 출발점입니다. 운동 기록이 쌓이면 중량·반복·세트를 기록 기반으로 조정합니다.', EvidenceKind.appDefault));

    return ProgramPlan(name: '${split.ko} · 주 $days일', split: split, days: adjusted, rationale: rationale);
  }

  (SplitType, List<_DayTemplate>) _templatesFor(int days, UserProfile p) {
    switch (days) {
      case 2:
        return (SplitType.fullBody, const [_DayTemplate('전신 A', 1, _fullA), _DayTemplate('전신 B', 4, _fullB)]);
      case 3:
        return (SplitType.fullBody, const [_DayTemplate('전신 A', 1, _fullA), _DayTemplate('전신 B', 3, _fullB), _DayTemplate('전신 C', 5, _fullC)]);
      case 4:
        return (
          SplitType.upperLower,
          const [_DayTemplate('상체 A', 1, _upperA), _DayTemplate('하체 A', 2, _lowerA), _DayTemplate('상체 B', 4, _upperB), _DayTemplate('하체 B', 5, _lowerB)],
        );
      case 5:
        return (
          SplitType.upperLowerFull,
          const [
            _DayTemplate('상체 A', 1, _upperA),
            _DayTemplate('하체 A', 2, _lowerA),
            _DayTemplate('전신 C', 3, _fullC),
            _DayTemplate('상체 B', 5, _upperB),
            _DayTemplate('하체 B', 6, _lowerB),
          ],
        );
      default:
        return (
          SplitType.ppl,
          const [
            _DayTemplate('밀기 A', 1, _pushA),
            _DayTemplate('당기기 A', 2, _pullA),
            _DayTemplate('하체 A', 3, _legsA),
            _DayTemplate('밀기 B', 4, _pushB),
            _DayTemplate('당기기 B', 5, _pullB),
            _DayTemplate('하체 B', 6, _legsB),
          ],
        );
    }
  }

  /// 템플릿 운동이 부적합하면 대체 운동을 찾습니다.
  Exercise? _resolve(String id, UserProfile p, Set<Equipment> equipment, Set<String> used, List<String> changes) {
    final ex = byId[id];
    if (ex == null) return null;
    final available = SubstitutionEngine.isAvailable(ex, equipment);
    final contra = SubstitutionEngine.isContraindicated(ex, p.limitations);
    final tooHard = ex.difficulty > p.experience.maxDifficulty;
    final jointHeavy = SubstitutionEngine.jointPenalty(ex, p.limitations) >= 6;
    if (available && !contra && !tooHard && !jointHeavy && !used.contains(ex.id)) return ex;

    final cands = _sub.suggest(ex, equipment: equipment, limitations: p.limitations, experience: p.experience, goal: p.primaryGoal, exclude: used, limit: 10);
    // 숙련도에 맞는 후보 우선
    final fit = cands.where((c) => c.exercise.difficulty <= p.experience.maxDifficulty).toList();
    final pick = (fit.isNotEmpty ? fit : cands).firstOrNull;
    if (pick == null) {
      // 대체가 없으면: 금기/기구 없음 → 제외, 난이도만 문제 → 유지
      if (available && !contra && !used.contains(ex.id)) return ex;
      changes.add('${ex.nameKo} 제외');
      return null;
    }
    final why = !available
        ? '기구 없음'
        : contra || jointHeavy
        ? '통증 부위 부담'
        : tooHard
        ? '숙련도'
        : '중복';
    changes.add('${ex.nameKo}→${pick.exercise.nameKo}($why)');
    return pick.exercise;
  }

  PlannedExercise _prescribe(Exercise ex, _Slot s, UserProfile p, {required bool isMain}) {
    var repMin = s.repMin, repMax = s.repMax, rest = ex.restSec, rir = ex.type == ExerciseType.compound ? 2 : 1;
    if (ex.timed) {
      repMin = ex.repMin;
      repMax = ex.repMax;
    }
    final g = p.primaryGoal;
    if (g == Goal.strength && isMain && ex.type == ExerciseType.compound && !ex.timed) {
      repMin = 4;
      repMax = 6;
      rest = 180;
      rir = 2;
    } else if (g == Goal.fitness && !ex.timed) {
      repMin = repMin < 10 ? 10 : repMin;
      repMax = repMax < 15 ? 15 : repMax;
      rest = ex.type == ExerciseType.compound ? 90 : 60;
    } else if (g == Goal.health || p.experience.isNovice) {
      rir = ex.type == ExerciseType.compound ? 3 : 2;
    }
    if (p.experience.isNovice) rir = rir < 2 ? 2 : rir;
    return PlannedExercise(exerciseId: ex.id, sets: s.sets, repMin: repMin, repMax: repMax, targetRir: rir, restSec: rest);
  }

  void _goalRationale(UserProfile p, List<Rationale> r) {
    switch (p.primaryGoal) {
      case Goal.strength:
        r.add(
          const Rationale('최대근력 목표: 각 날의 첫 복합운동을 4~6회, 휴식 3분으로 설정했습니다. 최대근력 향상에는 고중량이 상대적으로 유리했습니다.', EvidenceKind.research, [
            'schoenfeld_2017_load',
            'currier_2023_nma',
          ]),
        );
      case Goal.fatLoss || Goal.weightLoss:
        r.add(
          const Rationale(
            '체지방/체중 감량 목표: 근력운동은 근육 유지를 위해 유지하고, 감량은 식사와 활동량으로 조절하는 것을 권장합니다. 유산소 병행은 근비대·최대근력을 전반적으로 방해하지 않는 것으로 보고되었습니다.',
            EvidenceKind.research,
            ['schumann_2022_concurrent'],
          ),
        );
      case Goal.fitness:
        r.add(const Rationale('체력 향상 목표: 반복 범위를 높이고 휴식을 짧게 설정했습니다.', EvidenceKind.appDefault));
      case Goal.posture:
        r.add(const Rationale('자세/균형 목표: 후면 삼각근·등 상부 운동과 복근 운동 비중을 확인하세요. 통증이 있으면 의료 전문가와 상담하세요.', EvidenceKind.appDefault));
      case Goal.hypertrophy:
        r.add(
          const Rationale('근육량 증가 목표: 복합운동 6~10회, 고립운동 10~20회 범위를 사용합니다. 충분한 노력이라면 다양한 반복 범위에서 근비대가 가능합니다.', EvidenceKind.research, ['schoenfeld_2017_load']),
        );
      case Goal.health:
        r.add(const Rationale('건강 유지 목표: 무리하지 않는 운동량과 여유 있는 RIR(2~3)로 지속성을 우선합니다.', EvidenceKind.appDefault, ['acsm_2009_progression']));
    }
  }

  List<PlannedDay> _adjustVolume(List<PlannedDay> days, VolumeTarget target) {
    final engine = VolumeEngine(byId);
    final ds = [
      for (final d in days) d.copyWith(exercises: [...d.exercises]),
    ];
    for (var guard = 0; guard < 60; guard++) {
      final vol = engine.plannedVolume(ds);
      var changed = false;
      for (final m in trackedMuscles) {
        final v = vol[m]!.direct;
        if (v > target.max) {
          changed |= _changeSets(ds, m, -1, preferIsolation: true);
        } else if (v > 0 && v < target.min) {
          changed |= _changeSets(ds, m, 1, preferIsolation: true);
        }
      }
      if (!changed) break;
    }
    return ds;
  }

  /// 근육 m이 주 자극인 운동 중 하나의 세트를 ±1 (고립운동 우선, 각 날의 첫 운동 보호)
  bool _changeSets(List<PlannedDay> ds, Muscle m, int delta, {required bool preferIsolation}) {
    (int, int)? best;
    var bestScore = -1 << 30;
    for (var di = 0; di < ds.length; di++) {
      final xs = ds[di].exercises;
      for (var xi = 0; xi < xs.length; xi++) {
        final x = xs[xi];
        final e = byId[x.exerciseId]!;
        if (!e.primary.contains(m)) continue;
        if (delta < 0 && (x.sets <= 2 || (xi == 0 && x.sets <= 3))) continue;
        if (delta > 0 && x.sets >= 4) continue;
        var score = 0;
        if (e.type == ExerciseType.isolation) score += 10;
        if (e.primary.length == 1) score += 5; // 다른 근육에 영향 적음
        score += delta < 0 ? x.sets : -x.sets;
        if (xi == 0) score -= 20;
        if (score > bestScore) {
          bestScore = score;
          best = (di, xi);
        }
      }
    }
    if (best == null) return false;
    final (di, xi) = best;
    final xs = ds[di].exercises;
    xs[xi] = xs[xi].copyWith(sets: xs[xi].sets + delta);
    return true;
  }

  (List<PlannedDay>, bool) _fitTime(List<PlannedDay> days, int minutes) {
    var trimmed = false;
    final out = <PlannedDay>[];
    for (final d in days) {
      final xs = fitToTime(d.exercises, minutes);
      if (xs.length != d.exercises.length || xs.fold(0, (a, x) => a + x.sets) != d.exercises.fold(0, (a, x) => a + x.sets)) trimmed = true;
      out.add(d.copyWith(exercises: xs));
    }
    return (out, trimmed);
  }

  /// 예상 시간이 [minutes] 이하가 되도록 뒤쪽 운동부터 세트(최소 2)를 줄이고, 그래도 넘으면 마지막 운동을 제거(최소 3개 유지)
  static List<PlannedExercise> fitToTime(List<PlannedExercise> input, int minutes) {
    final xs = [...input];
    var guard = 0;
    while (estimateMinutes(xs) > minutes && guard++ < 100) {
      var reduced = false;
      for (var i = xs.length - 1; i >= 1; i--) {
        if (xs[i].sets > 2) {
          xs[i] = xs[i].copyWith(sets: xs[i].sets - 1);
          reduced = true;
          break;
        }
      }
      if (reduced) continue;
      if (xs.length > 3) {
        xs.removeLast();
      } else if (xs.isNotEmpty && xs.first.sets > 2) {
        xs[0] = xs[0].copyWith(sets: xs[0].sets - 1);
      } else {
        break;
      }
    }
    return xs;
  }
}
