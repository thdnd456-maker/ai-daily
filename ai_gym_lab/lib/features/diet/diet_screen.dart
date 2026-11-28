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

class DietScreen extends ConsumerWidget {
  const DietScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).value;
    final prefs = ref.watch(dietPrefsProvider).value;
    final ms = ref.watch(measurementsProvider).value ?? const [];
    if (profile == null || prefs == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('식단')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final plan = buildNutritionPlan(profile, level: prefs.$1, phase: prefs.$2);
    final trend = weightTrend([for (final m in ms) if (m.weightKg != null) (m.date, m.weightKg!)], plan);
    final repo = ref.read(repositoryProvider);

    Future<void> save(String key, String? v) async {
      await repo.setSetting(key, v);
      ref.refreshData();
    }

    final lv = plan.level;
    final showGrams = lv != DietLevel.beginner;
    final showMacros = lv == DietLevel.intermediate || lv == DietLevel.expert;

    return Scaffold(
      appBar: AppBar(title: const Text('식단')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          // ── 단계 고르기
          const SectionTitle('내 단계'),
          SegmentedButton<DietLevel>(
            showSelectedIcon: false,
            segments: [for (final l in DietLevel.values) ButtonSegment(value: l, label: Text(l.ko))],
            selected: {lv},
            onSelectionChanged: (s) => save('diet.level', s.first.name),
          ),
          const SizedBox(height: 8),
          Text(lv.summary, style: const TextStyle(color: GymColors.textDim, fontSize: 13)),
          if (prefs.$1 == null) const Text('운동 경력에 맞춰 자동으로 골랐어요. 눌러서 바꿀 수 있어요.', style: TextStyle(color: GymColors.textDim, fontSize: 12)),

          // ── 목표
          const SectionTitle('지금 목표'),
          SegmentedButton<DietPhase>(
            showSelectedIcon: false,
            segments: [for (final p in DietPhase.values) ButtonSegment(value: p, label: Text(p.ko))],
            selected: {plan.phase},
            onSelectionChanged: (s) => save('diet.phase', s.first.name),
          ),
          const SizedBox(height: 8),
          Text(
            prefs.$2 == null ? '프로필의 운동 목표(${profile.primaryGoal.ko})에 맞춰 자동으로 골랐어요.' : '직접 고른 목표예요.',
            style: const TextStyle(color: GymColors.textDim, fontSize: 12),
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

          // ── 오늘 목표
          SectionTitle(showGrams ? '하루 목표' : '끼니마다 이만큼'),
          if (!showGrams) _HandsCard(plan: plan) else _TargetCard(plan: plan, showMacros: showMacros),

          // ── 전문가: 운동일/휴식일
          if (plan.trainingDay != null && plan.restDay != null) ...[
            const SectionTitle('운동하는 날 / 쉬는 날'),
            SectionCard(
              child: Column(
                children: [
                  _DayRow(label: '운동일 (주 ${profile.daysPerWeek.clamp(1, 6)}일)', d: plan.trainingDay!),
                  const Divider(height: 20),
                  _DayRow(label: '휴식일', d: plan.restDay!),
                  const SizedBox(height: 8),
                  const Text('단백질·지방은 같고 탄수화물만 바꿉니다. 일주일 합계는 같아요.', style: TextStyle(color: GymColors.textDim, fontSize: 12)),
                ],
              ),
            ),
          ],

          // ── 중급 이상: 체중 추세
          if (lv == DietLevel.intermediate || lv == DietLevel.expert) ...[
            const SectionTitle('체중 추세로 점검'),
            _TrendCard(plan: plan, trend: trend),
          ],

          // ── 입문: 습관
          if (lv == DietLevel.beginner) ...[
            const SectionTitle('이것부터 하나씩'),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final (i, h) in beginnerHabits.indexed)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${i + 1}. ', style: const TextStyle(fontWeight: FontWeight.w800, color: GymColors.accent)),
                          Expanded(child: Text(h, style: const TextStyle(height: 1.4))),
                        ],
                      ),
                    ),
                  const Text('한 번에 다 하지 말고, 1번이 익숙해지면 2번을 더하세요.', style: TextStyle(color: GymColors.textDim, fontSize: 12)),
                ],
              ),
            ),
          ],

          // ── 하루 예시
          const SectionTitle('하루 예시 (한식)'),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (slot, what) in sampleDay(plan.phase))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 72, child: Text(slot, style: const TextStyle(fontWeight: FontWeight.w800))),
                        Expanded(child: Text(what, style: const TextStyle(height: 1.4))),
                      ],
                    ),
                  ),
                Text(
                  showGrams ? '목표 칼로리에 맞추려면 밥 양으로 조절하세요 (밥 1공기 ≈ 300kcal).' : '배고프면 채소와 단백질부터 더 드세요.',
                  style: const TextStyle(color: GymColors.textDim, fontSize: 12),
                ),
              ],
            ),
          ),

          // ── 전문가 팁
          if (lv == DietLevel.expert) ...[
            const SectionTitle('끼니 타이밍·보충제'),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final t in expertTips)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text('· $t', style: const TextStyle(height: 1.4)),
                    ),
                ],
              ),
            ),
          ],

          // ── 음식표
          if (showGrams) ...[
            const SectionTitle('음식별 영양 (대략)'),
            _FoodTable(title: '단백질 식품', foods: proteinFoods),
            _FoodTable(title: '탄수화물 식품', foods: carbFoods),
            if (showMacros) _FoodTable(title: '지방 식품', foods: fatFoods),
          ],

          // ── 계산 근거
          const SectionTitle('어떻게 계산했나요'),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final r in plan.rationale)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('· $r', style: const TextStyle(height: 1.4, fontSize: 13)),
                  ),
                if (showGrams) Text('기초대사량 ${plan.bmr}kcal · 하루 소모량(추정) ${plan.tdee}kcal', style: const TextStyle(color: GymColors.textDim, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Card(
            clipBehavior: Clip.antiAlias,
            child: ExpansionTile(
              title: Text('참고한 논문 ${nutritionReferences.length}편', style: const TextStyle(fontWeight: FontWeight.w700)),
              children: [
                for (final r in nutritionReferences)
                  ListTile(
                    title: Text(r.keyFindings, style: const TextStyle(fontSize: 13, height: 1.4)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('${r.citation}\n한계: ${r.limitations}', style: const TextStyle(fontSize: 11.5, color: GymColors.research)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '이 화면은 건강한 성인을 위한 일반 안내입니다. 임신·수유 중이거나, 당뇨·신장 질환 등이 있거나, 식사 문제(폭식·거식)를 겪고 있다면 의사나 영양사와 먼저 상의하세요.',
            style: TextStyle(color: GymColors.textDim, fontSize: 12, height: 1.4),
          ),
          if (profile.age < 18)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text('18세 미만은 성장기라 칼로리를 줄이지 말고 골고루 충분히 드세요.', style: TextStyle(color: GymColors.warn, fontSize: 12)),
            ),
        ],
      ),
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
              Expanded(child: StatTile(label: '칼로리', value: '${d.kcal}', sub: 'kcal', color: GymColors.accent)),
              Expanded(child: StatTile(label: '단백질', value: '${d.proteinG}g', sub: '끼니당 약 ${plan.proteinPerMealG}g')),
            ],
          ),
          if (showMacros) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: StatTile(label: '탄수화물', value: '${d.carbsG}g')),
                Expanded(child: StatTile(label: '지방', value: '${d.fatG}g')),
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
      Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))),
      Text('${d.kcal}kcal · 탄 ${d.carbsG}g', style: const TextStyle(color: GymColors.accent, fontWeight: FontWeight.w700)),
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
              Text('→ 새 목표 약 ${plan.day.kcal + t.kcalAdjust}kcal', style: const TextStyle(color: GymColors.accent, fontWeight: FontWeight.w700)),
          ],
        ],
      ),
    );
  }
}

class _FoodTable extends StatelessWidget {
  final String title;
  final List<FoodItem> foods;
  const _FoodTable({required this.title, required this.foods});
  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: ExpansionTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      children: [
        for (final f in foods)
          ListTile(
            dense: true,
            title: Text('${f.name} · ${f.serving}'),
            trailing: Text('단 ${f.proteinG} · 탄 ${f.carbsG} · 지 ${f.fatG}g\n${f.kcal}kcal', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12)),
          ),
      ],
    ),
  );
}
