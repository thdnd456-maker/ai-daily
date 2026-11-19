import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../app/widgets.dart';
import '../../domain/catalog/research.dart';
import '../../domain/engines/substitution_engine.dart';
import '../../domain/models.dart';

const _categories = <String, List<Muscle>>{
  '전체': [],
  '가슴': [Muscle.chest],
  '등': [Muscle.lats, Muscle.upperBack, Muscle.lowerBack],
  '어깨': [Muscle.frontDelt, Muscle.sideDelt, Muscle.rearDelt],
  '하체': [Muscle.quads, Muscle.hamstrings, Muscle.adductors],
  '엉덩이': [Muscle.glutes],
  '팔': [Muscle.biceps, Muscle.triceps, Muscle.forearms],
  '복근': [Muscle.abs],
  '종아리': [Muscle.calves],
};

/// 운동 데이터베이스 (pickMode: 운동 선택 후 id 반환)
class ExerciseLibraryScreen extends ConsumerStatefulWidget {
  final bool pickMode;
  const ExerciseLibraryScreen({super.key, this.pickMode = false});
  @override
  ConsumerState<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends ConsumerState<ExerciseLibraryScreen> {
  String _q = '';
  String _cat = '전체';
  bool _onlyAvailable = true;

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(repositoryProvider);
    final profile = ref.watch(profileProvider).value;
    final eq = profile == null ? Equipment.values.toSet() : (profile.equipment.isEmpty ? profile.environment.defaultEquipment : profile.equipment);
    final list = repo.exerciseList.where((e) {
      if (_cat != '전체' && !e.primary.any(_categories[_cat]!.contains)) return false;
      if (_onlyAvailable && !SubstitutionEngine.isAvailable(e, eq)) return false;
      if (_q.isEmpty) return true;
      final q = _q.replaceAll(' ', '').toLowerCase();
      return e.nameKo.replaceAll(' ', '').contains(q) || e.nameEn.toLowerCase().replaceAll(' ', '').contains(q);
    }).toList();
    return Scaffold(
      appBar: AppBar(title: Text(widget.pickMode ? '운동 선택' : '운동 데이터베이스 (${repo.exercises.length})')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: TextField(
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: '운동 이름 검색 (한글/영문)'),
              onChanged: (v) => setState(() => _q = v),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final c in _categories.keys)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(label: Text(c), selected: _cat == c, onSelected: (_) => setState(() => _cat = c)),
                  ),
              ],
            ),
          ),
          SwitchListTile(dense: true, title: const Text('내 기구로 가능한 운동만'), value: _onlyAvailable, onChanged: (v) => setState(() => _onlyAvailable = v)),
          Expanded(
            child: list.isEmpty
                ? const EmptyState(icon: Icons.search_off, title: '조건에 맞는 운동이 없습니다')
                : ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const Divider(height: 1, indent: 16),
                    itemBuilder: (_, i) {
                      final e = list[i];
                      return ListTile(
                        title: Text(e.nameKo),
                        subtitle: Text(
                          '${e.primary.map((m) => m.ko).join('·')} · ${e.equipment.map((q) => q.ko).join('+')}',
                          style: const TextStyle(color: GymColors.textDim, fontSize: 12),
                        ),
                        trailing: widget.pickMode
                            ? IconButton(icon: const Icon(Icons.info_outline), onPressed: () => _detail(e))
                            : Text(['', '초급', '중급', '고급'][e.difficulty], style: const TextStyle(color: GymColors.textDim)),
                        onTap: () => widget.pickMode ? Navigator.pop(context, e.id) : _detail(e),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _detail(Exercise e) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ExerciseDetailScreen(exercise: e)));
}

class ExerciseDetailScreen extends ConsumerWidget {
  final Exercise exercise;
  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final e = exercise;
    final repo = ref.read(repositoryProvider);
    Widget list(String title, List<String> items, IconData icon, Color color) => items.isEmpty
        ? const SizedBox.shrink()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(title),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final t in items)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(icon, size: 18, color: color),
                            const SizedBox(width: 8),
                            Expanded(child: Text(t, style: const TextStyle(height: 1.35))),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
    final stress = e.jointStress.entries.where((kv) => kv.value > 0).toList();
    return Scaffold(
      appBar: AppBar(title: Text(e.nameKo)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          Text(e.nameEn, style: const TextStyle(color: GymColors.textDim)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final m in e.primary) Pill('주요 ${m.ko}'),
              for (final m in e.secondary) Pill('보조 ${m.ko}', color: GymColors.info),
              Pill(e.type == ExerciseType.compound ? '복합운동' : '고립운동', color: GymColors.textDim),
              Pill(['', '초급', '중급', '고급'][e.difficulty], color: GymColors.textDim),
            ],
          ),
          const SizedBox(height: 12),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.description, style: const TextStyle(height: 1.4)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: StatTile(label: '권장 반복', value: '${e.repMin}~${e.repMax}${e.timed ? '초' : '회'}'),
                    ),
                    Expanded(
                      child: StatTile(label: '권장 휴식', value: '${e.restSec}초'),
                    ),
                    Expanded(
                      child: StatTile(label: '기구', value: e.equipment.map((q) => q.ko).join('+')),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (e.assisted) ...[
            const SizedBox(height: 8),
            const Text('보조 운동: 기록하는 중량은 보조 중량이며, 숫자가 줄어들수록 발전한 것입니다.', style: TextStyle(color: GymColors.warn, fontSize: 13)),
          ],
          list('올바른 자세', e.cues, Icons.check_circle_outline, GymColors.accent),
          list('흔한 실수', e.mistakes, Icons.error_outline, GymColors.warn),
          list('주의사항', e.cautions, Icons.health_and_safety_outlined, GymColors.danger),
          if (stress.isNotEmpty) ...[
            const SectionTitle('관절 부담 (앱 추정값)'),
            SectionCard(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final kv in stress) Pill('${kv.key.ko} ${['낮음', '보통', '높음'][kv.value]}', color: kv.value >= 2 ? GymColors.danger : GymColors.warn),
                ],
              ),
            ),
          ],
          if (e.alternatives.isNotEmpty) ...[
            const SectionTitle('대체 운동'),
            SectionCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final id in e.alternatives)
                    if (repo.exercises[id] != null)
                      ListTile(
                        title: Text(repo.exercises[id]!.nameKo),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ExerciseDetailScreen(exercise: repo.exercises[id]!))),
                      ),
                ],
              ),
            ),
          ],
          if (e.referenceIds.isNotEmpty) ...[
            const SectionTitle('관련 연구'),
            for (final id in e.referenceIds)
              if (researchById[id] != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(researchById[id]!.citation, style: const TextStyle(color: GymColors.research, fontSize: 13)),
                        const SizedBox(height: 6),
                        Text(researchById[id]!.keyFindings),
                        const SizedBox(height: 4),
                        Text('한계: ${researchById[id]!.limitations}', style: const TextStyle(color: GymColors.textDim, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
          ],
          const SectionTitle('운동 영상'),
          SectionCard(
            child: Text(e.videoUrl ?? '저작권이 확인된 영상이 아직 등록되지 않았습니다. 위의 자세 설명을 참고하세요.', style: const TextStyle(color: GymColors.textDim)),
          ),
        ],
      ),
    );
  }
}
