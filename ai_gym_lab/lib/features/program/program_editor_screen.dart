import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/exercise_visuals.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../app/widgets.dart';
import '../../domain/engines/program_generator.dart';
import '../../domain/models.dart';
import '../exercise/exercise_library_screen.dart';
import 'program_review_screen.dart' show weekdayKo;

/// 프로그램 직접 수정: 운동 추가/삭제/순서/요일/세트/반복/중량/휴식/분할 변경
/// 저장하면 수정된 ProgramPlan을 반환합니다.
class ProgramEditorScreen extends ConsumerStatefulWidget {
  final ProgramPlan plan;
  final String title;
  const ProgramEditorScreen({super.key, required this.plan, this.title = '프로그램 수정'});
  @override
  ConsumerState<ProgramEditorScreen> createState() => _ProgramEditorScreenState();
}

class _ProgramEditorScreenState extends ConsumerState<ProgramEditorScreen> {
  late String _name;
  late SplitType _split;
  late List<PlannedDay> _days;
  int _sel = 0;

  @override
  void initState() {
    super.initState();
    _name = widget.plan.name;
    _split = widget.plan.split;
    _days = [
      for (final d in widget.plan.days) d.copyWith(exercises: [...d.exercises]),
    ];
  }

  void _setDay(int i, PlannedDay d) => setState(() => _days[i] = d);

  Future<void> _editExercise(int dayIdx, int exIdx) async {
    final x = _days[dayIdx].exercises[exIdx];
    final r = await showModalBottomSheet<PlannedExercise>(
      context: context,
      isScrollControlled: true,
      backgroundColor: GymColors.surface,
      builder: (_) => _PrescriptionSheet(x: x),
    );
    if (r != null) {
      final xs = [..._days[dayIdx].exercises]..[exIdx] = r;
      _setDay(dayIdx, _days[dayIdx].copyWith(exercises: xs));
    }
  }

  Future<void> _addExercise(int dayIdx) async {
    final id = await Navigator.of(context).push<String>(MaterialPageRoute(builder: (_) => const ExerciseLibraryScreen(pickMode: true)));
    if (id == null) return;
    final e = ref.read(repositoryProvider).exercises[id]!;
    final xs = [
      ..._days[dayIdx].exercises,
      PlannedExercise(
        exerciseId: id,
        sets: e.type == ExerciseType.compound ? 3 : 2,
        repMin: e.repMin,
        repMax: e.repMax,
        targetRir: e.type == ExerciseType.compound ? 2 : 1,
        restSec: e.restSec,
      ),
    ];
    _setDay(dayIdx, _days[dayIdx].copyWith(exercises: xs));
  }

