// 운동 대체 추천 엔진
//
// 점수 = 움직임 패턴 일치 + 주요 근육 겹침 + 보조 근육 겹침 + 명시적 대체 목록
//        - 난이도 초과 감점 - 관절 부담 감점 (+ 목표별 소폭 가산)
// 사용 불가능한 기구가 필요한 운동과 금기(심한 통증 부위에 높은 부담) 운동은 제외합니다.
// 대체 운동은 기존 중량을 그대로 적용하지 않습니다(진행 엔진에서 '기준 중량 찾기'로 시작).
import '../models.dart';

class SubstitutionCandidate {
  final Exercise exercise;
  final double score;
  final List<String> reasons;
  const SubstitutionCandidate(this.exercise, this.score, this.reasons);
}

class SubstitutionEngine {
  final List<Exercise> catalog;
  const SubstitutionEngine(this.catalog);

  static bool isAvailable(Exercise e, Set<Equipment> equipment) => e.equipment.every((q) => q == Equipment.bodyweight || equipment.contains(q));

  /// 통증 강도(0~10)와 운동의 관절 부담(0~2)으로 금기 여부 판단 (앱 안전 규칙, 의학적 판단 아님)
  static bool isContraindicated(Exercise e, List<Limitation> limitations) {
    for (final l in limitations) {
      final s = e.stressOn(l.area);
      if (l.severity >= 6 && s >= 2) return true;
      if (l.severity >= 8 && s >= 1) return true;
    }
    return false;
  }

  /// 관절 부담 감점(0이면 문제 없음)
  static double jointPenalty(Exercise e, List<Limitation> limitations) {
    var p = 0.0;
    for (final l in limitations) {
      p += e.stressOn(l.area) * (l.severity / 10) * 15;
    }
    return p;
  }

  List<SubstitutionCandidate> suggest(
    Exercise current, {
    required Set<Equipment> equipment,
    List<Limitation> limitations = const [],
    Experience? experience,
    Goal? goal,
    Set<String> exclude = const {},
    int limit = 5,
  }) {
    final out = <SubstitutionCandidate>[];
    for (final c in catalog) {
      if (c.id == current.id || exclude.contains(c.id)) continue;
      if (!isAvailable(c, equipment)) continue;
      if (isContraindicated(c, limitations)) continue;

      final reasons = <String>[];
      var score = 0.0;
      final samePattern = c.pattern == current.pattern;
      final pOverlap = _jaccard(c.primary, current.primary);
      // 같은 패턴도 아니고 주요 근육도 겹치지 않으면 대체 운동이 아님
      if (!samePattern && pOverlap == 0) continue;
      if (samePattern) {
        score += 40;
        reasons.add('같은 움직임 패턴(${c.pattern.ko})');
      }
      if (pOverlap > 0) {
        score += 40 * pOverlap;
        final shared = c.primary.where(current.primary.contains).map((m) => m.ko).join('·');
        reasons.add('주요 자극 근육 일치: $shared');
      }
      score += 10 * _jaccard(c.secondary, current.secondary);
      if (current.alternatives.contains(c.id) || c.alternatives.contains(current.id)) {
        score += 15;
        reasons.add('일반적으로 쓰이는 대체 운동');
      }
      if (c.type == current.type) score += 5;
      if (experience != null && c.difficulty > experience.maxDifficulty) {
        score -= 20;
        reasons.add('현재 숙련도보다 어려울 수 있음');
      }
      final jp = jointPenalty(c, limitations);
      if (jp > 0) {
        score -= jp;
      } else if (limitations.isNotEmpty && jointPenalty(current, limitations) > 0) {
        reasons.add('입력한 통증 부위 부담이 낮은 편');
      }
      if (goal == Goal.strength && c.type == ExerciseType.compound && c.equipment.contains(Equipment.barbell)) score += 5;
      if (c.bodyweight && !current.bodyweight) score -= 5;
      out.add(SubstitutionCandidate(c, score, reasons));
    }
    out.sort((a, b) => b.score.compareTo(a.score));
    return out.take(limit).toList();
  }

  static double _jaccard(List<Muscle> a, List<Muscle> b) {
    if (a.isEmpty || b.isEmpty) return 0;
    final sa = a.toSet(), sb = b.toSet();
    return sa.intersection(sb).length / sa.union(sb).length;
  }
}
