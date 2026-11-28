import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/exercise_visuals.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../app/widgets.dart';
import '../../data/repository.dart';
import '../../domain/engines/program_generator.dart';
import '../../domain/models.dart';
import '../exercise/exercise_library_screen.dart' show ExerciseDetailScreen;
import '../program/program_editor_screen.dart';
import '../program/program_review_screen.dart';
import 'start_flow.dart';

/// 홈 화면 아래쪽: 현재 프로그램 · 주간 운동 일정 (예전 「운동」 탭을 홈에 합침)
class ProgramPanel extends ConsumerWidget {
  final HomeSummary s;
  const ProgramPanel({super.key, required this.s});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = s.program;
    if (p == null) return const SizedBox.shrink();
    final repo = ref.read(repositoryProvider);
    Widget btn(IconData icon, String label, VoidCallback onTap) => OutlinedButton.icon(
      style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact, padding: const EdgeInsets.symmetric(horizontal: 10)),
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 13)),
      onPressed: onTap,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle('주간 운동 일정', trailing: Pill(p.row.source == 'ai' ? 'AI 추천' : '내 수정', color: p.row.source == 'ai' ? GymColors.accent : GymColors.info)),
        SectionCard(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
                child: Text('${p.row.name} · ${p.split.ko}', style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
              for (var i = 0; i < p.days.length; i++)
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: i == s.nextIndex ? GymColors.accent : GymColors.surface2,
                    foregroundColor: i == s.nextIndex ? Colors.black : GymColors.text,
                    child: Text(weekdayKo[p.days[i].row.weekday], style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
                  title: Text(p.days[i].row.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                    '${p.days[i].exercises.length}개 운동 · 약 ${WorkoutDays.minutes(p.days[i])}분${i == s.nextIndex ? ' · 다음' : ''}',
                    style: TextStyle(color: i == s.nextIndex ? GymColors.accent : GymColors.textDim),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => WorkoutDays.dayDetail(context, ref, p, i),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    btn(Icons.edit_outlined, '수정', () async {
                      final edited = await Navigator.of(context).push<ProgramPlan>(MaterialPageRoute(builder: (_) => ProgramEditorScreen(plan: p.toPlan())));
                      if (edited == null) return;
                      await repo.updateProgram(p.row.id, edited);
                      ref.refreshData();
                      if (context.mounted) showSnack(context, p.row.source == 'ai' ? 'AI 추천 원본은 보존하고 수정본을 저장했습니다.' : '저장했습니다.');
                    }),
                    btn(
                      Icons.info_outline,
                      '구성 이유',
                      () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: GymColors.surface,
                        builder: (_) => DraggableScrollableSheet(
                          expand: false,
                          builder: (_, sc) => ListView(
                            controller: sc,
                            padding: const EdgeInsets.all(16),
                            children: [
                              const Text('프로그램 구성 이유', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 12),
                              RationaleList(p.rationale),
                            ],
                          ),
                        ),
                      ),
                    ),
                    btn(Icons.auto_awesome, '새로 추천', () async {
                      final profile = await repo.getProfile();
                      if (profile == null || !context.mounted) return;
                      final plan = ProgramGenerator(repo.exerciseList).generate(profile);
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProgramReviewScreen(plan: plan, isNew: true)));
                    }),
                    btn(Icons.folder_open, '목록', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProgramListScreen()))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

abstract final class WorkoutDays {
  static int minutes(DayView d) => ProgramGenerator.estimateMinutes([
    for (final x in d.exercises) PlannedExercise(exerciseId: x.exerciseId, sets: x.sets, repMin: x.repMin, repMax: x.repMax, restSec: x.restSec),
  ]);

  static void dayDetail(BuildContext context, WidgetRef ref, ProgramView p, int i) {
    final repo = ref.read(repositoryProvider);
    final d = p.days[i];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: GymColors.surface,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        builder: (_, sc) => ListView(
          controller: sc,
          padding: const EdgeInsets.all(16),
          children: [
            Text(d.row.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            for (final x in d.exercises)
              ExerciseTile(
                exercise: repo.exercises[x.exerciseId]!,
                trailing: Text('${x.sets} × ${x.repMin}~${x.repMax}', style: const TextStyle(fontWeight: FontWeight.w800)),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ExerciseDetailScreen(exercise: repo.exercises[x.exerciseId]!))),
              ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                startWorkoutFlow(context, ref, dayIndex: i);
              },
              child: Text('${d.row.name} 시작'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProgramListScreen extends ConsumerWidget {
  const ProgramListScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(programsProvider);
    final repo = ref.read(repositoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('저장된 프로그램')),
      body: list.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (ps) => ListView(
          padding: const EdgeInsets.all(12),
          children: [
            const Text('AI 추천 프로그램과 직접 수정한 프로그램이 모두 저장됩니다.', style: TextStyle(color: GymColors.textDim, fontSize: 12)),
            const SizedBox(height: 8),
            for (final p in ps)
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(p.name, style: TextStyle(fontWeight: p.isActive ? FontWeight.w800 : FontWeight.w500)),
                  subtitle: Text(
                    '${p.source == 'ai' ? 'AI 추천' : '내 수정'} · ${p.createdAt.year}.${p.createdAt.month}.${p.createdAt.day}${p.isActive ? ' · 사용 중' : ''}',
                    style: TextStyle(color: p.isActive ? GymColors.accent : GymColors.textDim),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      switch (v) {
                        case 'activate':
                          await repo.activateProgram(p.id);
                        case 'copy':
                          await repo.copyProgram(p.id);
                        case 'delete':
                          if (!await confirm(context, '프로그램 삭제', '${p.name}을(를) 삭제할까요? 운동 기록은 유지됩니다.', ok: '삭제', danger: true)) return;
                          await repo.deleteProgram(p.id);
                      }
                      ref.refreshData();
                    },
                    itemBuilder: (_) => [
                      if (!p.isActive) const PopupMenuItem(value: 'activate', child: Text('이 프로그램 사용')),
                      const PopupMenuItem(value: 'copy', child: Text('복사')),
                      if (!p.isActive) const PopupMenuItem(value: 'delete', child: Text('삭제')),
                    ],
                  ),
                  onTap: () async {
                    final view = await repo.getProgram(p.id);
                    if (view == null || !context.mounted) return;
                    final edited = await Navigator.of(context).push<ProgramPlan>(MaterialPageRoute(builder: (_) => ProgramEditorScreen(plan: view.toPlan())));
                    if (edited != null) {
                      await repo.updateProgram(p.id, edited);
                      ref.refreshData();
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
