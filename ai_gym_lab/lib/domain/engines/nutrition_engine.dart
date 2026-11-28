// 식단 계산 엔진 (입문 → 전문가 4단계)
//
// 근거: lib/domain/catalog/nutrition_catalog.dart 의 nutritionReferences 참고.
// - 논문에서 널리 인용되는 범위 안에서 값을 고르고, 범위 안의 정확한 선택(예: 지방 25%)은
//   '앱 기본값'으로 표시합니다. 어떤 공식도 개인의 실제 소모량을 정확히 맞히지 못하므로,
//   중급 이상은 실제 체중 변화로 칼로리를 다시 맞추게 합니다(Hall 2011).

import 'dart:math' as math;

import '../models.dart';

enum DietLevel { beginner, novice, intermediate, expert }

extension DietLevelX on DietLevel {
  String get ko => const {DietLevel.beginner: '입문', DietLevel.novice: '초급', DietLevel.intermediate: '중급', DietLevel.expert: '전문가'}[this]!;

  String get summary => const {
    DietLevel.beginner: '숫자 없이 손바닥으로 양 맞추기 + 기본 습관',
    DietLevel.novice: '하루 칼로리와 단백질만 맞추기',
    DietLevel.intermediate: '단백질·탄수화물·지방(g)을 맞추고 체중 추세로 점검',
    DietLevel.expert: '운동일/휴식일 나누기, 끼니 배분, 체중 추세로 자동 조정',
  }[this]!;

  /// 운동 경력으로 처음 보여 줄 단계를 고릅니다(사용자가 바꿀 수 있음).
  static DietLevel fromExperience(Experience e) => switch (e) {
    Experience.none || Experience.under3m => DietLevel.beginner,
    Experience.m3to6 || Experience.m6to12 => DietLevel.novice,
    Experience.y1to3 => DietLevel.intermediate,
    Experience.y3plus => DietLevel.expert,
  };
}

enum DietPhase { cut, maintain, gain }

extension DietPhaseX on DietPhase {
  String get ko => const {DietPhase.cut: '감량', DietPhase.maintain: '유지', DietPhase.gain: '증량'}[this]!;

  /// 목표와 목표 체중으로 자동 결정합니다.
  static DietPhase fromProfile(UserProfile p) {
    final g = p.primaryGoal;
    if (g == Goal.fatLoss || g == Goal.weightLoss) return DietPhase.cut;
    if (g == Goal.hypertrophy) return DietPhase.gain;
    final t = p.targetWeightKg;
    if (t != null && t < p.weightKg - 2) return DietPhase.cut;
    if (t != null && t > p.weightKg + 2 && g == Goal.strength) return DietPhase.gain;
    return DietPhase.maintain;
  }
}

class MacroDay {
  final int kcal;
  final int proteinG;
  final int carbsG;
  final int fatG;
  const MacroDay({required this.kcal, required this.proteinG, required this.carbsG, required this.fatG});
}

/// 손바닥 분량법(끼니당 개수) — 입문 단계용 실용 방법(앱 기본값)
class HandPortions {
  final int palmsProtein; // 손바닥(두께 포함) = 단백질 식품
  final int fistsVeg; // 주먹 = 채소
  final double cuppedCarbs; // 오목한 손 = 밥·고구마 등
  final int thumbsFat; // 엄지 = 기름·견과류
  const HandPortions(this.palmsProtein, this.fistsVeg, this.cuppedCarbs, this.thumbsFat);
}

class NutritionPlan {
  final DietLevel level;
  final DietPhase phase;
  final int bmr;
  final int tdee;
  final MacroDay day;
  final int meals;
  final int proteinPerMealG;
  final MacroDay? trainingDay;
  final MacroDay? restDay;
  final HandPortions hands;

  /// 목표 체중 변화 범위 (kg/주)
  final double weeklyMinKg;
  final double weeklyMaxKg;
  final bool usedBodyFat;
  final bool floorApplied;
  final List<String> rationale;

