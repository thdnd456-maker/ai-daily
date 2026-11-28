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

/// 음식 이름으로 그림 찾기 (직접 입력은 기본 그림)
String foodEmoji(String name) {
  for (final (_, foods) in foodGroups) {
    for (final f in foods) {
      if (f.name == name) return f.emoji;
    }
  }
  return '🍽️';
}

/// 하단 메뉴 「식단」 탭
class DietTab extends StatelessWidget {
  const DietTab({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('식단'),
      actions: [
        TextButton.icon(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DietPlanPage())),
          icon: const Icon(Icons.tune, size: 18),
          label: const Text('내 계획'),
        ),
        const SizedBox(width: 4),
      ],
    ),
    body: const MealLogView(),
  );
}

class DietPlanPage extends StatelessWidget {
  const DietPlanPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('내 식단 계획')),
    body: const DietPlanView(),
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
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: [
        Row(
          children: [
            IconButton(onPressed: () => _shift(-1), icon: const Icon(Icons.chevron_left), tooltip: '전날'),
            Expanded(
              child: Text(
                isToday ? '오늘 · ${DateFormat('M월 d일 E', 'ko_KR').format(_day)}' : DateFormat('M월 d일 E', 'ko_KR').format(_day),
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ),
            IconButton(onPressed: isToday ? null : () => _shift(1), icon: const Icon(Icons.chevron_right), tooltip: '다음 날'),
          ],
        ),
        _TotalsCard(eaten: today, target: target, plan: plan, trained: trained),
        for (final MapEntry(key: slot, value: meta) in mealMeta.entries)
          _MealCard(day: _day, slot: slot, meta: meta, plan: plan, target: target, items: today.where((m) => m.meal == slot).toList()),
        const SizedBox(height: 16),
        _WeekCard(day: _day, week: week, plan: plan),
      ],
    );
  }
}

double _sum(List<MealLog> l, double Function(MealLog) f) => l.fold(0.0, (a, m) => a + f(m));

