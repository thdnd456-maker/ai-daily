// 회복 상태 분석 엔진
//
// 회복 점수(0~100)는 의료적으로 검증된 지표가 아니라 수면·피로·근육통·의욕·관절 통증과
// 최근 수행 추세를 합산한 앱 자체 추정값입니다. 가중치는 모두 앱 기본값입니다.
import '../models.dart';
import 'progression_engine.dart';

class RecoveryInput {
  final double sleepHours;
  final int fatigue; // 1(낮음)~5(높음)
  final int soreness; // 1~5
  final int motivation; // 1(낮음)~5(높음)
  final bool jointPain;
  final JointArea? painArea;

  /// 최근 7일 동안 수행이 떨어진 운동 수 (통계 엔진 제공)
  final int recentPerformanceDrops;

  /// 마지막 운동 후 경과 시간(시간). null=기록 없음
  final double? hoursSinceLastSession;

  const RecoveryInput({
    required this.sleepHours,
    required this.fatigue,
    required this.soreness,
    required this.motivation,
    this.jointPain = false,
    this.painArea,
    this.recentPerformanceDrops = 0,
    this.hoursSinceLastSession,
  });
}

class RecoveryResult {
  final int score;
  final Readiness readiness;
  final String label;
  final String recommendation;
  final List<String> factors;

  /// 세트 수 배율(1.0=계획대로)
  final double setMultiplier;

  /// 목표 RIR 가산(0=계획대로)
  final int rirOffset;
  final JointArea? avoidArea;

  const RecoveryResult({
    required this.score,
    required this.readiness,
    required this.label,
    required this.recommendation,
    required this.factors,
    required this.setMultiplier,
    required this.rirOffset,
    this.avoidArea,
  });

  static const disclaimer = '회복 점수는 의료적으로 검증된 진단 지표가 아니라 입력값을 바탕으로 한 앱 자체 추정값입니다.';
}

class RecoveryEngine {
  const RecoveryEngine();

  RecoveryResult analyze(RecoveryInput i) {
    var score = 100.0;
    final f = <String>[];
    if (i.sleepHours < 5) {
      score -= 25;
      f.add('수면 ${i.sleepHours}시간: 매우 부족');
    } else if (i.sleepHours < 6) {
      score -= 15;
      f.add('수면 ${i.sleepHours}시간: 부족');
    } else if (i.sleepHours < 7) {
      score -= 5;
      f.add('수면 ${i.sleepHours}시간: 약간 부족');
    }
    if (i.fatigue >= 3) {
      score -= (i.fatigue - 1) * 7;
      f.add('피로도 ${i.fatigue}/5');
    }
    if (i.soreness >= 3) {
      score -= (i.soreness - 1) * 6;
      f.add('근육통 ${i.soreness}/5');
    }
    if (i.motivation <= 3) {
      score -= (5 - i.motivation) * 4;
      f.add('운동 의욕 ${i.motivation}/5');
    }
    if (i.jointPain) {
      score -= 15;
      f.add('관절 통증 있음${i.painArea != null ? '(${i.painArea!.ko})' : ''}');
    }
    if (i.recentPerformanceDrops > 0) {
      score -= (i.recentPerformanceDrops * 5).clamp(0, 20);
      f.add('최근 수행 능력이 떨어진 운동 ${i.recentPerformanceDrops}개');
    }
    if (i.hoursSinceLastSession != null && i.hoursSinceLastSession! < 20) {
      score -= 5;
      f.add('마지막 운동 후 ${i.hoursSinceLastSession!.round()}시간');
    }
    final s = score.round().clamp(0, 100);
    if (s >= 75) {
      return RecoveryResult(
        score: s,
        readiness: Readiness.good,
        label: '양호',
        recommendation: '계획된 운동을 정상적으로 진행하세요.',
        factors: f,
        setMultiplier: 1,
        rirOffset: 0,
        avoidArea: i.jointPain ? i.painArea : null,
      );
    }
    if (s >= 55) {
      return RecoveryResult(
        score: s,
        readiness: Readiness.caution,
        label: '주의',
        recommendation: '계획대로 진행하되 목표 RIR을 1 높여(조금 더 여유 있게) 수행하고, 오늘은 중량 증가를 서두르지 않는 것을 권장합니다.',
        factors: f,
        setMultiplier: 1,
        rirOffset: 1,
        avoidArea: i.jointPain ? i.painArea : null,
      );
    }
    if (s >= 40) {
      return RecoveryResult(
        score: s,
        readiness: Readiness.low,
        label: '회복 부족 가능성',
        recommendation: '최근 수행 기록과 피로도를 고려해 오늘은 운동량을 약 1/3 줄이는 방안을 제안합니다. 줄인 운동량으로도 단기간 성과는 대부분 유지될 수 있습니다.',
        factors: f,
        setMultiplier: 0.67,
        rirOffset: 1,
        avoidArea: i.jointPain ? i.painArea : null,
      );
    }
    return RecoveryResult(
      score: s,
      readiness: Readiness.rest,
      label: '회복 권장',
      recommendation: '오늘은 휴식하거나 가벼운 활동(걷기, 가벼운 스트레칭)을 권장합니다. 운동한다면 세트를 절반으로 줄이고 여유 있게 수행하세요.',
      factors: f,
      setMultiplier: 0.5,
      rirOffset: 2,
      avoidArea: i.jointPain ? i.painArea : null,
    );
  }
}