  const NutritionPlan({
    required this.level,
    required this.phase,
    required this.bmr,
    required this.tdee,
    required this.day,
    required this.meals,
    required this.proteinPerMealG,
    required this.trainingDay,
    required this.restDay,
    required this.hands,
    required this.weeklyMinKg,
    required this.weeklyMaxKg,
    required this.usedBodyFat,
    required this.floorApplied,
    required this.rationale,
  });
}

/// 운동 일수에 따른 활동 계수 (앱 기본값: 흔히 쓰는 1.2~1.9 범위에서 선택)
double activityFactor(int daysPerWeek) {
  if (daysPerWeek <= 1) return 1.3;
  if (daysPerWeek <= 3) return 1.45;
  if (daysPerWeek <= 5) return 1.55;
  return 1.7;
}

/// 기초대사량: 체지방률을 알면 Katch-McArdle(제지방량 기반), 모르면 Mifflin-St Jeor(1990)
(double, bool) basalMetabolicRate(UserProfile p) {
  final bf = p.bodyFatPct;
  if (bf != null && bf > 3 && bf < 60) {
    final lbm = p.weightKg * (1 - bf / 100);
    return (370 + 21.6 * lbm, true);
  }
  final s = switch (p.sex) {
    Sex.male => 5.0,
    Sex.female => -161.0,
    Sex.other => -78.0, // 남녀 값의 중간
  };
  return (10 * p.weightKg + 6.25 * p.heightCm - 5 * p.age + s, false);
}

/// 단백질 계산에 쓰는 체중. 비만(BMI 30 이상)이면 실제 체중으로 계산할 때 과하게 나오므로 BMI 25 체중을 씁니다.
double proteinReferenceWeight(UserProfile p) {
  final h = p.heightCm / 100;
  final bmi = p.weightKg / (h * h);
  return bmi >= 30 ? 25 * h * h : p.weightKg;
}

