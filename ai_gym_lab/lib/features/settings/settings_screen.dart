import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';

import '../../ai/ai_providers.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../app/widgets.dart';
import '../../domain/catalog/research.dart';
import '../../domain/models.dart';
import '../exercise/exercise_library_screen.dart';
import '../onboarding/onboarding_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final data = await ref.read(repositoryProvider).exportAll();
    final json = const JsonEncoder.withIndent('  ').convert(data);
    Directory dir;
    try {
      dir = (Platform.isAndroid ? await getExternalStorageDirectory() : null) ?? await getApplicationDocumentsDirectory();
    } catch (_) {
      dir = await getApplicationDocumentsDirectory();
    }
    final ts = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
    final f = File('${dir.path}/ai_gym_lab_export_$ts.json');
    await f.writeAsString(json);
    await Clipboard.setData(ClipboardData(text: json));
    if (context.mounted) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('내보내기 완료'),
          content: SelectableText('JSON 파일로 저장했고 클립보드에도 복사했습니다.\n\n${f.path}'),
          actions: [FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('확인'))],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).value;
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        children: [
          const _Header('내 정보'),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('프로필 · 목표 · 기구 · 신체 상태'),
            subtitle: profile == null
                ? null
                : Text('${profile.experience.ko} · 주 ${profile.daysPerWeek}일 · ${profile.sessionMinutes}분 · ${profile.goals.map((g) => g.ko).join(', ')}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: profile == null
                ? null
                : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => OnboardingScreen(initial: profile, editMode: true))),
          ),
          const _Header('운동'),
          ListTile(
            leading: const Icon(Icons.scale_outlined),
            title: const Text('기구별 중량 증가 단위'),
            subtitle: const Text('예: 머신 5kg, 덤벨 2kg'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const IncrementSettingsScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.menu_book_outlined),
            title: const Text('운동 데이터베이스'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ExerciseLibraryScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.science_outlined),
            title: const Text('연구 근거 라이브러리'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ResearchScreen())),
          ),
          const _Header('AI'),
          ListTile(
            leading: const Icon(Icons.smart_toy_outlined),
            title: const Text('AI 트레이너 연결 · 사용량 제한'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AiSettingsScreen())),
          ),
          const _Header('데이터'),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('데이터 내보내기 (JSON)'),
            subtitle: const Text('API 키는 포함되지 않습니다'),
            onTap: () => _export(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever_outlined, color: GymColors.danger),
            title: const Text('모든 데이터 삭제', style: TextStyle(color: GymColors.danger)),
            subtitle: const Text('프로필·프로그램·운동 기록·신체 기록·대화가 삭제됩니다'),
            onTap: () async {
              if (!await confirm(context, '모든 데이터 삭제', '이 기기의 모든 개인 데이터를 삭제합니다. 되돌릴 수 없습니다. 먼저 내보내기를 권장합니다.', ok: '삭제', danger: true)) return;
              await ref.read(repositoryProvider).deleteAllUserData();
              ref.refreshData();
              if (context.mounted) Navigator.of(context).popUntil((r) => r.isFirst);
            },
          ),
          const _Header('정보'),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: Text(
              'AI GYM LAB은 의료기기가 아니며 진단·치료를 하지 않습니다. 통증·질환 정보는 운동 조정 참고용입니다.\n\n'
              '운동 처방(중량·반복·세트)은 검증 가능한 규칙 기반 엔진이 계산하며, AI 언어모델은 설명과 질의응답, 변경 제안에만 사용됩니다.\n\n'
              '모든 데이터는 이 기기에만 저장됩니다(서버 없음).',
              style: TextStyle(color: GymColors.textDim, height: 1.4, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String t;
  const _Header(this.t);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
    child: Text(
      t,
      style: const TextStyle(color: GymColors.accent, fontWeight: FontWeight.w800),
    ),
  );
}

