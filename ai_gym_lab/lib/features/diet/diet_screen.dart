import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../app/widgets.dart';
import '../../domain/catalog/nutrition_catalog.dart';
import '../../domain/engines/nutrition_engine.dart';
import '../../domain/models.dart';

/// 저장된 식단 설정 (단계·목표). null = 자동
final dietPrefsProvider = FutureProvider<(DietLevel?, DietPhase?)>((ref) async {
  ref.watch(dataVersionProvider);
  final repo = ref.read(repositoryProvider);
  final l = await repo.getSetting('diet.level');
  final p = await repo.getSetting('diet.phase');
  return (DietLevel.values.where((e) => e.name == l).firstOrNull, DietPhase.values.where((e) => e.name == p).firstOrNull);
});

/// 「내 계획」: 단계별 목표·예시·근거
class DietPlanView extends ConsumerWidget {
  const DietPlanView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).value;
    final prefs = ref.watch(dietPrefsProvider).value;
    final ms = ref.watch(measurementsProvider).value ?? const [];
    if (profile == null || prefs == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final plan = buildNutritionPlan(profile, level: prefs.$1, phase: prefs.$2);
    final trend = weightTrend([
      for (final m in ms)
        if (m.weightKg != null) (m.date, m.weightKg!),
    ], plan);
    final repo = ref.read(repositoryProvider);

    Future<void> save(String key, String? v) async {
      await repo.setSetting(key, v);
      ref.refreshData();
    }

    final lv = plan.level;
    final showGrams = lv != DietLevel.beginner;
    final showMacros = lv == DietLevel.intermediate || lv == DietLevel.expert;

    Widget fold(String title, List<Widget> children) => Card(
      margin: const EdgeInsets.only(top: 8),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
    Widget line(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(t, style: const TextStyle(height: 1.4, fontSize: 13)),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: [
        const SectionTitle('내 단계'),
        SegmentedButton<DietLevel>(
          showSelectedIcon: false,
          segments: [for (final l in DietLevel.values) ButtonSegment(value: l, label: Text(l.ko))],
          selected: {lv},
          onSelectionChanged: (s) => save('diet.level', s.first.name),
        ),
        const SizedBox(height: 6),
        Text(lv.summary, style: const TextStyle(color: GymColors.textDim, fontSize: 12.5)),
        const SectionTitle('지금 목표'),
        SegmentedButton<DietPhase>(
          showSelectedIcon: false,
          segments: [for (final p in DietPhase.values) ButtonSegment(value: p, label: Text(p.ko))],
          selected: {plan.phase},
          onSelectionChanged: (s) => save('diet.phase', s.first.name),
        ),
        if (prefs.$1 != null || prefs.$2 != null)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () async {
                await repo.setSetting('diet.level', null);
                await repo.setSetting('diet.phase', null);
                ref.refreshData();
              },
              child: const Text('자동으로 되돌리기'),
            ),
          ),

        SectionTitle(showGrams ? '하루 목표' : '끼니마다 이만큼'),
        if (!showGrams) _HandsCard(plan: plan) else _TargetCard(plan: plan, showMacros: showMacros),

        if (plan.trainingDay != null && plan.restDay != null) ...[
          const SizedBox(height: 8),
          SectionCard(
            child: Column(
              children: [
                _DayRow(label: '🏋️ 운동일', d: plan.trainingDay!),
                const Divider(height: 18),
                _DayRow(label: '😴 휴식일', d: plan.restDay!),
              ],
            ),
          ),
        ],

        if (lv == DietLevel.intermediate || lv == DietLevel.expert) ...[const SectionTitle('체중 추세'), _TrendCard(plan: plan, trend: trend)],

        const SizedBox(height: 8),
        if (lv == DietLevel.beginner) fold('✅ 습관 ${beginnerHabits.length}가지', [for (final (i, h) in beginnerHabits.indexed) line('${i + 1}. $h')]),
        if (lv == DietLevel.expert) fold('⏱️ 타이밍 · 보충제', [for (final t in expertTips) line('· $t')]),
        if (showGrams)
          fold('🍽️ 음식별 영양', [
            for (final (title, foods) in foodGroups) ...[
              Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 4),
                child: Text(
                  title,
                  style: const TextStyle(color: GymColors.accent, fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ),
              for (final f in foods)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Text(f.emoji),
                      const SizedBox(width: 8),
                      Expanded(child: Text('${f.name} · ${f.serving}', style: const TextStyle(fontSize: 13))),
                      Text('${f.kcal}kcal · 단 ${f.proteinG}g', style: const TextStyle(fontSize: 12, color: GymColors.textDim)),
                    ],
                  ),
                ),
            ],
          ]),
        fold('📐 계산 근거', [for (final r in plan.rationale) line('· $r'), if (showGrams) line('기초대사량 ${plan.bmr}kcal · 하루 소모량(추정) ${plan.tdee}kcal')]),
        fold('📚 참고 논문 ${nutritionReferences.length}편', [
          for (final r in nutritionReferences)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.keyFindings, style: const TextStyle(fontSize: 13, height: 1.4)),
                  Text(r.citation, style: const TextStyle(fontSize: 11.5, color: GymColors.research)),
                ],
              ),
            ),
        ]),
        const SizedBox(height: 12),
        Text(
          profile.age < 18 ? '18세 미만은 칼로리를 줄이지 말고 골고루 충분히 드세요.' : '임신 중이거나 질환이 있으면 의사와 먼저 상의하세요.',
          style: TextStyle(color: profile.age < 18 ? GymColors.warn : GymColors.textDim, fontSize: 12),
        ),
      ],
    );
  }
}