NutritionPlan buildNutritionPlan(UserProfile p, {DietLevel? level, DietPhase? phase}) {
  final lv = level ?? DietLevelX.fromExperience(p.experience);
  final ph = phase ?? DietPhaseX.fromProfile(p);
  final why = <String>[];

  final (bmrD, usedBf) = basalMetabolicRate(p);
  final tdee = bmrD * activityFactor(p.daysPerWeek);
  why.add(usedBf ? '기초대사량: 체지방률로 제지방량을 구해 계산(Katch-McArdle)' : '기초대사량: 키·몸무게·나이·성별로 계산(Mifflin-St Jeor 1990)');
  why.add('활동량: 주 ${p.daysPerWeek}회 운동 → 기초대사량 × ${activityFactor(p.daysPerWeek)} (앱 기본값)');

  // 목표 변화 속도
  double minKg, maxKg, kcal;
  switch (ph) {
    case DietPhase.cut:
      // 주당 체중의 0.5~1% 감량 (Helms 2014). 가운데(0.75%)를 목표로, 하루 300kcal ~ 소모량의 25% 사이.
      minKg = -p.weightKg * 0.01;
      maxKg = -p.weightKg * 0.005;
      final deficit = (p.weightKg * 0.0075 * 1100).clamp(300.0, tdee * 0.25);
      kcal = tdee - deficit;
      why.add('감량 속도: 주당 체중의 0.5~1% (Helms 2014) → 하루 약 ${deficit.round()}kcal 덜 먹기');
    case DietPhase.gain:
      // 주당 체중의 0.25~0.5% 증가 (Iraki 2019). 경력이 많을수록 천천히.
      final rate = switch (lv) {
        DietLevel.beginner || DietLevel.novice => 0.0035,
        DietLevel.intermediate => 0.0025,
        DietLevel.expert => 0.002,
      };
      minKg = p.weightKg * 0.001;
      maxKg = p.weightKg * 0.005;
      final surplus = (p.weightKg * rate * 1100).clamp(150.0, 500.0);
      kcal = tdee + surplus;
      why.add('증량 속도: 주당 체중의 0.25~0.5% (Iraki 2019) → 하루 약 ${surplus.round()}kcal 더 먹기');
    case DietPhase.maintain:
      minKg = -p.weightKg * 0.0025;
      maxKg = p.weightKg * 0.0025;
      kcal = tdee;
      why.add('유지: 소모량만큼 먹기');
  }

  // 너무 적게 먹지 않도록 하한 (앱 안전 기본값)
  final floor = math.max(bmrD, switch (p.sex) {
    Sex.male => 1500.0,
    Sex.female => 1200.0,
    Sex.other => 1350.0,
  });
  final floorApplied = kcal < floor;
  if (floorApplied) {
    kcal = floor;
    why.add('안전을 위해 기초대사량·최소 열량 아래로는 내리지 않았습니다');
  }

  // 단백질: 근육 증가 효과는 하루 약 1.6g/kg에서 대부분 얻음(Morton 2018), 감량 중엔 더 높게(Helms 2014, ISSN 2017)
  final refW = proteinReferenceWeight(p);
  final perKg = switch (ph) {
    DietPhase.cut => lv == DietLevel.expert ? 2.2 : 2.0,
    DietPhase.gain => (lv == DietLevel.intermediate || lv == DietLevel.expert) ? 1.8 : 1.6,
    DietPhase.maintain => 1.6,
  };
  final protein = refW * perKg;
  why.add(
    '단백질: 체중 1kg당 ${perKg}g${refW < p.weightKg ? ' (BMI 25 기준 체중 ${refW.toStringAsFixed(0)}kg로 계산)' : ''} — Morton 2018, ISSN 2017${ph == DietPhase.cut ? ', 감량 중 근육 지키기 Helms 2014' : ''}',
  );

  // 지방: 열량의 20~35% 권장 범위 중 25%(감량 22%), 체중 1kg당 최소 0.6g (앱 기본값)
  var fat = math.max(kcal * (ph == DietPhase.cut ? 0.22 : 0.25) / 9, refW * 0.6);
  var carbs = (kcal - protein * 4 - fat * 9) / 4;
  if (carbs < 50) {
    fat = math.max(refW * 0.5, (kcal - protein * 4 - 50 * 4) / 9);
    carbs = math.max(0, (kcal - protein * 4 - fat * 9) / 4);
  }
  why.add('지방: 열량의 약 ${ph == DietPhase.cut ? 22 : 25}% (호르몬·건강을 위해 너무 낮추지 않음), 나머지는 탄수화물');

  final day = MacroDay(kcal: kcal.round(), proteinG: protein.round(), carbsG: carbs.round(), fatG: fat.round());
  final meals = lv == DietLevel.beginner ? 3 : 4;
  // 끼니당 단백질 약 0.4g/kg, 하루 4끼 이상 (Schoenfeld & Aragon 2018)
  final perMeal = math.max(protein / meals, refW * 0.4).round();

  MacroDay? training, rest;
  if (lv == DietLevel.expert) {
    // 운동하는 날 탄수화물을 늘리고 쉬는 날 줄여 주간 합계는 같게 (ACSM 2016: 활동량에 맞춘 탄수화물)
    final n = p.daysPerWeek.clamp(1, 6);
    final up = carbs * 0.15;
    final down = up * n / (7 - n);
    final tc = carbs + up;
    final rc = math.max(0.0, carbs - down);
    training = MacroDay(kcal: (protein * 4 + tc * 4 + fat * 9).round(), proteinG: protein.round(), carbsG: tc.round(), fatG: fat.round());
    rest = MacroDay(kcal: (protein * 4 + rc * 4 + fat * 9).round(), proteinG: protein.round(), carbsG: rc.round(), fatG: fat.round());
    why.add('운동일 탄수화물 +15%, 휴식일은 그만큼 줄여 일주일 합계는 같게 (ACSM 2016, 앱 기본값)');
  }

  final big = p.sex == Sex.male;
  final hands = switch (ph) {
    DietPhase.cut => HandPortions(big ? 2 : 1, 2, big ? 1 : 0.5, 1),
    DietPhase.maintain => HandPortions(big ? 2 : 1, big ? 2 : 1, big ? 2 : 1, big ? 2 : 1),
    DietPhase.gain => HandPortions(big ? 2 : 1, big ? 2 : 1, big ? 3 : 2, big ? 2 : 1),
  };

  return NutritionPlan(
    level: lv,
    phase: ph,
    bmr: bmrD.round(),
    tdee: tdee.round(),
    day: day,
    meals: meals,
    proteinPerMealG: perMeal,
    trainingDay: training,
    restDay: rest,
    hands: hands,
    weeklyMinKg: minKg,
    weeklyMaxKg: maxKg,
    usedBodyFat: usedBf,
    floorApplied: floorApplied,
    rationale: why,
  );
}

