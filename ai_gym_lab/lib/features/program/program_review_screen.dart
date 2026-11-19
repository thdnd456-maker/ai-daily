import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/exercise_visuals.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../app/widgets.dart';
import '../../domain/engines/program_generator.dart';
import '../../domain/engines/volume_engine.dart';
import '../../domain/models.dart';
import 'program_editor_screen.dart';

const weekdayKo = ['', '월', '화', '수', '목', '금', '토', '일'];

/// 운동 프로그램 추천 화면 (생성 결과 + 근거)
class ProgramReviewScreen extends ConsumerWidget {
  final ProgramPlan plan;
  final bool isNew;
  final bool isRoot;
  const ProgramReviewScreen({super.key, required this.plan, this.isNew = false, this.isRoot = false});

  Future<void> _save(BuildContext context, WidgetRef ref, ProgramPlan p, String source) async {
    await ref.read(repositoryProvider).saveProgram(p, source: source, activate: true);
    ref.refreshData();
    if (!context.mounted) return;
    if (!isRoot) Navigator.of(context).popUntil((r) => r.isFirst);
    showSnack(context, '프로그램이 활성화되었습니다.');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(repositoryProvider);
    final profile = ref.watch(profileProvider).value;
    return Scaffold(
      appBar: AppBar(title: const Text('추천 운동 프로그램'), automaticallyImplyLeading: !isRoot),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plan.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text('${plan.days.length}일 순환 · ${plan.days.map((d) => weekdayKo[d.weekday]).join('·')} 권장', style: const TextStyle(color: GymColors.textDim)),
                const SizedBox(height: 8),
                const Text('요일을 놓쳐도 다음 운동은 순서대로 이어집니다.', style: TextStyle(color: GymColors.textDim, fontSize: 12)),
              ],
            ),
          ),
          for (final d in plan.days) ...[
            SectionTitle(
              '${d.name} · ${weekdayKo[d.weekday]}',
              trailing: Text('약 ${ProgramGenerator.estimateMinutes(d.exercises)}분', style: const TextStyle(color: GymColors.textDim)),
            ),
            SectionCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  for (final x in d.exercises)
                    ExerciseTile(
                      exercise: repo.exercises[x.exerciseId]!,
                      thumb: 48,
                      onTap: () => showExercisePhotoViewer(context, repo.exercises[x.exerciseId]!),
                      trailing: Text(
                        '${x.sets} × ${x.repMin}~${x.repMax}${repo.exercises[x.exerciseId]!.timed ? '초' : ''}',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SectionTitle('근육별 주간 직접 세트(계획)'),
          SectionCard(
            child: _VolumeBars(plan: plan, target: profile == null ? null : weeklyVolumeTarget(profile)),
          ),
          const SectionTitle('이렇게 구성한 이유'),
          SectionCard(child: RationaleList(plan.rationale)),
          const SizedBox(height: 8),
          const Text('이 프로그램은 초기 템플릿입니다. 모든 사람에게 같은 방법이 최선이라고 가정하지 않으며, 기록에 따라 계속 조정됩니다.', style: TextStyle(color: GymColors.textDim, fontSize: 12)),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final edited = await Navigator.of(context).push<ProgramPlan>(
                      MaterialPageRoute(
                        builder: (_) => ProgramEditorScreen(plan: plan, title: '프로그램 직접 수정'),
                      ),
                    );
                    if (edited != null && context.mounted) await _save(context, ref, edited, 'user');
                  },
                  child: const Text('직접 수정'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton(onPressed: () => _save(context, ref, plan, 'ai'), child: const Text('이 프로그램으로 시작')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VolumeBars extends ConsumerWidget {
  final ProgramPlan plan;
  final VolumeTarget? target;
  const _VolumeBars({required this.plan, this.target});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = VolumeEngine(ref.read(repositoryProvider).exercises).plannedVolume(plan.days);
    final maxV = trackedMuscles.map((m) => v[m]!.direct).fold<double>(1, (a, b) => a > b ? a : b);
    return Column(
      children: [
        for (final m in trackedMuscles)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                SizedBox(width: 86, child: Text(m.ko, style: const TextStyle(fontSize: 13))),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: v[m]!.direct / maxV,
                      minHeight: 10,
                      backgroundColor: GymColors.surface2,
                      color: target != null && v[m]!.direct >= target!.min && v[m]!.direct <= target!.max ? GymColors.accent : GymColors.warn,
                    ),
                  ),
                ),
                SizedBox(
                  width: 44,
                  child: Text(
                    ' ${v[m]!.direct.toInt()}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        if (target != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '초록: 시작 목표 ${target!.min}~${target!.max}세트 범위 · 주황: 범위 밖 (앱 기본값, 개인에 따라 조정)',
              style: const TextStyle(fontSize: 12, color: GymColors.textDim),
            ),
          ),
      ],
    );
  }
}
