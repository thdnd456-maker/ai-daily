// 근육별 주간 운동량 계산 엔진
//
// - 직접 세트: 해당 근육이 '주요 자극 근육'인 운동의 완료 세트 수(1세트 = 1).
// - 간접 세트: 해당 근육이 '보조 근육'인 운동의 완료 세트 × 0.5.
//   0.5 가중치는 연구로 확정된 값이 아닌 앱의 추정 모델이며 화면에도 그렇게 표시합니다.
import '../models.dart';

const double indirectWeight = 0.5;

class VolumeTarget {
  final int min;
  final int max;
  final List<Rationale> rationale;
  const VolumeTarget(this.min, this.max, [this.rationale = const []]);
}

/// 주간 세트 목표(근육별 직접 세트). 모두 앱 기본값이며, 출발점은 Schoenfeld 2017 등을 참고했습니다.
VolumeTarget weeklyVolumeTarget(UserProfile p) {
  var (min, max) = switch (p.experience) {
    Experience.none || Experience.under3m => (6, 10),
    Experience.m3to6 => (8, 12),
    Experience.m6to12 => (10, 14),
    Experience.y1to3 => (10, 16),
    Experience.y3plus => (12, 18),
  };
  final notes = <Rationale>[
    Rationale('근육별 주 10세트 이상이 5세트 미만보다 근비대와 더 강하게 연관된다는 메타분석 결과를 참고했습니다.', EvidenceKind.research, ['schoenfeld_2017_volume']),
    Rationale('경험 수준(${p.experience.ko})에 따라 근육별 주 $min~$max세트를 시작 범위로 설정했습니다. 이 범위는 앱의 실용 권장값입니다.', EvidenceKind.appDefault),
  ];
  if (p.primaryGoal == Goal.health || p.primaryGoal == Goal.posture) {
    min = (min - 2).clamp(4, 20);
    max = (max - 4).clamp(min + 2, 20);
    notes.add(Rationale('건강 유지/자세 개선이 최우선 목표이므로 운동량을 주 $min~$max세트로 낮춰 지속 가능성을 우선했습니다.', EvidenceKind.appDefault));
  }
  if (p.primaryGoal == Goal.strength) {
    max = (max - 2).clamp(min + 2, 20);
    notes.add(Rationale('최대근력 목표는 주요 리프트의 질을 위해 보조운동량 상한을 약간 낮췄습니다.', EvidenceKind.appDefault));
  }
  return VolumeTarget(min, max, notes);
}

class MuscleVolume {
  double direct;
  double indirect;
  MuscleVolume([this.direct = 0, this.indirect = 0]);
  double get total => direct + indirect;
}

class VolumeEngine {
  final Map<String, Exercise> exercises;
  const VolumeEngine(this.exercises);

  /// [setsByExercise]: (운동 ID, 완료 세트 수) 목록
  Map<Muscle, MuscleVolume> compute(Iterable<(String, int)> setsByExercise) {
    final out = {for (final m in Muscle.values) m: MuscleVolume()};
    for (final (id, sets) in setsByExercise) {
      final e = exercises[id];
      if (e == null || sets <= 0) continue;
      for (final m in e.primary) {
        out[m]!.direct += sets;
      }
      for (final m in e.secondary) {
        if (e.primary.contains(m)) continue;
        out[m]!.indirect += sets * indirectWeight;
      }
    }
    return out;
  }

  /// 프로그램 계획의 주간 직접 세트(목표치)
  Map<Muscle, MuscleVolume> plannedVolume(List<PlannedDay> days) => compute([
    for (final d in days)
      for (final x in d.exercises) (x.exerciseId, x.sets),
  ]);
}

enum VolumeStatus { none, below, within, above }

class VolumeAssessment {
  final VolumeStatus status;
  final String message;
  const VolumeAssessment(this.status, this.message);
}

/// 운동량 평가: '많을수록 좋다'고 판단하지 않습니다.
VolumeAssessment assessVolume(Muscle m, double direct, VolumeTarget t, {bool poorRecovery = false}) {
  if (direct <= 0) return VolumeAssessment(VolumeStatus.none, '${m.ko}: 이번 주 직접 운동 기록이 없습니다.');
  if (direct < t.min) {
    return VolumeAssessment(VolumeStatus.below, '${m.ko}: ${_f(direct)}세트로 시작 목표(${t.min}~${t.max})보다 적습니다. 이번 주 남은 운동으로 채울 수 있는지 확인하세요.');
  }
  if (direct > t.max) {
    final extra = poorRecovery ? ' 최근 회복 지표가 낮아 운동량을 유지하거나 줄이는 것을 고려하세요.' : '';
    return VolumeAssessment(VolumeStatus.above, '${m.ko}: ${_f(direct)}세트로 시작 목표 상한(${t.max})을 넘었습니다. 세트가 많다고 반드시 더 효과적인 것은 아니며, 수행 능력과 회복을 함께 확인하세요.$extra');
  }
  return VolumeAssessment(VolumeStatus.within, '${m.ko}: ${_f(direct)}세트로 시작 목표 범위 안입니다.');
}

String _f(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