enum TrendVerdict { onTrack, tooSlow, tooFast }

class WeightTrend {
  final double kgPerWeek;
  final int spanDays;
  final TrendVerdict verdict;

  /// 권장 칼로리 조정 (kcal/일, + 더 먹기 / - 덜 먹기)
  final int kcalAdjust;
  final String advice;
  const WeightTrend(this.kgPerWeek, this.spanDays, this.verdict, this.kcalAdjust, this.advice);
}

/// 최근 4주 체중 기록으로 주당 변화를 구하고, 목표 범위와 비교합니다.
/// 공식보다 실제 체중 변화가 더 정확하므로(Hall 2011) 2주 이상 기록이 있으면 이것으로 조정합니다.
WeightTrend? weightTrend(List<(DateTime, double)> points, NutritionPlan plan, {DateTime? now}) {
  final t = now ?? DateTime.now();
  final pts = points.where((e) => t.difference(e.$1).inDays <= 28).toList()..sort((a, b) => a.$1.compareTo(b.$1));
  if (pts.length < 2) return null;
  final span = pts.last.$1.difference(pts.first.$1).inHours / 24;
  if (span < 10) return null;
  // 단순 선형 회귀 기울기 (kg/일)
  final xs = [for (final e in pts) e.$1.difference(pts.first.$1).inHours / 24];
  final ys = [for (final e in pts) e.$2];
  final mx = xs.reduce((a, b) => a + b) / xs.length;
  final my = ys.reduce((a, b) => a + b) / ys.length;
  var num = 0.0, den = 0.0;
  for (var i = 0; i < xs.length; i++) {
    num += (xs[i] - mx) * (ys[i] - my);
    den += (xs[i] - mx) * (xs[i] - mx);
  }
  if (den == 0) return null;
  final perWeek = num / den * 7;
  const step = 150; // 한 번에 조금씩 (앱 기본값)
  final p = plan.phase;
  if (perWeek < plan.weeklyMinKg) {
    // 너무 빨리 빠짐(감량) / 줄어드는 중(유지·증량)
    final msg = p == DietPhase.cut ? '너무 빨리 빠지고 있어요. 근육 손실을 막으려면 하루 약 ${step}kcal 더 드세요(탄수화물 위주).' : '체중이 목표보다 덜 늘고 있어요. 하루 약 ${step}kcal 더 드세요.';
    return WeightTrend(perWeek, span.round(), p == DietPhase.cut ? TrendVerdict.tooFast : TrendVerdict.tooSlow, step, msg);
  }
  if (perWeek > plan.weeklyMaxKg) {
    final msg = p == DietPhase.cut ? '감량이 느려요. 하루 약 ${step}kcal 줄여 보세요(탄수화물·지방에서).' : '체중이 목표보다 빨리 늘고 있어요(지방이 붙기 쉬움). 하루 약 ${step}kcal 줄이세요.';
    return WeightTrend(perWeek, span.round(), p == DietPhase.cut ? TrendVerdict.tooSlow : TrendVerdict.tooFast, -step, msg);
  }
  return WeightTrend(perWeek, span.round(), TrendVerdict.onTrack, 0, '목표 속도 안이에요. 지금처럼 유지하세요.');
}
