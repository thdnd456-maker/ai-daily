import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../app/widgets.dart';
import '../../domain/engines/program_generator.dart';
import '../../domain/models.dart';
import '../program/program_review_screen.dart';

/// 최초 실행: 시작 화면 → 기본 정보 → 운동 목표 → 경험 → 일정 → 환경/기구 → 신체 상태 → 프로그램 추천
/// editMode: 설정에서 프로필 수정
class OnboardingScreen extends ConsumerStatefulWidget {
  final UserProfile? initial;
  final bool editMode;
  const OnboardingScreen({super.key, this.initial, this.editMode = false});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pc;
  int _page = 0;
  late Sex _sex;
  final _age = TextEditingController(), _height = TextEditingController(), _weight = TextEditingController();
  final _target = TextEditingController(), _fat = TextEditingController(), _smm = TextEditingController();
  final _customMin = TextEditingController();
  late List<Goal> _goals;
  late Experience _exp;
  late int _days;
  late int _minutes;
  late GymEnvironment _env;
  late Set<Equipment> _equipment;
  final Map<JointArea, Limitation> _lims = {};
  bool _noIssue = true;

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    _sex = p?.sex ?? Sex.male;
    _age.text = p == null ? '' : '${p.age}';
    _height.text = p == null ? '' : _num(p.heightCm);
    _weight.text = p == null ? '' : _num(p.weightKg);
    _target.text = p?.targetWeightKg == null ? '' : _num(p!.targetWeightKg!);
    _fat.text = p?.bodyFatPct == null ? '' : _num(p!.bodyFatPct!);
    _smm.text = p?.skeletalMuscleKg == null ? '' : _num(p!.skeletalMuscleKg!);
    _goals = [...?p?.goals];
    _exp = p?.experience ?? Experience.none;
    _days = p?.daysPerWeek ?? 3;
    _minutes = p?.sessionMinutes ?? 60;
    _env = p?.environment ?? GymEnvironment.standardGym;
    _equipment = p == null || p.equipment.isEmpty ? _env.defaultEquipment : {...p.equipment};
    for (final l in p?.limitations ?? const <Limitation>[]) {
      _lims[l.area] = l;
    }
    _noIssue = _lims.isEmpty;
    if (![30, 45, 60, 75, 90].contains(_minutes)) _customMin.text = '$_minutes';
    _page = widget.editMode ? 1 : 0;
    _pc = PageController(initialPage: _page);
  }

  static String _num(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  static const _titles = ['', '기본 정보', '운동 목적', '운동 경험', '운동 가능 시간', '운동 환경', '신체 상태'];

  String? _validate() {
    switch (_page) {
      case 1:
        final age = int.tryParse(_age.text), h = double.tryParse(_height.text), w = double.tryParse(_weight.text);
        if (age == null || age < 14 || age > 90) return '나이를 확인하세요 (14~90).';
        if (h == null || h < 120 || h > 230) return '키를 확인하세요 (cm).';
        if (w == null || w < 30 || w > 250) return '체중을 확인하세요 (kg).';
      case 2:
        if (_goals.isEmpty) return '운동 목적을 하나 이상 선택하세요.';
      case 4:
        if (_customMin.text.isNotEmpty) {
          final m = int.tryParse(_customMin.text);
          if (m == null || m < 15 || m > 180) return '운동 시간은 15~180분으로 입력하세요.';
        }
      case 5:
        if (_equipment.isEmpty) return '사용 가능한 기구를 선택하세요.';
    }
    return null;
  }

  void _next() {
    final err = _validate();
    if (err != null) return showSnack(context, err);
    if (_page == 6) {
      _finish();
      return;
    }
    _pc.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  UserProfile _profile() => UserProfile(
    sex: _sex,
    age: int.tryParse(_age.text) ?? 30,
    heightCm: double.tryParse(_height.text) ?? 170,
    weightKg: double.tryParse(_weight.text) ?? 70,
    targetWeightKg: double.tryParse(_target.text),
    bodyFatPct: double.tryParse(_fat.text),
    skeletalMuscleKg: double.tryParse(_smm.text),
    goals: _goals,
    experience: _exp,
    daysPerWeek: _days,
    sessionMinutes: int.tryParse(_customMin.text) ?? _minutes,
    environment: _env,
    equipment: _equipment,
    limitations: _noIssue ? const [] : _lims.values.toList(),
  );

  Future<void> _finish() async {
    final repo = ref.read(repositoryProvider);
    final p = _profile();
    await repo.saveProfile(p);
    if (!mounted) return;
    if (!widget.editMode) {
      // 최초 실행: 프로필 저장 → 루트 화면이 추천 프로그램 확인 화면으로 전환됨
      ref.refreshData();
      return;
    }
    {
      final regen = await confirm(context, '프로필 저장됨', '바뀐 정보로 새 추천 프로그램을 생성할까요?\n기존 프로그램과 기록은 보존됩니다.', ok: '새 프로그램 보기');
      if (!mounted) return;
      if (!regen) {
        ref.refreshData();
        Navigator.pop(context);
        return;
      }
    }
    final plan = ProgramGenerator(repo.exerciseList).generate(p);
    if (!mounted) return;
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProgramReviewScreen(plan: plan, isNew: true)));
    if (!mounted) return;
    if (widget.editMode && Navigator.canPop(context)) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _page == 0
          ? null
          : AppBar(
              title: Text(_titles[_page]),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (widget.editMode && _page == 1) {
                    Navigator.pop(context);
                  } else if (_page > 0) {
                    _pc.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
                  }
                },
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(4),
                child: LinearProgressIndicator(value: _page / 6, color: GymColors.accent, backgroundColor: GymColors.line),
              ),
            ),
      // 버튼을 본문 안에 두어 키보드가 올라와도 가려지지 않게 함
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pc,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                children: [_welcome(), _basic(), _goalsPage(), _expPage(), _schedule(), _envPage(), _bodyPage()],
              ),
            ),
            if (_page > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(onPressed: _next, child: Text(_page == 6 ? (widget.editMode ? '저장' : '내 프로그램 만들기') : '다음')),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _pad(List<Widget> c) => ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), children: c);

  Widget _welcome() => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      children: [
        // 작은 화면·큰 글씨에서도 「시작하기」 버튼이 항상 보이도록 내용만 스크롤
        Expanded(
          child: LayoutBuilder(
            builder: (context, box) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: box.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      const Icon(Icons.fitness_center, size: 56, color: GymColors.accent),
                      const SizedBox(height: 16),
                      const Text('AI GYM LAB', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      const SizedBox(height: 8),
                      const Text('운동과학 기반 개인 맞춤형 트레이너', style: TextStyle(fontSize: 17, color: GymColors.textDim)),
                      const SizedBox(height: 28),
                      for (final t in ['오늘 할 운동·중량·반복·세트를 바로 확인', '기록할수록 다음 운동이 자동으로 조정', '추천 이유와 연구 근거를 투명하게 표시', '인터넷 없이도 기록과 자동 추천이 동작'])
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: GymColors.accent, size: 20),
                              const SizedBox(width: 10),
                              Expanded(child: Text(t, style: const TextStyle(fontSize: 15))),
                            ],
                          ),
                        ),
                      const Spacer(),
                      const Text('입력한 건강 관련 정보는 이 기기에만 저장되며 운동 조정 참고용으로만 사용됩니다.', style: TextStyle(color: GymColors.textDim, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => _pc.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut),
            child: const Text('시작하기'),
          ),
        ),
      ],
    ),
  );

  Widget _field(String label, TextEditingController c, {String? suffix, String? hint}) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, suffixText: suffix, hintText: hint),
    ),
  );

  Widget _basic() => _pad([
    const Text('성별', style: TextStyle(color: GymColors.textDim)),
    const SizedBox(height: 8),
    Wrap(
      spacing: 8,
      children: [for (final s in Sex.values) ChoiceChip(label: Text(s.ko), selected: _sex == s, onSelected: (_) => setState(() => _sex = s))],
    ),
    const SizedBox(height: 16),
    _field('나이', _age, suffix: '세'),
    _field('키', _height, suffix: 'cm'),
    _field('체중', _weight, suffix: 'kg'),
    _field('목표 체중 (선택)', _target, suffix: 'kg'),
    _field('체지방률 (선택)', _fat, suffix: '%'),
    _field('골격근량 (선택)', _smm, suffix: 'kg'),
  ]);

  Widget _goalsPage() => _pad([
    const Text('여러 개 선택할 수 있습니다. 선택한 순서가 우선순위이며 화살표로 바꿀 수 있어요.', style: TextStyle(color: GymColors.textDim)),
    const SizedBox(height: 12),
    Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final g in Goal.values)
          FilterChip(label: Text(g.ko), selected: _goals.contains(g), onSelected: (v) => setState(() => v ? _goals.add(g) : _goals.remove(g))),
      ],
    ),
    if (_goals.length > 1) ...[
      const SectionTitle('우선순위'),
      for (var i = 0; i < _goals.length; i++)
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              radius: 14,
              backgroundColor: i == 0 ? GymColors.accent : GymColors.surface2,
              child: Text('${i + 1}', style: TextStyle(color: i == 0 ? Colors.black : GymColors.text)),
            ),
            title: Text(_goals[i].ko),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.arrow_upward), onPressed: i == 0 ? null : () => setState(() => _goals.insert(i - 1, _goals.removeAt(i)))),
                IconButton(
                  icon: const Icon(Icons.arrow_downward),
                  onPressed: i == _goals.length - 1 ? null : () => setState(() => _goals.insert(i + 1, _goals.removeAt(i))),
                ),
              ],
            ),
          ),
        ),
    ],
  ]);

  Widget _expPage() => _pad([
    const Text('운동 경험 기간을 선택하세요. 실제 수행 능력은 운동 기록으로 계속 반영됩니다.', style: TextStyle(color: GymColors.textDim)),
    const SizedBox(height: 12),
    RadioGroup<Experience>(
      groupValue: _exp,
      onChanged: (v) => setState(() => _exp = v!),
      child: Column(
        children: [
          for (final e in Experience.values)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: RadioListTile<Experience>(
                value: e,
                title: Text(e.ko),
                subtitle: e.isNovice ? const Text('기본 동작 위주, 낮은 운동량으로 시작', style: TextStyle(color: GymColors.textDim, fontSize: 12)) : null,
              ),
            ),
        ],
      ),
    ),
  ]);

  Widget _schedule() => _pad([
    const Text('주당 운동 일수', style: TextStyle(fontWeight: FontWeight.w700)),
    const SizedBox(height: 8),
    Wrap(
      spacing: 8,
      children: [
        for (final d in [2, 3, 4, 5, 6]) ChoiceChip(label: Text('주 $d일'), selected: _days == d, onSelected: (_) => setState(() => _days = d)),
      ],
    ),
    const SizedBox(height: 24),
    const Text('1회 운동 시간', style: TextStyle(fontWeight: FontWeight.w700)),
    const SizedBox(height: 8),
    Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final m in [30, 45, 60, 75, 90])
          ChoiceChip(
            label: Text('$m분'),
            selected: _minutes == m && _customMin.text.isEmpty,
            onSelected: (_) => setState(() {
              _minutes = m;
              _customMin.clear();
            }),
          ),
      ],
    ),
    const SizedBox(height: 12),
    _field('직접 입력 (분)', _customMin, suffix: '분', hint: '예: 50'),
  ]);

  Widget _envPage() => _pad([
    RadioGroup<GymEnvironment>(
      groupValue: _env,
      onChanged: (v) => setState(() {
        _env = v!;
        _equipment = v.defaultEquipment;
      }),
      child: Column(
        children: [
          for (final e in GymEnvironment.values)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: RadioListTile<GymEnvironment>(value: e, title: Text(e.ko)),
            ),
        ],
      ),
    ),
    const SectionTitle('사용 가능한 기구'),
    Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final q in Equipment.values.where((q) => q != Equipment.bodyweight))
          FilterChip(label: Text(q.ko), selected: _equipment.contains(q), onSelected: (v) => setState(() => v ? _equipment.add(q) : _equipment.remove(q))),
      ],
    ),
    const SizedBox(height: 8),
    const Text('맨몸 운동은 항상 포함됩니다.', style: TextStyle(color: GymColors.textDim, fontSize: 12)),
  ]);

  Widget _bodyPage() => _pad([
    Card(
      color: GymColors.warn.withValues(alpha: 0.08),
      child: const Padding(
        padding: EdgeInsets.all(12),
        child: Text('통증·질환 정보는 의료 진단이 아닌 운동 조정 참고자료로만 사용됩니다. 심한 통증이나 질환이 있다면 의료 전문가와 먼저 상담하세요.', style: TextStyle(fontSize: 13, height: 1.4)),
      ),
    ),
    const SizedBox(height: 12),
    Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          label: const Text('특별한 문제 없음'),
          selected: _noIssue,
          onSelected: (v) => setState(() {
            _noIssue = v;
            if (v) _lims.clear();
          }),
        ),
        for (final a in JointArea.values)
          FilterChip(
            label: Text(a == JointArea.other ? '기타 부상' : '${a.ko} 통증'),
            selected: _lims.containsKey(a),
            onSelected: (v) => setState(() {
              if (v) {
                _lims[a] = Limitation(area: a, severity: 4);
                _noIssue = false;
              } else {
                _lims.remove(a);
                if (_lims.isEmpty) _noIssue = true;
              }
            }),
          ),
      ],
    ),
    for (final l in _lims.values) _limitationEditor(l),
  ]);

  Widget _limitationEditor(Limitation l) {
    void upd({int? sev, String? t, String? n}) => _lims[l.area] = Limitation(
      area: l.area,
      severity: sev ?? _lims[l.area]!.severity,
      timing: t ?? _lims[l.area]!.timing,
      notes: n ?? _lims[l.area]!.notes,
    );
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l.area == JointArea.other ? '기타 부상' : '${l.area.ko} 통증'} · 강도 ${l.severity}/10', style: const TextStyle(fontWeight: FontWeight.w700)),
            Slider(
              value: l.severity.toDouble(),
              min: 0,
              max: 10,
              divisions: 10,
              label: '${l.severity}',
              onChanged: (v) => setState(() => upd(sev: v.round())),
            ),
            TextFormField(
              key: ValueKey('timing-${l.area.name}'),
              initialValue: l.timing,
              decoration: const InputDecoration(labelText: '발생 시점 (예: 스쿼트 깊이 앉을 때)'),
              onChanged: (v) => upd(t: v),
            ),
            const SizedBox(height: 8),
            TextFormField(
              key: ValueKey('notes-${l.area.name}'),
              initialValue: l.notes,
              decoration: const InputDecoration(labelText: '위치/메모 (선택)'),
              onChanged: (v) => upd(n: v),
            ),
          ],
        ),
      ),
    );
  }
}