class IncrementSettingsScreen extends ConsumerStatefulWidget {
  const IncrementSettingsScreen({super.key});
  @override
  ConsumerState<IncrementSettingsScreen> createState() => _IncrementSettingsScreenState();
}

class _IncrementSettingsScreenState extends ConsumerState<IncrementSettingsScreen> {
  final Map<Equipment, double> _v = {};
  static const _eqs = [
    Equipment.barbell,
    Equipment.dumbbell,
    Equipment.machine,
    Equipment.cable,
    Equipment.smith,
    Equipment.ezBar,
    Equipment.legPress,
    Equipment.hackSquat,
    Equipment.specialtyMachine,
    Equipment.kettlebell,
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(repositoryProvider);
    for (final e in _eqs) {
      _v[e] = double.tryParse(await repo.getSetting('increment.${e.name}') ?? '') ?? e.defaultIncrementKg;
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('중량 증가 단위')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('자동 중량 증가와 입력 +/- 버튼에 사용됩니다. 내가 다니는 헬스장의 실제 원판/핀 단위에 맞추세요.', style: TextStyle(color: GymColors.textDim)),
        const SizedBox(height: 12),
        for (final e in _eqs)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(child: Text(e.ko, style: const TextStyle(fontSize: 15))),
                SizedBox(
                  width: 170,
                  child: NumberStepper(
                    label: 'kg',
                    value: _v[e],
                    step: 0.5,
                    min: 0.5,
                    max: 20,
                    decimals: 2,
                    onChanged: (x) async {
                      setState(() => _v[e] = x);
                      await ref.read(repositoryProvider).setSetting('increment.${e.name}', '$x');
                      ref.refreshData();
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

class AiSettingsScreen extends ConsumerStatefulWidget {
  const AiSettingsScreen({super.key});
  @override
  ConsumerState<AiSettingsScreen> createState() => _AiSettingsScreenState();
}

class _AiSettingsScreenState extends ConsumerState<AiSettingsScreen> {
  String _provider = 'offline';
  final _key = TextEditingController(), _model = TextEditingController(), _base = TextEditingController();
  final _proxy = TextEditingController(), _token = TextEditingController(), _limit = TextEditingController();
  int _usedToday = 0;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(repositoryProvider);
    _provider = await repo.getSetting('ai.provider') ?? 'offline';
    _key.text = await repo.getSetting('ai.apiKey') ?? '';
    _model.text = await repo.getSetting('ai.model') ?? '';
    _base.text = await repo.getSetting('ai.baseUrl') ?? '';
    _proxy.text = await repo.getSetting('ai.proxyUrl') ?? '';
    _token.text = await repo.getSetting('ai.proxyToken') ?? '';
    _limit.text = await repo.getSetting('ai.dailyLimit') ?? '30';
    _usedToday = await repo.aiRequestsToday();
    if (mounted) setState(() => _loaded = true);
  }

  Future<void> _save() async {
    final repo = ref.read(repositoryProvider);
    String? v(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();
    await repo.setSetting('ai.provider', _provider);
    await repo.setSetting('ai.apiKey', v(_key));
    await repo.setSetting('ai.model', v(_model));
    await repo.setSetting('ai.baseUrl', v(_base));
    await repo.setSetting('ai.proxyUrl', v(_proxy));
    await repo.setSetting('ai.proxyToken', v(_token));
    await repo.setSetting('ai.dailyLimit', '${int.tryParse(_limit.text) ?? 30}');
    ref.refreshData();
    if (mounted) {
      showSnack(context, '저장했습니다.');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final needsKey = _provider == 'anthropic' || _provider == 'openai';
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 트레이너 설정'),
        actions: [TextButton(onPressed: _save, child: const Text('저장'))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('AI가 없어도 운동 기록·자동 중량 추천·오프라인 트레이너는 모두 동작합니다.', style: TextStyle(color: GymColors.textDim)),
          const SizedBox(height: 12),
          RadioGroup<String>(
            groupValue: _provider,
            onChanged: (v) => setState(() => _provider = v!),
            child: Column(
              children: [
                for (final (id, label, sub) in [
                  ('offline', '오프라인 트레이너', '인터넷·비용 없음, 규칙 기반 답변'),
                  ('proxy', '백엔드 프록시 (배포 권장)', 'API 키를 서버에 두고 앱은 프록시로 요청'),
                  ('anthropic', 'Anthropic API (개발/개인용)', '기본 모델 ${AnthropicProvider.defaultModel}'),
                  ('openai', 'OpenAI 호환 API (개발/개인용)', '모델명을 직접 입력'),
                ])
                  RadioListTile<String>(value: id, title: Text(label), subtitle: Text(sub)),
              ],
            ),
          ),
          if (needsKey) ...[
            Card(
              color: GymColors.warn.withValues(alpha: 0.08),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'API 키는 앱 소스코드에 포함되지 않으며, 입력한 키는 이 기기의 로컬 DB에만 저장됩니다. 배포 버전에서는 키를 앱에 넣지 말고 백엔드 프록시를 사용하세요.',
                  style: TextStyle(fontSize: 12, height: 1.4),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _key,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'API 키'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _model,
              decoration: InputDecoration(labelText: '모델', hintText: _provider == 'anthropic' ? AnthropicProvider.defaultModel : '예: 사용하는 모델명'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _base,
              decoration: const InputDecoration(labelText: 'Base URL (선택, 호환 엔드포인트)'),
            ),
          ],
          if (_provider == 'proxy') ...[
            TextField(
              controller: _proxy,
              decoration: const InputDecoration(labelText: '프록시 URL', hintText: 'https://your-server.example/ai/chat'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _token,
              obscureText: true,
              decoration: const InputDecoration(labelText: '앱 인증 토큰 (선택)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _model,
              decoration: const InputDecoration(labelText: '모델 (선택, 서버 기본값 사용 시 비움)'),
            ),
            const SizedBox(height: 6),
            const Text(
              '요청: {"system","messages","model"} → 응답: {"text","model","usage"} (README 참고)',
              style: TextStyle(color: GymColors.textDim, fontSize: 12),
            ),
          ],
          const SizedBox(height: 16),
          const Text('비용 관리', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          TextField(
            controller: _limit,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: '하루 AI 요청 한도', suffixText: '회', helperText: '오늘 사용: $_usedToday회 · 한도 초과 시 오프라인 트레이너가 답변'),
          ),
        ],
      ),
    );
  }
}

class ResearchScreen extends ConsumerWidget {
  const ResearchScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('연구 근거 라이브러리')),
    body: FutureBuilder<List<ResearchReference>>(
      future: ref.read(repositoryProvider).researchLibrary(),
      builder: (_, snap) {
        final list = snap.data;
        if (list == null) return const Center(child: CircularProgressIndicator());
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            const Text(
              '요약은 개발팀이 작성한 것으로 원문을 대체하지 않습니다. 앱이 사용하는 실용 수치(초보자 세트 상한, 복귀 감량 비율 등)는 연구 결과가 아닌 "앱 기본값"으로 따로 표시합니다.',
              style: TextStyle(color: GymColors.textDim, fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 8),
            for (final r in list)
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ExpansionTile(
                  title: Text(r.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  subtitle: Text(
                    '${r.authors.split(',').first} 외 · ${r.year} · ${r.studyType}',
                    style: const TextStyle(color: GymColors.research, fontSize: 12),
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final (k, v) in [
                      ('저자', r.authors),
                      ('학술지', r.journal),
                      ('대상자', r.population),
                      ('주요 결과', r.keyFindings),
                      ('한계점', r.limitations),
                      ('앱 적용', r.appliedIn),
                    ])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(k, style: const TextStyle(color: GymColors.textDim, fontSize: 12)),
                            Text(v, style: const TextStyle(height: 1.35)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    ),
  );
}