class _HandsCard extends StatelessWidget {
  final NutritionPlan plan;
  const _HandsCard({required this.plan});
  @override
  Widget build(BuildContext context) {
    final h = plan.hands;
    String n(num v) => v == 0.5 ? '반' : (v % 1 == 0 ? '${v.toInt()}' : '$v');
    final rows = [
      ('✋', '단백질', '손바닥 ${n(h.palmsProtein)}개', '고기·생선·달걀·두부 (손바닥 크기·두께)'),
      ('✊', '채소', '주먹 ${n(h.fistsVeg)}개', '나물·샐러드·버섯·김치'),
      ('🤲', '탄수화물', '오목한 손 ${n(h.cuppedCarbs)}개', '밥·고구마·과일 (오목한 손 1개 ≈ 밥 1/3공기)'),
      ('👍', '지방', '엄지 ${n(h.thumbsFat)}개', '기름·견과류·치즈'),
    ];
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (icon, what, amount, ex) in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Text(icon, style: const TextStyle(fontSize: 26)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$what  $amount', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        Text(ex, style: const TextStyle(color: GymColors.textDim, fontSize: 12.5)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Text('하루 ${plan.meals}끼 기준이에요. 숫자를 세지 않아도 되는 방법이라 처음 시작하기 좋아요.', style: const TextStyle(color: GymColors.textDim, fontSize: 12)),
          const SizedBox(height: 4),
          const EvidenceBadge(EvidenceKind.appDefault),
        ],
      ),
    );
  }
}

class _TargetCard extends StatelessWidget {
  final NutritionPlan plan;
  final bool showMacros;
  const _TargetCard({required this.plan, required this.showMacros});
  @override
  Widget build(BuildContext context) {
    final d = plan.day;
    final perMealCarbs = (d.carbsG / plan.meals).round();
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: StatTile(label: '칼로리', value: '${d.kcal}', sub: 'kcal', color: GymColors.accent),
              ),
              Expanded(
                child: StatTile(label: '단백질', value: '${d.proteinG}g', sub: '끼니당 약 ${plan.proteinPerMealG}g'),
              ),
            ],
          ),
          if (showMacros) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: StatTile(label: '탄수화물', value: '${d.carbsG}g'),
                ),
                Expanded(
                  child: StatTile(label: '지방', value: '${d.fatG}g'),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          Text('끼니 하나 예시 (하루 ${plan.meals}끼)', style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(mealExample(plan.proteinPerMealG, perMealCarbs), style: const TextStyle(height: 1.4)),
          if (plan.floorApplied) ...[
            const SizedBox(height: 8),
            const Text('너무 적게 먹지 않도록 최소 열량으로 맞췄어요.', style: TextStyle(color: GymColors.warn, fontSize: 12)),
          ],
        ],
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  final String label;
  final MacroDay d;
  const _DayRow({required this.label, required this.d});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      Text(
        '${d.kcal}kcal · 탄 ${d.carbsG}g',
        style: const TextStyle(color: GymColors.accent, fontWeight: FontWeight.w700),
      ),
    ],
  );
}

class _TrendCard extends StatelessWidget {
  final NutritionPlan plan;
  final WeightTrend? trend;
  const _TrendCard({required this.plan, required this.trend});
  @override
  Widget build(BuildContext context) {
    String kg(double v) => '${v >= 0 ? '+' : ''}${v.toStringAsFixed(2)}kg';
    final t = trend;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('목표 속도: 주당 ${kg(plan.weeklyMinKg)} ~ ${kg(plan.weeklyMaxKg)}', style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (t == null)
            const Text('「기록」 탭에 체중을 2주 이상(최소 2번) 적으면, 실제 변화로 칼로리를 다시 맞춰 드려요.', style: TextStyle(color: GymColors.textDim, height: 1.4))
          else ...[
            Text(
              '최근 ${t.spanDays}일: 주당 ${kg(t.kgPerWeek)}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: t.verdict == TrendVerdict.onTrack ? GymColors.accent : GymColors.warn),
            ),
            const SizedBox(height: 4),
            Text(t.advice, style: const TextStyle(height: 1.4)),
            if (t.kcalAdjust != 0)
              Text(
                '→ 새 목표 약 ${plan.day.kcal + t.kcalAdjust}kcal',
                style: const TextStyle(color: GymColors.accent, fontWeight: FontWeight.w700),
              ),
          ],
        ],
      ),
    );
  }
}
