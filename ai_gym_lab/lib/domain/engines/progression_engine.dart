// 점진적 과부하 엔진 (Double Progression + RIR + 안전장치)
//
// 판단 순서
//  1. 기록 없음 → 기준 중량 찾기 (중량을 임의로 단정하지 않음)
//  2. 공백 기간(14일↑/28일↑) → 복귀 강도 재평가(감량)
//  3. 통증 → 자동 증가 중단 (2회 연속이면 감량 + 대체 운동 권장)
//  4. 자세 불안정 → 유지
//  5. 목표 세트 미완료 → 유지
//  6. 반복 범위 평가
//     - 모든 세트 상단 달성 + RIR ≥ 1 → 1단계 증가 (반복은 하단부터 다시)
//     - 상단 달성했지만 RIR 0 → 유지 (같은 중량을 여유 있게 달성하면 증가)
//     - 범위 안 → 중량 유지 + 반복 늘리기
//     - 범위 미달 1회 → 피로·난이도 확인(유지), 2회 연속/큰 폭 → 감량
//  7. 오늘 회복 상태가 낮으면 증가를 보류
// 수치(14/28일, 10/20% 감량, 2회 연속 등)는 연구로 확정된 값이 아닌 앱 기본값입니다.
import '../models.dart';

enum ProgressionAction { establishBaseline, increaseWeight, maintain, increaseReps, adjustSets, decreaseWeight, recover }

extension ProgressionActionKo on ProgressionAction {
  String get ko => const {
    ProgressionAction.establishBaseline: '기준 중량 찾기',
    ProgressionAction.increaseWeight: '중량 증가',
    ProgressionAction.maintain: '중량 유지',
    ProgressionAction.increaseReps: '반복 횟수 증가',
    ProgressionAction.adjustSets: '세트 수 조정',
    ProgressionAction.decreaseWeight: '중량 감소',
    ProgressionAction.recover: '회복 권장',
  }[this]!;
}

enum Confidence { low, medium, high }

extension ConfidenceKo on Confidence {
  String get ko => const {Confidence.low: '낮음', Confidence.medium: '보통', Confidence.high: '높음'}[this]!;
}

enum Readiness { good, caution, low, rest }

class ProgressionRecommendation {
  final ProgressionAction action;

  /// null = 기록이 없어 중량을 단정하지 않음
  final double? weight;
  final double? previousWeight;
  final int sets;

  /// 세트별 목표 반복
  final List<int> targetReps;
  final List<String> reasons;
  final Confidence confidence;
  final List<String> referenceIds;

  const ProgressionRecommendation({
    required this.action,
    required this.weight,
    this.previousWeight,
    required this.sets,
    required this.targetReps,
    required this.reasons,
    required this.confidence,
    this.referenceIds = const [],
  });

  String summary({bool timed = false, bool assisted = false}) {
    final unit = timed ? '초' : '회';
    final reps = targetReps.toSet().length == 1 ? '${targetReps.first}$unit' : targetReps.map((r) => '$r').join('/') + unit;
    if (weight == null) return '$sets세트 × $reps · 기준 중량 찾기';
    final w = '${fmtKg(weight!)}kg${assisted ? '(보조)' : ''}';
    return '$w × $reps × $sets세트';
  }
}

String fmtKg(double w) => w == w.roundToDouble() ? w.toInt().toString() : w.toStringAsFixed(w * 10 == (w * 10).roundToDouble() ? 1 : 2);

class ProgressionEngine {
  const ProgressionEngine();

  static double roundTo(double w, double inc, {bool down = false}) {
    if (inc <= 0) return w;
    final q = w / inc;
    final r = (down ? q.floorToDouble() : q.roundToDouble()) * inc;
    return double.parse(r.toStringAsFixed(2)).clamp(0, double.infinity).toDouble();
  }