/// 칼로리 원 + 단백질·탄수화물·지방 막대
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
    final r = target.kcal <= 0 ? 0.0 : kcal / target.kcal;
    final showMacros = plan.level == DietLevel.intermediate || plan.level == DietLevel.expert;
    return SectionCard(
      child: Row(
        children: [
          SizedBox(
            width: 112,
            height: 112,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: r.clamp(0, 1).toDouble(),
                    strokeWidth: 10,
                    backgroundColor: GymColors.surface2,
                    color: r > 1.1 ? GymColors.warn : GymColors.accent,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${kcal.round()}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                    Text('/ ${target.kcal}kcal', style: const TextStyle(color: GymColors.textDim, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  left >= 0 ? '${left.round()}kcal 남음' : '${(-left).round()}kcal 초과',
                  style: TextStyle(color: left >= 0 ? GymColors.accent : GymColors.warn, fontWeight: FontWeight.w800, fontSize: 15),
                ),
                const SizedBox(height: 8),
                _MacroRow(label: '단백질', value: _sum(eaten, (m) => m.proteinG), goal: target.proteinG, color: GymColors.info),
                if (showMacros) ...[
                  _MacroRow(label: '탄수', value: _sum(eaten, (m) => m.carbsG), goal: target.carbsG, color: GymColors.accent),
                  _MacroRow(label: '지방', value: _sum(eaten, (m) => m.fatG), goal: target.fatG, color: GymColors.warn),
                ],
                Text(
                  '${plan.phase.ko}${plan.level == DietLevel.expert ? (trained ? ' · 운동일' : ' · 휴식일') : ''}',
                  style: const TextStyle(color: GymColors.textDim, fontSize: 11.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  final String label;
  final double value;
  final int goal;
  final Color color;
  const _MacroRow({required this.label, required this.value, required this.goal, required this.color});
  @override
  Widget build(BuildContext context) {
    final r = goal <= 0 ? 0.0 : value / goal;
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('${value.round()}/${goal}g', style: const TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 3),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: r.clamp(0, 1).toDouble(), minHeight: 5, backgroundColor: GymColors.surface2, color: color),
          ),
        ],
      ),
    );
  }
}

/// 끼니 카드: 그림 · 끼니 목표 · 추천 메뉴(비어 있을 때) · 먹은 것
class _MealCard extends ConsumerWidget {
  final DateTime day;
  final String slot;
  final (String, String, double) meta;
  final NutritionPlan plan;
  final MacroDay target;
  final List<MealLog> items;
  const _MealCard({required this.day, required this.slot, required this.meta, required this.plan, required this.target, required this.items});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (label, emoji, share) = meta;
    final kcal = _sum(items, (m) => m.kcal);
    final goal = (target.kcal * share).round();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 6, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: GymColors.surface2, borderRadius: BorderRadius.circular(14)),
                    child: Text(emoji, style: const TextStyle(fontSize: 28)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                        Text(
                          items.isEmpty ? '목표 약 ${goal}kcal' : '${kcal.round()} / ${goal}kcal',
                          style: TextStyle(color: items.isEmpty ? GymColors.textDim : GymColors.accent, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: '$label 추가',
                    onPressed: () => showAddFoodSheet(context, ref, day: day, slot: slot, label: label),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              if (items.isEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final s in mealSuggestion(slot, plan.phase))
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: GymColors.line),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(s, style: const TextStyle(fontSize: 12.5)),
                      ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 6, left: 2),
                  child: Text('추천 예시', style: TextStyle(color: GymColors.textDim, fontSize: 11)),
                ),
              ],
              for (final m in items)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 52,
                        child: Center(child: Text(foodEmoji(m.name), style: const TextStyle(fontSize: 20))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m.name,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${m.amount.isEmpty ? '' : '${m.amount} · '}단백질 ${m.proteinG.round()}g',
                              style: const TextStyle(color: GymColors.textDim, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Text('${m.kcal.round()}kcal', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      IconButton(
                        visualDensity: VisualDensity.compact,
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
            ],
          ),
        ),
      ),
    );
  }
}

/// 최근 7일 막대 + 한 줄 요약
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
    final goal = plan.day.kcal.toDouble();
    final maxK = [goal * 1.2, for (final d in days) _sum(perDay[d]!, (m) => m.kcal)].reduce((a, b) => a > b ? a : b);
    final avgK = logged.isEmpty ? 0.0 : logged.map((d) => _sum(perDay[d]!, (m) => m.kcal)).reduce((a, b) => a + b) / logged.length;
    final proteinDays = logged.where((d) => _sum(perDay[d]!, (m) => m.proteinG) >= plan.day.proteinG * 0.9).length;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('최근 7일', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final d in days)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: 58 * (_sum(perDay[d]!, (m) => m.kcal) / maxK).clamp(0.03, 1),
                          margin: const EdgeInsets.symmetric(horizontal: 6),
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
          const SizedBox(height: 10),
          Text(
            logged.isEmpty ? '기록하면 일주일 평균이 나와요' : '평균 ${avgK.round()}kcal · 단백질 채운 날 $proteinDays/${logged.length}일',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          if (logged.length >= 3) Text(_weekAdvice(avgK, plan), style: const TextStyle(color: GymColors.textDim, fontSize: 12)),
        ],
      ),
    );
  }
}

String _weekAdvice(double avgK, NutritionPlan plan) {
  final diff = avgK - plan.day.kcal;
  if (diff.abs() <= plan.day.kcal * 0.1) return '👍 목표 근처로 잘 지키고 있어요';
  return diff > 0 ? '하루 평균 ${diff.round()}kcal 많아요' : '하루 평균 ${(-diff).round()}kcal 적어요';
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
                        leading: Text(foodEmoji(m.name), style: const TextStyle(fontSize: 22)),
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
                          leading: Text(f.emoji, style: const TextStyle(fontSize: 22)),
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
      title: Text('${f.emoji}  ${f.name}'),
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
