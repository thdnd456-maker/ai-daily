import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../app/widgets.dart';
import '../../data/db/database.dart';
import '../../data/repository.dart';
import '../../domain/catalog/nutrition_catalog.dart';
import '../../domain/engines/nutrition_engine.dart';
import 'diet_screen.dart';

const mealSlots = <(String, String)>[('breakfast', '아침'), ('lunch', '점심'), ('dinner', '저녁'), ('snack', '간식')];

/// 지금 단계·목표로 만든 식단 계획
final nutritionPlanProvider = FutureProvider<NutritionPlan?>((ref) async {
  final profile = await ref.watch(profileProvider.future);
  final prefs = await ref.watch(dietPrefsProvider.future);
  if (profile == null) return null;
  return buildNutritionPlan(profile, level: prefs.$1, phase: prefs.$2);
});

/// 고른 날짜를 포함한 최근 7일 식사 기록
final mealWeekProvider = FutureProvider.family<List<MealLog>, DateTime>((ref, day) {
  ref.watch(dataVersionProvider);
  return ref.read(repositoryProvider).mealsBetween(day.subtract(const Duration(days: 6)), day);
});

final recentMealsProvider = FutureProvider<List<MealLog>>((ref) {
  ref.watch(dataVersionProvider);
  return ref.read(repositoryProvider).recentMeals();
});

/// 하단 메뉴 「식단」 탭: 오늘 기록 | 내 계획
class DietTab extends StatelessWidget {
  const DietTab({super.key});
  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 2,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('식단'),
        bottom: const TabBar(
          indicatorColor: GymColors.accent,
          labelColor: GymColors.accent,
          unselectedLabelColor: GymColors.textDim,
          tabs: [
            Tab(text: '오늘 기록'),
            Tab(text: '내 계획'),
          ],
        ),
      ),
      body: const TabBarView(children: [MealLogView(), DietPlanView()]),
    ),
  );
}

class MealLogView extends ConsumerStatefulWidget {
  const MealLogView({super.key});
  @override
  ConsumerState<MealLogView> createState() => _MealLogViewState();
}

class _MealLogViewState extends ConsumerState<MealLogView> {
  DateTime _day = GymRepository.dayOf(DateTime.now());

  void _shift(int days) {
    final next = _day.add(Duration(days: days));
    if (next.isAfter(GymRepository.dayOf(DateTime.now()))) return;
    setState(() => _day = next);
  }

  @override
  Widget build(BuildContext context) {
    final plan = ref.watch(nutritionPlanProvider).value;
    final week = ref.watch(mealWeekProvider(_day)).value;
    final sessions = ref.watch(completedSessionsProvider).value ?? const [];
    final live = ref.watch(inProgressSessionProvider).value;
    if (plan == null || week == null) return const Center(child: CircularProgressIndicator());

    final today = week.where((m) => m.date == _day).toList();
    final trained = (live != null && GymRepository.dayOf(live.startedAt) == _day) || sessions.any((s) => GymRepository.dayOf(s.row.startedAt) == _day);
    final target = plan.level == DietLevel.expert ? (trained ? plan.trainingDay! : plan.restDay!) : plan.day;
    final isToday = _day == GymRepository.dayOf(DateTime.now());

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Row(
          children: [
            IconButton(onPressed: () => _shift(-1), icon: const Icon(Icons.chevron_left), tooltip: '전날'),
            Expanded(
              child: Text(
                isToday ? '오늘 (${DateFormat('M월 d일 E', 'ko_KR').format(_day)})' : DateFormat('M월 d일 EEEE', 'ko_KR').format(_day),
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
            IconButton(onPressed: isToday ? null : () => _shift(1), icon: const Icon(Icons.chevron_right), tooltip: '다음 날'),
          ],
        ),
        _TotalsCard(eaten: today, target: target, plan: plan, trained: trained),
        for (final (key, label) in mealSlots) _MealSection(day: _day, slot: key, label: label, items: today.where((m) => m.meal == key).toList()),
        const SectionTitle('최근 7일'),
        _WeekCard(day: _day, week: week, plan: plan),
      ],
    );
  }
}

double _sum(List<MealLog> l, double Function(MealLog) f) => l.fold(0.0, (a, m) => a + f(m));

class _TotalsCard extends StatelessWidget {
  final List<MealLog> eaten;
  final MacroDay target;
  final NutritionPlan plan;
  final bool trained;
  const _TotalsCard({required this.eaten, required this.target, required this.plan, required this.trained});