  ProgressionRecommendation recommend({
    required Exercise exercise,
    required int targetSets,
    required int repMin,
    required int repMax,
    int targetRir = 2,
    required List<ExercisePerformance> history, // 최신순
    required double increment,
    required DateTime now,
    double? userStartWeight,
    Experience experience = Experience.m6to12,
    Readiness readiness = Readiness.good,
  }) {
    final assisted = exercise.assisted;
    double harder(double w, double step) => assisted ? (w - step).clamp(0, double.infinity).toDouble() : w + step;
    double easier(double w, double frac) {
      if (assisted) {
        final nw = roundTo(w * (1 + frac), increment);
        return nw <= w ? w + increment : nw;
      }
      final nw = roundTo(w * (1 - frac), increment, down: true);
      return nw >= w && w > 0 ? (w - increment).clamp(0, double.infinity).toDouble() : nw;
    }

    List<int> repsAll(int r) => List.filled(targetSets, r);

    // 1. 기록 없음
    final hist = history.where((h) => h.completedSets.isNotEmpty).toList();
    if (hist.isEmpty) {
      return ProgressionRecommendation(
        action: ProgressionAction.establishBaseline,
        weight: userStartWeight,
        sets: targetSets,
        targetReps: repsAll(repMin),
        confidence: Confidence.low,
        reasons: [
          '이 운동의 기록이 없어 중량을 단정하지 않습니다.',
          userStartWeight != null
              ? '직접 입력한 시작 중량 ${fmtKg(userStartWeight)}kg을 사용합니다. 첫 세트에서 너무 무겁거나 가벼우면 조정하세요.'
              : '가벼운 중량으로 시작해 목표 반복($repMin~$repMax회)을 RIR 2~3(2~3회 더 할 수 있는 여유)으로 마칠 수 있는 중량을 찾으세요.',
          '오늘 기록이 다음 운동 추천의 기준이 됩니다.',
        ],
      );
    }

    final last = hist.first;
    final lastW = last.workingWeight;
    final days = now.difference(last.date).inHours / 24;
    final lastSets = last.completedSets;
    final lastReps = [for (var i = 0; i < targetSets; i++) i < lastSets.length ? lastSets[i].reps : repMin];

    // 2. 공백
    if (days >= 14) {
      final frac = days >= 28 ? 0.2 : 0.1;
      final w = lastW > 0 ? easier(lastW, frac) : lastW;
      return ProgressionRecommendation(
        action: ProgressionAction.decreaseWeight,
        weight: w,
        previousWeight: lastW,
        sets: targetSets,
        targetReps: repsAll(repMin),
        confidence: Confidence.low,
        reasons: [
          '마지막 기록 이후 ${days.floor()}일이 지났습니다 → 복귀 강도 재평가.',
          '약 ${(frac * 100).round()}% ${assisted ? '보조를 늘려' : '낮춰'} 시작하고, 컨디션이 좋으면 세트마다 올려도 됩니다. (앱 기본값)',
        ],
      );
    }

    // 3. 통증
    if (last.pain) {
      final repeated = hist.length >= 2 && hist[1].pain;
      if (repeated) {
        return ProgressionRecommendation(
          action: ProgressionAction.decreaseWeight,
          weight: lastW > 0 ? easier(lastW, 0.1) : lastW,
          previousWeight: lastW,
          sets: targetSets,
          targetReps: repsAll(repMin),
          confidence: Confidence.medium,
          reasons: ['최근 2회 연속 통증이 기록되었습니다 → 자동 중량 증가 중단.', '중량을 낮추고 통증 없는 범위에서 수행하거나 대체 운동을 고려하세요.', '통증이 지속되거나 심해지면 운동을 멈추고 의료 전문가와 상담하세요. (앱은 진단을 하지 않습니다)'],
        );
      }
      return ProgressionRecommendation(
        action: ProgressionAction.maintain,
        weight: lastW,
        previousWeight: lastW,
        sets: targetSets,
        targetReps: lastReps,
        confidence: Confidence.medium,
        reasons: ['지난 운동에서 통증이 기록되었습니다 → 중량 증가 보류.', '같은 중량에서 통증 없이 수행되는지 확인하세요.'],
      );
    }

    // 4. 자세 불안정
    if (last.formUnstable) {
      return ProgressionRecommendation(
        action: ProgressionAction.maintain,
        weight: lastW,
        previousWeight: lastW,
        sets: targetSets,
        targetReps: lastReps,
        confidence: Confidence.medium,
        reasons: ['지난 운동에서 자세가 불안정했다고 기록했습니다 → 같은 중량에서 자세를 먼저 안정화합니다.'],
      );
    }

    final work = lastSets.take(targetSets).toList();
    final rirs = work.map((s) => s.rir).whereType<int>().toList();
    final minRir = rirs.isEmpty ? null : rirs.reduce((a, b) => a < b ? a : b);
    final allTop = work.length >= targetSets && work.every((s) => s.reps >= repMax);
    final belowMin = work.where((s) => s.reps < repMin).length;
    final reasons = <String>[];
    final refs = <String>[];
    var conf = hist.length >= 3 && rirs.isNotEmpty ? Confidence.high : Confidence.medium;
    if (experience.isNovice && rirs.isNotEmpty) {
      reasons.add('초보자는 RIR 평가가 부정확할 수 있어 반복 횟수를 우선 반영했습니다.');
      refs.add('zourdos_2016_rir');
    }
    final lastDesc = '지난 기록: ${fmtKg(lastW)}kg × ${work.map((s) => s.reps).join('/')}${minRir != null ? ' (최소 RIR $minRir)' : ''}';
    reasons.insert(0, lastDesc);

    ProgressionRecommendation withReadiness(ProgressionRecommendation r) {
      if (readiness == Readiness.good || r.action != ProgressionAction.increaseWeight) return r;
      return ProgressionRecommendation(
        action: ProgressionAction.maintain,
        weight: r.previousWeight,
        previousWeight: r.previousWeight,
        sets: r.sets,
        targetReps: lastReps,
        confidence: r.confidence,
        reasons: [...r.reasons, '다만 오늘 회복 상태가 낮게 평가되어 중량 증가는 다음 운동으로 미룹니다.'],
        referenceIds: r.referenceIds,
      );
    }

    // 5. 세트 미완료
    if (work.length < targetSets && belowMin == 0) {
      return ProgressionRecommendation(
        action: ProgressionAction.maintain,
        weight: lastW,
        previousWeight: lastW,
        sets: targetSets,
        targetReps: lastReps,
        confidence: conf,
        reasons: [...reasons, '목표 $targetSets세트 중 ${work.length}세트만 완료했습니다 → 중량 유지 후 모든 세트 완료를 목표로 합니다.'],
      );
    }

    // 6a. 모든 세트 상단 달성
    if (allTop) {
      if (minRir == 0) {
        return ProgressionRecommendation(
          action: ProgressionAction.maintain,
          weight: lastW,
          previousWeight: lastW,
          sets: targetSets,
          targetReps: repsAll(repMax),
          confidence: conf,
          reasons: [...reasons, '목표 반복은 달성했지만 실패 지점(RIR 0)에 도달한 세트가 있습니다.', '같은 중량을 RIR 1 이상으로 달성하면 중량을 올립니다.'],
          referenceIds: ['grgic_2022_failure'],
        );
      }
      if (exercise.timed || (exercise.bodyweight && lastW == 0)) {
        final cap = repMax + 5;
        return ProgressionRecommendation(
          action: ProgressionAction.increaseReps,
          weight: lastW,
          previousWeight: lastW,
          sets: targetSets,
          targetReps: [for (final r in lastReps) (r + (exercise.timed ? 5 : 1)).clamp(repMin, exercise.timed ? repMax + 30 : cap)],
          confidence: conf,
          reasons: [...reasons, exercise.timed ? '목표 시간을 모두 달성했습니다 → 시간을 조금 늘립니다.' : '맨몸으로 반복 범위 상단을 달성했습니다 → 반복을 늘리거나 더 어려운 변형·외부 중량 추가를 고려하세요.'],
        );
      }
      if (hist.length == 1 && minRir == null) conf = Confidence.medium;
      final w = harder(lastW, increment);
      final rel = lastW > 0 && !assisted ? increment / lastW : 0;
      final extra = <String>[];
      if (rel > 0.15) {
        conf = Confidence.low;
        extra.add('증가 폭이 현재 중량의 ${(rel * 100).round()}%로 큰 편입니다. 첫 세트만 새 중량을 시도하거나 반복을 먼저 늘리는 방법도 있습니다.');
      }
      if (hist.length < 2) extra.add('기록이 1회뿐이라 1단계만 올립니다.');
      return withReadiness(
        ProgressionRecommendation(
          action: ProgressionAction.increaseWeight,
          weight: w,
          previousWeight: lastW,
          sets: targetSets,
          targetReps: repsAll(repMin),
          confidence: conf,
          reasons: [
            ...reasons,
            '모든 세트에서 목표 상단($repMax회)을 달성했고 여유가 있었습니다 → ${fmtKg(lastW)}kg → ${fmtKg(w)}kg ${assisted ? '(보조 중량 감소)' : ''}도전.',
            '중량이 바뀌었으므로 반복은 범위 하단($repMin회)부터 다시 쌓습니다.',
            ...extra,
          ],
          referenceIds: [...refs, 'plotkin_2022_progression', 'helms_2016_rir'],
        ),
      );
    }

    // 6c. 범위 미달
    if (belowMin > 0) {
      final prev = hist.length >= 2 ? hist[1] : null;
      final prevBelow =
          prev != null &&
          (assisted ? prev.workingWeight >= lastW : prev.workingWeight <= lastW) &&
          prev.completedSets.take(targetSets).any((s) => s.reps < repMin);
      final totalReps = work.fold<int>(0, (a, s) => a + s.reps);
      final severe = totalReps < repMin * targetSets * 0.7;
      if (prevBelow || severe) {
        final w = lastW > 0 ? easier(lastW, 0.075) : lastW;
        return ProgressionRecommendation(
          action: readiness == Readiness.low || readiness == Readiness.rest ? ProgressionAction.recover : ProgressionAction.decreaseWeight,
          weight: w,
          previousWeight: lastW,
          sets: targetSets,
          targetReps: repsAll(repMin),
          confidence: conf,
          reasons: [
            ...reasons,
            prevBelow ? '2회 연속 목표 반복($repMin회) 미달입니다.' : '목표 반복 대비 수행량이 크게 부족했습니다.',
            '중량을 약 5~10% 낮춰 목표 범위 안에서 다시 쌓아 올립니다.',
            if (readiness == Readiness.low || readiness == Readiness.rest) '오늘 회복 상태도 낮아 회복을 우선하는 것을 권장합니다.',
          ],
        );
      }
      final fatigued = readiness == Readiness.low || readiness == Readiness.rest;
      return ProgressionRecommendation(
        action: fatigued ? ProgressionAction.adjustSets : ProgressionAction.maintain,
        weight: lastW,
        previousWeight: lastW,
        sets: fatigued ? (targetSets - 1).clamp(1, targetSets) : targetSets,
        targetReps: repsAll(repMin),
        confidence: conf,
        reasons: [
          ...reasons,
          '일부 세트가 목표 하단($repMin회)에 못 미쳤습니다 → 피로와 난이도 확인.',
          '같은 중량을 유지하고 수면·피로·휴식 시간을 점검하세요. 다음에도 미달이면 중량을 낮춥니다.',
          if (fatigued) '오늘 회복 상태가 낮아 세트를 1개 줄이는 것을 제안합니다.',
        ],
      );
    }

    // 6b. 범위 안 → 반복 늘리기
    final targets = [for (final r in lastReps) (r + 1).clamp(repMin, repMax)];
    final stalled = _stalled(hist, targetSets);
    return ProgressionRecommendation(
      action: ProgressionAction.increaseReps,
      weight: lastW,
      previousWeight: lastW,
      sets: targetSets,
      targetReps: targets,
      confidence: conf,
      reasons: [
        ...reasons,
        '목표 범위($repMin~$repMax회) 안입니다 → ${fmtKg(lastW)}kg 유지, 상단에 못 미친 세트의 반복을 1회씩 늘립니다.',
        '모든 세트가 $repMax회에 도달하면 중량을 올립니다(더블 프로그레션).',
        if (stalled) '최근 3회 이상 같은 중량에서 반복 수가 늘지 않았습니다. 정체 가능성이 있어 주간 분석에서 원인을 확인하세요.',
      ],
      referenceIds: ['plotkin_2022_progression'],
    );
  }

  static bool _stalled(List<ExercisePerformance> hist, int targetSets) {
    if (hist.length < 3) return false;
    final w0 = hist[0].workingWeight;
    if (hist.take(3).any((h) => h.workingWeight != w0)) return false;
    int total(ExercisePerformance h) => h.completedSets.take(targetSets).fold(0, (a, s) => a + s.reps);
    return total(hist[0]) <= total(hist[2]);
  }
}
