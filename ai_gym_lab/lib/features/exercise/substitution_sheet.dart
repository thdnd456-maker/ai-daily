import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../domain/engines/substitution_engine.dart';
import '../../domain/models.dart';
import 'exercise_library_screen.dart';

/// 운동 대체 선택: 선택한 운동 id 반환
Future<String?> showSubstitutionSheet(BuildContext context, WidgetRef ref, Exercise current, {JointArea? painArea}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: GymColors.surface,
    builder: (_) => _SubstitutionSheet(current: current, painArea: painArea),
  );
}

class _SubstitutionSheet extends ConsumerStatefulWidget {
  final Exercise current;
  final JointArea? painArea;
  const _SubstitutionSheet({required this.current, this.painArea});
  @override
  ConsumerState<_SubstitutionSheet> createState() => _SubstitutionSheetState();
}

class _SubstitutionSheetState extends ConsumerState<_SubstitutionSheet> {
  bool _equipmentBusy = false;
  JointArea? _pain;

  @override
  void initState() {
    super.initState();
    _pain = widget.painArea;
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(repositoryProvider);
    final p = ref.watch(profileProvider).value ?? const UserProfile();
    final eq = {...(p.equipment.isEmpty ? p.environment.defaultEquipment : p.equipment)};
    if (_equipmentBusy) {
      eq.removeAll(widget.current.equipment.where((q) => q != Equipment.bodyweight && q != Equipment.bench));
    }
    final lims = [...p.limitations, if (_pain != null) Limitation(area: _pain!, severity: 6)];
    final cands = SubstitutionEngine(repo.exerciseList)
        .suggest(widget.current, equipment: eq, limitations: lims, experience: p.experience, goal: p.primaryGoal, limit: 6);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (_, sc) => ListView(
        controller: sc,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Text('${widget.current.nameKo} 대체 운동', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('주요 자극 근육·운동 패턴·사용 가능한 기구·숙련도·통증을 고려해 추천합니다. 대체 운동은 기존 중량을 그대로 적용하지 않습니다.', style: TextStyle(color: GymColors.textDim, fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              FilterChip(label: const Text('지금 이 기구 사용 불가'), selected: _equipmentBusy, onSelected: (v) => setState(() => _equipmentBusy = v)),
              for (final a in JointArea.values.where((a) => a != JointArea.other))
                FilterChip(label: Text('${a.ko} 통증'), selected: _pain == a, onSelected: (v) => setState(() => _pain = v ? a : null)),
            ],
          ),
          const SizedBox(height: 8),
          if (cands.isEmpty) const Padding(padding: EdgeInsets.all(16), child: Text('조건에 맞는 대체 운동이 없습니다.')),
          for (var i = 0; i < cands.length; i++)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(radius: 14, backgroundColor: GymColors.surface2, child: Text('${i + 1}')),
                title: Text(cands[i].exercise.nameKo, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(cands[i].reasons.take(3).join(' · '), style: const TextStyle(color: GymColors.textDim, fontSize: 12)),
                trailing: IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ExerciseDetailScreen(exercise: cands[i].exercise))),
                ),
                onTap: () => Navigator.pop(context, cands[i].exercise.id),
              ),
            ),
          TextButton.icon(
            onPressed: () async {
              final id = await Navigator.of(context).push<String>(MaterialPageRoute(builder: (_) => const ExerciseLibraryScreen(pickMode: true)));
              if (id != null && context.mounted) Navigator.pop(context, id);
            },
            icon: const Icon(Icons.list),
            label: const Text('전체 목록에서 직접 선택'),
          ),
        ],
      ),
    );
  }
}