  Future<void> _renameDay(int i) async {
    final c = TextEditingController(text: _days[i].name);
    final r = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('운동일 이름'),
        content: TextField(controller: c, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          FilledButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: const Text('확인')),
        ],
      ),
    );
    if (r != null && r.isNotEmpty) _setDay(i, _days[i].copyWith(name: r));
  }

  Future<void> _rename() async {
    final c = TextEditingController(text: _name);
    final r = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('프로그램 이름'),
        content: TextField(controller: c, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          FilledButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: const Text('확인')),
        ],
      ),
    );
    if (r != null && r.isNotEmpty) setState(() => _name = r);
  }

  void _save() {
    if (_days.isEmpty || _days.any((d) => d.exercises.isEmpty)) {
      showSnack(context, '모든 운동일에 운동이 하나 이상 있어야 합니다.');
      return;
    }
    Navigator.pop(
      context,
      ProgramPlan(
        name: _name,
        split: _split,
        days: _days,
        rationale: [...widget.plan.rationale, const Rationale('사용자가 직접 수정한 프로그램입니다.', EvidenceKind.userData)],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(repositoryProvider);
    if (_sel >= _days.length) _sel = _days.isEmpty ? 0 : _days.length - 1;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [TextButton(onPressed: _save, child: const Text('저장'))],
      ),
      body: Column(
        children: [
          ListTile(
            title: Text(_name, style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text(_split.ko),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit), onPressed: _rename, tooltip: '이름 변경'),
                PopupMenuButton<SplitType>(
                  tooltip: '분할 방식',
                  icon: const Icon(Icons.view_week),
                  onSelected: (s) => setState(() => _split = s),
                  itemBuilder: (_) => [for (final s in SplitType.values) PopupMenuItem(value: s, child: Text(s.ko))],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (var i = 0; i < _days.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(label: Text(_days[i].name), selected: _sel == i, onSelected: (_) => setState(() => _sel = i)),
                  ),
                ActionChip(
                  avatar: const Icon(Icons.add, size: 18),
                  label: const Text('운동일 추가'),
                  onPressed: () => setState(() {
                    _days.add(PlannedDay(name: '운동 ${_days.length + 1}', weekday: (_days.length % 7) + 1, exercises: const []));
                    _sel = _days.length - 1;
                  }),
                ),
              ],
            ),
          ),
          if (_days.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  const Text('요일 ', style: TextStyle(color: GymColors.textDim)),
                  DropdownButton<int>(
                    value: _days[_sel].weekday,
                    onChanged: (v) => _setDay(_sel, _days[_sel].copyWith(weekday: v)),
                    items: [for (var w = 1; w <= 7; w++) DropdownMenuItem(value: w, child: Text('${weekdayKo[w]}요일'))],
                  ),
                  const SizedBox(width: 8),
                  Text('약 ${ProgramGenerator.estimateMinutes(_days[_sel].exercises)}분', style: const TextStyle(color: GymColors.textDim)),
                  const SizedBox(width: 8),
                  IconButton(icon: const Icon(Icons.drive_file_rename_outline), onPressed: () => _renameDay(_sel), tooltip: '운동일 이름'),
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    tooltip: '순서 앞으로',
                    onPressed: _sel == 0
                        ? null
                        : () => setState(() {
                            _days.insert(_sel - 1, _days.removeAt(_sel));
                            _sel--;
                          }),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    tooltip: '순서 뒤로',
                    onPressed: _sel == _days.length - 1
                        ? null
                        : () => setState(() {
                            _days.insert(_sel + 1, _days.removeAt(_sel));
                            _sel++;
                          }),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: GymColors.danger),
                    tooltip: '운동일 삭제',
                    onPressed: _days.length <= 1
                        ? null
                        : () async {
                            if (await confirm(context, '운동일 삭제', '${_days[_sel].name}을(를) 삭제할까요?', danger: true, ok: '삭제')) {
                              setState(() => _days.removeAt(_sel));
                            }
                          },
                  ),
                ],
              ),
            ),
            Expanded(
              child: ReorderableListView(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 100),
                onReorderItem: (a, b) {
                  final xs = [..._days[_sel].exercises];
                  xs.insert(b, xs.removeAt(a));
                  _setDay(_sel, _days[_sel].copyWith(exercises: xs));
                },
                children: [
                  for (var i = 0; i < _days[_sel].exercises.length; i++)
                    Card(
                      key: ValueKey('${_sel}_${i}_${_days[_sel].exercises[i].exerciseId}'),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        onTap: () => _editExercise(_sel, i),
                        contentPadding: const EdgeInsets.fromLTRB(10, 4, 4, 4),
                        leading: ExercisePhoto(exercise: repo.exercises[_days[_sel].exercises[i].exerciseId]!, width: 48, height: 48, radius: 10),
                        title: Text(repo.exercises[_days[_sel].exercises[i].exerciseId]!.nameKo),
                        subtitle: Text(_desc(_days[_sel].exercises[i]), style: const TextStyle(color: GymColors.textDim)),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            final xs = [..._days[_sel].exercises]..removeAt(i);
                            _setDay(_sel, _days[_sel].copyWith(exercises: xs));
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
      floatingActionButton: _days.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _addExercise(_sel),
              backgroundColor: GymColors.accent,
              foregroundColor: Colors.black,
              icon: const Icon(Icons.add),
              label: const Text('운동 추가'),
            ),
    );
  }

  String _desc(PlannedExercise x) =>
      '${x.sets}세트 × ${x.repMin}~${x.repMax} · RIR ${x.targetRir} · 휴식 ${x.restSec}초${x.startWeight != null ? ' · 시작 ${x.startWeight}kg' : ''}';
}

class _PrescriptionSheet extends StatefulWidget {
  final PlannedExercise x;
  const _PrescriptionSheet({required this.x});
  @override
  State<_PrescriptionSheet> createState() => _PrescriptionSheetState();
}

class _PrescriptionSheetState extends State<_PrescriptionSheet> {
  late PlannedExercise x = widget.x;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('처방 수정', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: NumberStepper(
                label: '세트',
                value: x.sets.toDouble(),
                min: 1,
                max: 10,
                onChanged: (v) => setState(() => x = x.copyWith(sets: v.round())),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NumberStepper(
                label: '목표 RIR',
                value: x.targetRir.toDouble(),
                min: 0,
                max: 5,
                onChanged: (v) => setState(() => x = x.copyWith(targetRir: v.round())),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: NumberStepper(
                label: '최소 반복',
                value: x.repMin.toDouble(),
                min: 1,
                max: 100,
                onChanged: (v) => setState(() => x = x.copyWith(repMin: v.round(), repMax: v.round() > x.repMax ? v.round() : x.repMax)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NumberStepper(
                label: '최대 반복',
                value: x.repMax.toDouble(),
                min: 1,
                max: 100,
                onChanged: (v) => setState(() => x = x.copyWith(repMax: v.round(), repMin: v.round() < x.repMin ? v.round() : x.repMin)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: NumberStepper(
                label: '휴식(초)',
                value: x.restSec.toDouble(),
                step: 15,
                min: 15,
                max: 600,
                onChanged: (v) => setState(() => x = x.copyWith(restSec: v.round())),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NumberStepper(
                label: '시작 중량(kg)',
                value: x.startWeight,
                step: 2.5,
                decimals: 2,
                placeholder: '자동',
                onChanged: (v) => setState(() => x = x.copyWith(startWeight: v)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text('시작 중량은 기록이 없을 때만 사용됩니다. 기록이 있으면 기록 기반 추천이 우선합니다.', style: TextStyle(color: GymColors.textDim, fontSize: 12)),
        const SizedBox(height: 16),
        FilledButton(onPressed: () => Navigator.pop(context, x), child: const Text('적용')),
      ],
    ),
  );
}