  @override
  Widget build(BuildContext context) {
    final kcal = _sum(eaten, (m) => m.kcal);
    final left = target.kcal - kcal;
    final showMacros = plan.level == DietLevel.intermediate || plan.level == DietLevel.expert;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: '${kcal.round()}', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
                        TextSpan(text: ' / ${target.kcal}kcal', style: const TextStyle(color: GymColors.textDim, fontSize: 15)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                left >= 0 ? '${left.round()} 남음' : '${(-left).round()} 초과',
                style: TextStyle(color: left >= 0 ? GymColors.accent : GymColors.warn, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _Bar(value: kcal, goal: target.kcal.toDouble()),
          const SizedBox(height: 14),
          _MacroRow(label: '단백질', value: _sum(eaten, (m) => m.proteinG), goal: target.proteinG, minGoal: true),
          if (showMacros) ...[
            _MacroRow(label: '탄수화물', value: _sum(eaten, (m) => m.carbsG), goal: target.carbsG),
            _MacroRow(label: '지방', value: _sum(eaten, (m) => m.fatG), goal: target.fatG),
          ],
          Text(
            '${plan.phase.ko} · ${plan.level.ko} 단계${plan.level == DietLevel.expert ? (trained ? ' · 운동일 목표' : ' · 휴식일 목표') : ''}',
            style: const TextStyle(color: GymColors.textDim, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double value;
  final double goal;
  const _Bar({required this.value, required this.goal});
  @override
  Widget build(BuildContext context) {
    final r = goal <= 0 ? 0.0 : value / goal;
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LinearProgressIndicator(
        value: r.clamp(0, 1).toDouble(),
        minHeight: 8,
        backgroundColor: GymColors.surface2,
        color: r > 1.1 ? GymColors.warn : GymColors.accent,
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  final String label;
  final double value;
  final int goal;

  /// 단백질처럼 "이상" 채우는 것이 목표인 값
  final bool minGoal;
  const _MacroRow({required this.label, required this.value, required this.goal, this.minGoal = false});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            const Spacer(),
            Text('${value.round()} / ${goal}g${minGoal && value >= goal ? ' ✓' : ''}', style: const TextStyle(fontSize: 13)),
          ],
        ),
        const SizedBox(height: 4),
        _Bar(value: value, goal: goal.toDouble()),
      ],
    ),
  );
}

class _MealSection extends ConsumerWidget {
  final DateTime day;
  final String slot;
  final String label;
  final List<MealLog> items;
  const _MealSection({required this.day, required this.slot, required this.label, required this.items});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kcal = _sum(items, (m) => m.kcal);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 4, 0),
              child: Row(
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(width: 8),
                  if (items.isNotEmpty) Text('${kcal.round()}kcal', style: const TextStyle(color: GymColors.textDim, fontSize: 13)),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => showAddFoodSheet(context, ref, day: day, slot: slot, label: label),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('추가'),
                  ),
                ],
              ),
            ),
            for (final m in items)
              ListTile(
                dense: true,
                title: Text(m.name),
                subtitle: Text('${m.amount.isEmpty ? '' : '${m.amount} · '}단 ${m.proteinG.round()}g'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${m.kcal.round()}kcal'),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18, color: GymColors.textDim),
                      tooltip: '지우기',
                      onPressed: () async {
                        await ref.read(repositoryProvider).deleteMeal(m.id);
                        ref.refreshData();
                      },
                    ),
                  ],
                ),
              ),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text('아직 기록이 없어요', style: TextStyle(color: GymColors.textDim, fontSize: 13)),
              ),
          ],
        ),
      ),
    );
  }
}

class _WeekCard extends StatelessWidget {
  final DateTime day;
  final List<MealLog> week;
  final NutritionPlan plan;
  const _WeekCard({required this.day, required this.week, required this.plan});

