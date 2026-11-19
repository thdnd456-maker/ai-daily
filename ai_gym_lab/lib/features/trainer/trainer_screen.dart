import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../app/widgets.dart';
import '../../data/db/database.dart';
import '../settings/settings_screen.dart';

final chatProvider = FutureProvider<List<(ChatMessage, AiRecommendation?)>>((ref) async {
  ref.watch(dataVersionProvider);
  final repo = ref.read(repositoryProvider);
  final msgs = await repo.chatHistory();
  return [for (final m in msgs) (m, m.recommendationId == null ? null : await repo.aiRecommendation(m.recommendationId!))];
});

final aiProviderLabelProvider = FutureProvider<String>((ref) async {
  ref.watch(dataVersionProvider);
  final p = await ref.read(repositoryProvider).getSetting('ai.provider');
  return switch (p) {
    'anthropic' => 'Anthropic 연결됨',
    'openai' => 'OpenAI 연결됨',
    'proxy' => '백엔드 프록시 연결됨',
    _ => '오프라인 트레이너 (규칙 기반)',
  };
});

class TrainerScreen extends ConsumerStatefulWidget {
  const TrainerScreen({super.key});
  @override
  ConsumerState<TrainerScreen> createState() => _TrainerScreenState();
}

class _TrainerScreenState extends ConsumerState<TrainerScreen> {
  final _c = TextEditingController();
  final _scroll = ScrollController();
  bool _sending = false;

  static const _examples = ['오늘 벤치프레스 몇 kg으로 해야 해?', '어제 하체 운동했는데 오늘 또 해도 돼?', '무릎이 아픈데 스쿼트 대신 무엇을 하면 좋아?', '가슴 근육이 잘 안 크는 이유가 뭘까?', '운동 시간을 40분으로 줄여줘.'];

  Future<void> _send(String text) async {
    final q = text.trim();
    if (q.isEmpty || _sending) return;
    setState(() => _sending = true);
    _c.clear();
    try {
      await ref.read(trainerServiceProvider).ask(q);
    } catch (e) {
      if (mounted) showSnack(context, '답변 실패: $e');
    }
    ref.refreshData();
    if (mounted) setState(() => _sending = false);
    await Future.delayed(const Duration(milliseconds: 300));
    if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(chatProvider);
    final label = ref.watch(aiProviderLabelProvider).value ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AI 트레이너'),
            Text(label, style: const TextStyle(fontSize: 12, color: GymColors.textDim)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'AI 설정',
            icon: const Icon(Icons.tune),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AiSettingsScreen())),
          ),
          IconButton(
            tooltip: '대화 지우기',
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () async {
              if (await confirm(context, '대화 지우기', '대화 기록을 모두 삭제할까요?', ok: '삭제', danger: true)) {
                await ref.read(repositoryProvider).clearChat();
                ref.refreshData();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: chat.when(
              skipLoadingOnReload: true,
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (items) {
                if (items.isEmpty) {
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const SizedBox(height: 24),
                      const Icon(Icons.smart_toy, size: 48, color: GymColors.accent),
                      const SizedBox(height: 12),
                      const Text(
                        '내 운동 기록과 현재 프로그램을 바탕으로 답변합니다.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '의학적 진단은 하지 않으며, 프로그램 변경은 승인 후에만 적용됩니다.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: GymColors.textDim),
                      ),
                      const SizedBox(height: 20),
                      for (final e in _examples)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: OutlinedButton(
                            onPressed: () => _send(e),
                            child: Align(alignment: Alignment.centerLeft, child: Text(e)),
                          ),
                        ),
                    ],
                  );
                }
                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  itemCount: items.length + (_sending ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i == items.length) {
                      return const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('답변 작성 중…', style: TextStyle(color: GymColors.textDim)),
                      );
                    }
                    final (m, rec) = items[i];
                    return _Bubble(msg: m, rec: rec);
                  },
                );
              },
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final e in _examples)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ActionChip(
                      label: Text(e, style: const TextStyle(fontSize: 12)),
                      onPressed: () => _send(e),
                    ),
                  ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _c,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _send,
                      decoration: const InputDecoration(hintText: '트레이너에게 질문하기'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    style: IconButton.styleFrom(backgroundColor: GymColors.accent, foregroundColor: Colors.black, minimumSize: const Size(52, 52)),
                    onPressed: _sending ? null : () => _send(_c.text),
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends ConsumerWidget {
  final ChatMessage msg;
  final AiRecommendation? rec;
  const _Bubble({required this.msg, this.rec});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mine = msg.role == 'user';
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.86),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: mine ? GymColors.accent.withValues(alpha: 0.16) : GymColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: mine ? null : Border.all(color: GymColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(msg.content, style: const TextStyle(height: 1.4)),
              if (!mine && msg.provider != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(msg.provider == 'offline' ? '오프라인 트레이너' : msg.provider!, style: const TextStyle(color: GymColors.textDim, fontSize: 11)),
                ),
              if (rec != null) _ProposalCard(rec: rec!),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProposalCard extends ConsumerWidget {
  final AiRecommendation rec;
  const _ProposalCard({required this.rec});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final svc = ref.read(trainerServiceProvider);
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GymColors.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GymColors.accent.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_calendar, size: 18, color: GymColors.accent),
              const SizedBox(width: 6),
              Expanded(
                child: Text('프로그램 변경 제안: ${rec.title}', style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(rec.body, style: const TextStyle(fontSize: 13, height: 1.35)),
          const SizedBox(height: 10),
          if (rec.status == 'pending')
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await svc.rejectRecommendation(rec.id);
                      ref.refreshData();
                    },
                    child: const Text('거절'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(minimumSize: const Size(48, 44)),
                    onPressed: () async {
                      final msg = await svc.applyRecommendation(rec.id);
                      ref.refreshData();
                      if (context.mounted) showSnack(context, msg);
                    },
                    child: const Text('적용'),
                  ),
                ),
              ],
            )
          else
            Pill(rec.status == 'accepted' ? '적용됨' : '거절됨', color: rec.status == 'accepted' ? GymColors.accent : GymColors.textDim),
        ],
      ),
    );
  }
}
