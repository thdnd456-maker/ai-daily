import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../app/widgets.dart';
import '../../data/repository.dart';
import '../../domain/engines/program_generator.dart';
import '../../domain/models.dart';
import '../exercise/exercise_library_screen.dart';
import '../program/program_editor_screen.dart';
import '../program/program_review_screen.dart';
import 'start_flow.dart';

/// 운동 탭: 주간 운동 일정 · 현재 프로그램 · 프로그램 관리 · 운동 데이터베이스
class WorkoutTab extends ConsumerWidget {
  const WorkoutTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(homeSummaryProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('운동'),
        actions: [
          IconButton(
            tooltip: '운동 데이터베이스',
            icon: const Icon(Icons.menu_book_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ExerciseLibraryScreen())),
          ),
        ],
      ),
      body: summary.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (s) {
          final p = s.program;
          if (p == null) return const EmptyState(icon: Icons.fitness_center, title: '활성 프로그램이 없습니다');
          final repo = ref.read(repositoryProvider);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(p.row.name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                        ),
                        Pill(p.row.source == 'ai' ? 'AI 추천' : '내 수정', color: p.row.source == 'ai' ? GymColors.accent : GymColors.info),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${p.split.ko} · ${p.days.length}일 순환', style: const TextStyle(color: GymColors.textDim)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('수정'),
                          onPressed: () async {
                            final edited = await Navigator.of(context)
                                .push<ProgramPlan>(MaterialPageRoute(builder: (_) => ProgramEditorScreen(plan: p.toPlan())));
                            if (edited == null) return;
                            await repo.updateProgram(p.row.id, edited);
                            ref.refreshData();
                            if (context.mounted) {
                              showSnack(context, p.row.source == 'ai' ? 'AI 추천 원본은 보존하고 수정본을 저장했습니다.' : '저장했습니다.');
                            }
                          },
                        ),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.info_outline, size: 18),
                          label: const Text('구성 이유'),
                          onPressed: () => showModalBottomSheet(
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
                        OutlinedButton.icon(
                          icon: const Icon(Icons.auto_awesome, size: 18),
                          label: const Text('새로 추천받기'),
                          onPressed: () async {
                            final profile = await repo.getProfile();
                            if (profile == null || !context.mounted) return;
                            final plan = ProgramGenerator(repo.exerciseList).generate(profile);
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProgramReviewScreen(plan: plan, isNew: true)));
                          },
                        ),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.folder_open, size: 18),
                          label: const Text('프로그램 목록'),
                          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProgramListScreen())),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SectionTitle('주간 운동 일정'),
              SectionCard(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: [
                    for (var i = 0; i < p.days.length; i++)
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: i == s.nextIndex ? GymColors.accent : GymColors.surface2,
                          foregroundColor: i == s.nextIndex ? Colors.black : GymColors.text,
                          child: Text(weekdayKo[p.days[i].row.weekday], style: const TextStyle(fontWeight: FontWeight.w800)),
                        ),
                        title: Text(p.days[i].row.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text(
                          '${p.days[i].exercises.length}개 운동 · 약 ${_minutes(p.days[i])}분${i == s.nextIndex ? ' · 다음 순서' : ''}',
                          style: TextStyle(color: i == s.nextIndex ? GymColors.accent : GymColors.textDim),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _dayDetail(context, ref, p, i),
                      ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text('요일은 권장값입니다. 운동은 순서대로 이어지며, 다른 날 운동을 먼저 하고 싶다면 해당 날을 눌러 시작하세요.', style: TextStyle(color: GymColors.textDim, fontSize: 12)),
              ),
            ],
          );
        },
      ),
    );
  }

  static int _minutes(DayView d) => ProgramGenerator.estimateMinutes([
    for (final x in d.exercises) PlannedExercise(exerciseId: x.exerciseId, sets: x.sets, repMin: x.repMin, repMax: x.repMax, restSec: x.restSec),
  ]);

  void _dayDetail(BuildContext context, WidgetRef ref, ProgramView p, int i) {
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
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(repo.exercises[x.exerciseId]!.nameKo),
                subtitle: Text('휴식 ${x.restSec}초 · RIR ${x.targetRir}', style: const TextStyle(color: GymColors.textDim)),
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