  @override
  Widget build(BuildContext context) {
    final days = [for (var i = 6; i >= 0; i--) day.subtract(Duration(days: i))];
    final perDay = {for (final d in days) d: week.where((m) => m.date == d).toList()};
    final logged = days.where((d) => perDay[d]!.isNotEmpty).toList();
    final maxK = [plan.day.kcal.toDouble(), for (final d in days) _sum(perDay[d]!, (m) => m.kcal)].reduce((a, b) => a > b ? a : b);
    final avgK = logged.isEmpty ? 0 : logged.map((d) => _sum(perDay[d]!, (m) => m.kcal)).reduce((a, b) => a + b) / logged.length;
    final avgP = logged.isEmpty ? 0 : logged.map((d) => _sum(perDay[d]!, (m) => m.proteinG)).reduce((a, b) => a + b) / logged.length;
    final proteinDays = logged.where((d) => _sum(perDay[d]!, (m) => m.proteinG) >= plan.day.proteinG * 0.9).length;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 90,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final d in days)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: 64 * (_sum(perDay[d]!, (m) => m.kcal) / maxK).clamp(0.02, 1),
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            color: perDay[d]!.isEmpty ? GymColors.surface2 : (d == day ? GymColors.accent : GymColors.accentDim),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(DateFormat('E', 'ko_KR').format(d), style: const TextStyle(fontSize: 11, color: GymColors.textDim)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (logged.isEmpty)
            const Text('식사를 기록하면 일주일 평균과 목표 달성일이 나와요.', style: TextStyle(color: GymColors.textDim))
          else ...[
            Text('기록한 날 ${logged.length}일 · 평균 ${avgK.round()}kcal (목표 ${plan.day.kcal})', style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text('평균 단백질 ${avgP.round()}g · 단백질 목표 채운 날 $proteinDays일', style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 6),
            Text(
              _weekAdvice(avgK.toDouble(), avgP.toDouble(), logged.length, plan),
              style: const TextStyle(color: GymColors.textDim, fontSize: 12.5, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}

String _weekAdvice(double avgK, double avgP, int days, NutritionPlan plan) {
  if (days < 3) return '3일 이상 기록하면 더 정확하게 볼 수 있어요. 빠짐없이 적는 것이 가장 중요해요.';
  final diff = avgK - plan.day.kcal;
  final parts = <String>[];
  if (avgP < plan.day.proteinG * 0.9) parts.add('단백질이 부족해요. 끼니마다 단백질 식품을 먼저 챙기세요.');
  if (diff.abs() <= plan.day.kcal * 0.1) {
    parts.add('칼로리는 목표 근처로 잘 지키고 있어요.');
  } else if (diff > 0) {
    parts.add('평균 ${diff.round()}kcal 더 드셨어요.${plan.phase == DietPhase.cut ? ' 간식·음료부터 줄여 보세요.' : ''}');
  } else {
    parts.add('평균 ${(-diff).round()}kcal 덜 드셨어요.${plan.phase == DietPhase.gain ? ' 밥 양이나 간식을 조금 늘려 보세요.' : ''}');
  }
  return parts.join(' ');
}

// ───────────────────────── 음식 추가 ─────────────────────────

Future<void> showAddFoodSheet(BuildContext context, WidgetRef ref, {required DateTime day, required String slot, required String label}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: GymColors.surface,
      builder: (ctx) => _AddFoodSheet(day: day, slot: slot, label: label),
    );

class _AddFoodSheet extends ConsumerStatefulWidget {
  final DateTime day;
  final String slot;
  final String label;
  const _AddFoodSheet({required this.day, required this.slot, required this.label});
  @override
  ConsumerState<_AddFoodSheet> createState() => _AddFoodSheetState();
}

class _AddFoodSheetState extends ConsumerState<_AddFoodSheet> {
  String _q = '';

  Future<void> _save({required String name, required String amount, required double kcal, double p = 0, double c = 0, double f = 0}) async {
    await ref.read(repositoryProvider).addMeal(date: widget.day, meal: widget.slot, name: name, amount: amount, kcal: kcal, protein: p, carbs: c, fat: f);
    ref.refreshData();
    if (mounted) {
      Navigator.of(context).pop();
      showSnack(context, '${widget.label}에 「$name」 추가');
    }
  }

  Future<void> _pickFood(FoodItem food) async {
    final times = await showDialog<double>(
      context: context,
      builder: (_) => _AmountDialog(food: food),
    );
    if (times == null) return;
    final t = times == times.roundToDouble() ? times.toInt().toString() : times.toString();
    await _save(
      name: food.name,
      amount: '${food.serving}${times == 1 ? '' : ' × $t'}',
      kcal: food.kcal * times,
      p: food.proteinG * times,
      c: food.carbsG * times,
      f: food.fatG * times,
    );
  }

  @override
  Widget build(BuildContext context) {
    final recent = ref.watch(recentMealsProvider).value ?? const [];
    final q = _q.trim();
    bool match(String s) => q.isEmpty || s.contains(q);
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text('${widget.label}에 추가', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final r = await showDialog<_Custom>(context: context, builder: (_) => const _CustomDialog());
                      if (r != null) await _save(name: r.name, amount: '직접 입력', kcal: r.kcal, p: r.p, c: r.c, f: r.f);
                    },
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('직접 입력'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: const InputDecoration(hintText: '음식 이름 찾기 (예: 닭가슴살, 김밥)', prefixIcon: Icon(Icons.search), isDense: true),
                onChanged: (v) => setState(() => _q = v),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  if (recent.any((m) => match(m.name))) ...[
                    const _GroupTitle('최근 먹은 것'),
                    for (final m in recent.where((m) => match(m.name)))
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.history, size: 20, color: GymColors.textDim),
                        title: Text(m.name),
                        subtitle: Text(m.amount),
                        trailing: Text('${m.kcal.round()}kcal'),
                        onTap: () => _save(name: m.name, amount: m.amount, kcal: m.kcal, p: m.proteinG, c: m.carbsG, f: m.fatG),
                      ),
                  ],
                  for (final (title, foods) in foodGroups)
                    if (foods.any((f) => match(f.name))) ...[
                      _GroupTitle(title),
                      for (final f in foods.where((f) => match(f.name)))
                        ListTile(
                          dense: true,
                          title: Text(f.name),
                          subtitle: Text('${f.serving} · 단 ${f.proteinG}g'),
                          trailing: Text('${f.kcal}kcal'),
                          onTap: () => _pickFood(f),
                        ),
                    ],
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Text('목록에 없으면 「직접 입력」을 누르세요. 포장지의 영양 정보를 그대로 적으면 가장 정확해요.', style: TextStyle(color: GymColors.textDim, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupTitle extends StatelessWidget {
  final String text;
  const _GroupTitle(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 2),
    child: Text(
      text,
      style: const TextStyle(color: GymColors.accent, fontWeight: FontWeight.w800, fontSize: 13),
    ),
  );
}

class _AmountDialog extends StatefulWidget {
  final FoodItem food;
  const _AmountDialog({required this.food});
  @override
  State<_AmountDialog> createState() => _AmountDialogState();
}

class _AmountDialogState extends State<_AmountDialog> {
  double _t = 1;
  @override
  Widget build(BuildContext context) {
    final f = widget.food;
    return AlertDialog(
      title: Text(f.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('기준: ${f.serving}', style: const TextStyle(color: GymColors.textDim)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final v in const [0.5, 1.0, 1.5, 2.0, 3.0])
                ChoiceChip(
                  label: Text(v == 0.5 ? '반' : '${v == v.roundToDouble() ? v.toInt() : v}배'),
                  selected: _t == v,
                  onSelected: (_) => setState(() => _t = v),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '${(f.kcal * _t).round()}kcal · 단 ${(f.proteinG * _t).round()} · 탄 ${(f.carbsG * _t).round()} · 지 ${(f.fatG * _t).round()}g',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text('대략값이에요.', style: TextStyle(color: GymColors.textDim, fontSize: 12)),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
        FilledButton(onPressed: () => Navigator.pop(context, _t), child: const Text('추가')),
      ],
    );
  }
}

class _Custom {
  final String name;
  final double kcal, p, c, f;
  const _Custom(this.name, this.kcal, this.p, this.c, this.f);
}

class _CustomDialog extends StatefulWidget {
  const _CustomDialog();
  @override
  State<_CustomDialog> createState() => _CustomDialogState();
}

class _CustomDialogState extends State<_CustomDialog> {
  final _name = TextEditingController();
  final _kcal = TextEditingController();
  final _p = TextEditingController();
  final _c = TextEditingController();
  final _f = TextEditingController();
  String? _err;

  @override
  void dispose() {
    for (final c in [_name, _kcal, _p, _c, _f]) {
      c.dispose();
    }
    super.dispose();
  }

  double _n(TextEditingController c) => double.tryParse(c.text.trim().replaceAll(',', '.')) ?? 0;

  Widget _field(TextEditingController c, String label, {bool number = true}) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: TextField(
      controller: c,
      keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: InputDecoration(labelText: label, isDense: true),
    ),
  );

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('직접 입력'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _field(_name, '음식 이름', number: false),
          _field(_kcal, '칼로리 (kcal)'),
          _field(_p, '단백질 g (모르면 비워 두기)'),
          _field(_c, '탄수화물 g (모르면 비워 두기)'),
          _field(_f, '지방 g (모르면 비워 두기)'),
          if (_err != null) Text(_err!, style: const TextStyle(color: GymColors.danger)),
        ],
      ),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
      FilledButton(
        onPressed: () {
          final name = _name.text.trim();
          final kcal = _n(_kcal);
          if (name.isEmpty || kcal <= 0) {
            setState(() => _err = '이름과 칼로리를 적어 주세요.');
            return;
          }
          Navigator.pop(context, _Custom(name, kcal, _n(_p), _n(_c), _n(_f)));
        },
        child: const Text('추가'),
      ),
    ],
  );
}
