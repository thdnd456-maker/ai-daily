import 'package:ai_gym_lab/app/providers.dart';
import 'package:ai_gym_lab/app/theme.dart';
import 'package:ai_gym_lab/data/db/database.dart';
import 'package:ai_gym_lab/data/repository.dart';
import 'package:ai_gym_lab/domain/catalog/nutrition_catalog.dart';
import 'package:ai_gym_lab/domain/engines/nutrition_engine.dart';
import 'package:ai_gym_lab/domain/models.dart';
import 'package:ai_gym_lab/features/diet/diet_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'ui_tour_test.dart' show settle;

void main() {
  const man = UserProfile(sex: Sex.male, age: 30, heightCm: 175, weightKg: 80, goals: [Goal.hypertrophy], experience: Experience.y1to3, daysPerWeek: 4);

  test('Mifflin-St Jeor 기초대사량 (남 80kg·175cm·30세 = 1749kcal)', () {
    final (bmr, usedBf) = basalMetabolicRate(man);
    expect(usedBf, isFalse);
    expect(bmr, closeTo(1748.75, 0.01));
    // 체지방률이 있으면 제지방량 공식
    final (bmr2, used2) = basalMetabolicRate(man.copyWith(bodyFatPct: 20));
    expect(used2, isTrue);
    expect(bmr2, closeTo(370 + 21.6 * 64, 0.01));
  });

  test('목표와 경력으로 단계·목표가 자동으로 정해진다', () {
    expect(DietLevelX.fromExperience(Experience.none), DietLevel.beginner);
    expect(DietLevelX.fromExperience(Experience.y3plus), DietLevel.expert);
    expect(DietPhaseX.fromProfile(man), DietPhase.gain);
    expect(DietPhaseX.fromProfile(man.copyWith(goals: [Goal.fatLoss])), DietPhase.cut);
    expect(DietPhaseX.fromProfile(man.copyWith(goals: [Goal.health])), DietPhase.maintain);
  });

  test('증량: 소모량보다 많이, 단백질 1.8g/kg, 열량 합계가 맞다', () {
    final p = buildNutritionPlan(man);
    expect(p.phase, DietPhase.gain);
    expect(p.day.kcal, greaterThan(p.tdee));
    expect(p.day.proteinG, (80 * 1.8).round());
    final sum = p.day.proteinG * 4 + p.day.carbsG * 4 + p.day.fatG * 9;
    expect((sum - p.day.kcal).abs(), lessThan(15));
  });

  test('감량: 주당 0.5~1% 범위, 단백질 2.0g/kg 이상, 최소 열량 아래로 안 내려감', () {
    final p = buildNutritionPlan(man.copyWith(goals: [Goal.fatLoss]), level: DietLevel.novice);
    expect(p.day.kcal, lessThan(p.tdee));
    expect(p.day.proteinG, greaterThanOrEqualTo(160));
    expect(p.weeklyMinKg, closeTo(-0.8, 0.001));
    expect(p.weeklyMaxKg, closeTo(-0.4, 0.001));
    // 작은 여성: 하한 적용
    const small = UserProfile(sex: Sex.female, age: 55, heightCm: 150, weightKg: 48, goals: [Goal.weightLoss], daysPerWeek: 1);
    final q = buildNutritionPlan(small);
    expect(q.day.kcal, greaterThanOrEqualTo(1200));
    expect(q.day.kcal, greaterThanOrEqualTo(q.bmr));
    expect(q.day.carbsG, greaterThanOrEqualTo(0));
  });

  test('비만이면 단백질은 BMI 25 기준 체중으로 계산', () {
    const big = UserProfile(sex: Sex.male, heightCm: 170, weightKg: 110, goals: [Goal.fatLoss]);
    final p = buildNutritionPlan(big, level: DietLevel.novice);
    expect(p.day.proteinG, (25 * 1.7 * 1.7 * 2.0).round());
  });

  test('전문가: 운동일은 탄수화물이 더 많고 일주일 합계는 같다', () {
    final p = buildNutritionPlan(man, level: DietLevel.expert);
    final t = p.trainingDay!, r = p.restDay!;
    expect(t.carbsG, greaterThan(r.carbsG));
    final week = t.carbsG * 4 + r.carbsG * 3;
    expect((week - p.day.carbsG * 7).abs(), lessThanOrEqualTo(4));
    expect(buildNutritionPlan(man, level: DietLevel.intermediate).trainingDay, isNull);
  });

  test('체중 추세: 감량이 느리면 줄이라고, 2주 미만이면 판단 안 함', () {
    final now = DateTime(2026, 11, 28);
    final p = buildNutritionPlan(man.copyWith(goals: [Goal.fatLoss]));
    // 3주 동안 0.1kg/주만 빠짐 → 너무 느림
    final slow = [for (var d = 0; d <= 21; d += 3) (now.subtract(Duration(days: 21 - d)), 80 - d / 7 * 0.1)];
    final t = weightTrend(slow, p, now: now)!;
    expect(t.kgPerWeek, closeTo(-0.1, 0.01));
    expect(t.verdict, TrendVerdict.tooSlow);
    expect(t.kcalAdjust, lessThan(0));
    // 주당 0.6kg 감량 → 목표 안
    final ok = [for (var d = 0; d <= 14; d += 2) (now.subtract(Duration(days: 14 - d)), 80 - d / 7 * 0.6)];
    expect(weightTrend(ok, p, now: now)!.verdict, TrendVerdict.onTrack);
    // 기간이 짧으면 null
    expect(weightTrend([(now.subtract(const Duration(days: 5)), 80), (now, 79)], p, now: now), isNull);
  });

  test('끼니 예시 문구', () {
    expect(mealExample(31, 65), contains('닭가슴살 약 100g'));
    expect(mealExample(31, 65), contains('밥 1공기'));
    expect(nutritionReferences.map((r) => r.id).toSet().length, nutritionReferences.length);
  });

  testWidgets('식단 화면: 4단계 모두 오류 없이 보인다 (360pt 폭)', (t) async {
    t.view.physicalSize = const Size(1080, 2400);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    late GymRepository repo;
    await t.runAsync(() async {
      repo = GymRepository(AppDatabase(NativeDatabase.memory()));
      await repo.init();
      await repo.saveProfile(man);
    });
    await t.pumpWidget(
      ProviderScope(
        overrides: [repositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(theme: buildTheme(), home: const DietScreen()),
      ),
    );
    await settle(t);
    expect(find.text('하루 목표'), findsOneWidget); // 1~3년 → 중급
    expect(find.text('체중 추세로 점검'), findsOneWidget);

    await t.tap(find.text('입문'));
    await settle(t);
    expect(find.text('끼니마다 이만큼'), findsOneWidget);
    expect(find.text('이것부터 하나씩'), findsOneWidget);

    await t.tap(find.text('전문가'));
    await settle(t);
    await t.scrollUntilVisible(find.text('운동하는 날 / 쉬는 날'), 200);
    expect(find.text('운동하는 날 / 쉬는 날'), findsOneWidget);

    await t.scrollUntilVisible(find.text('자동으로 되돌리기'), -200);
    await t.tap(find.text('감량'));
    await settle(t);
    await t.scrollUntilVisible(find.text('초급'), -200);
    await t.tap(find.text('초급'));
    await settle(t);
    expect(find.text('하루 목표'), findsOneWidget);
    expect(find.text('체중 추세로 점검'), findsNothing);
    expect(t.takeException(), isNull);
    await t.runAsync(() => repo.db.close());
  });
}
