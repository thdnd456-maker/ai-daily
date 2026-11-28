import 'app/update_dialog.dart';

import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

import 'app/providers.dart';
import 'app/rest_timer.dart';
import 'app/theme.dart';
import 'data/db/database.dart';
import 'data/repository.dart';
import 'domain/engines/program_generator.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/program/program_review_screen.dart';
import 'features/shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 기본 시작 화면(로고)에 머물지 않도록 즉시 준비 화면을 띄우고, 그 안에서 단계별로 초기화합니다.
  runApp(const BootApp());
}

/// 단계별 초기화 화면: 진행 단계 표시, 멈춤(타임아웃)·오류 시 내용 표시 및 재시도
class BootApp extends StatefulWidget {
  const BootApp({super.key});
  @override
  State<BootApp> createState() => _BootAppState();
}

class _BootAppState extends State<BootApp> {
  String _step = '시작 준비 중';
  String? _error;
  final _log = <String>[];

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<T> _run<T>(String label, Future<T> Function() f, {Duration timeout = const Duration(seconds: 20)}) async {
    if (mounted) setState(() => _step = label);
    final sw = Stopwatch()..start();
    try {
      final r = await f().timeout(timeout);
      _log.add('✓ $label (${sw.elapsedMilliseconds}ms)');
      return r;
    } on TimeoutException {
      _log.add('✗ $label: ${timeout.inSeconds}초 동안 응답 없음');
      rethrow;
    } catch (e) {
      _log.add('✗ $label: $e');
      rethrow;
    }
  }

  Future<GymRepository> _openRepository() async {
    // 1차: drift_flutter 기본 방식(백그라운드 isolate)
    try {
      final db = AppDatabase(driftDatabase(name: 'ai_gym_lab'));
      await _run('데이터베이스 열기', () => db.customSelect('SELECT 1').get(), timeout: const Duration(seconds: 12));
      return GymRepository(db);
    } catch (_) {
      // 2차: 같은 파일을 메인 isolate에서 직접 열기
      final dir = await getApplicationDocumentsDirectory();
      final db = AppDatabase(NativeDatabase(File(p.join(dir.path, 'ai_gym_lab.sqlite'))));
      await _run('데이터베이스 열기 (대체 방식)', () => db.customSelect('SELECT 1').get());
      return GymRepository(db);
    }
  }

  Future<void> _boot() async {
    setState(() {
      _error = null;
      _log.clear();
    });
    try {
      await _run('날짜 형식 준비', () => initializeDateFormatting('ko_KR'));
      final repo = await _openRepository();
      await _run('운동 데이터 준비', repo.init, timeout: const Duration(seconds: 30));
      try {
        await _run('알림 설정', Notifications.init, timeout: const Duration(seconds: 5));
      } catch (_) {
        // 알림 실패는 앱 사용을 막지 않음
      }
      runApp(ProviderScope(overrides: [repositoryProvider.overrideWithValue(repo)], child: const GymLabApp()));
    } catch (e, st) {
      if (mounted) setState(() => _error = '$e\n\n${st.toString().split('\n').take(6).join('\n')}');
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: buildTheme(),
    home: Scaffold(
      body: SafeArea(
        child: _error == null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.fitness_center, size: 56, color: GymColors.accent),
                    const SizedBox(height: 16),
                    const Text('AI GYM LAB', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 24),
                    const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 3)),
                    const SizedBox(height: 12),
                    Text(_step, style: const TextStyle(color: GymColors.textDim)),
                  ],
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const Icon(Icons.error_outline, size: 48, color: GymColors.danger),
                  const SizedBox(height: 12),
                  const Text('앱을 시작하지 못했습니다', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  const Text('이 화면을 캡처해서 보내주세요.', style: TextStyle(color: GymColors.textDim)),
                  const SizedBox(height: 16),
                  for (final l in _log) Text(l, style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 12),
                  SelectableText(_error!, style: const TextStyle(fontSize: 12, color: GymColors.textDim)),
                  const SizedBox(height: 16),
                  FilledButton(onPressed: _boot, child: const Text('다시 시도')),
                ],
              ),
      ),
    ),
  );
}

class GymLabApp extends StatelessWidget {
  const GymLabApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'AI GYM LAB',
    debugShowCheckedModeBanner: false,
    theme: buildTheme(),
    darkTheme: buildTheme(),
    themeMode: ThemeMode.dark,
    // 시스템 글자 크기가 아주 크면 버튼이 화면 밖으로 밀리지 않도록 최대 1.3배로 제한
    builder: (context, child) {
      final mq = MediaQuery.of(context);
      return MediaQuery(
        data: mq.copyWith(textScaler: mq.textScaler.clamp(maxScaleFactor: 1.3)),
        child: child!,
      );
    },
    home: const UpdateCheckHost(child: RootGate()),
  );
}

/// 프로필이 없으면 온보딩 → 프로그램이 없으면 추천 프로그램 확인 → 메인 화면
class RootGate extends ConsumerWidget {
  const RootGate({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gate = ref.watch(gateProvider);
    return gate.when(
      skipLoadingOnReload: true,
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('오류: $e'))),
      data: (g) {
        final (profile, program) = g;
        if (profile == null) return const OnboardingScreen();
        if (program == null) {
          final plan = ProgramGenerator(ref.read(repositoryProvider).exerciseList).generate(profile);
          return ProgramReviewScreen(plan: plan, isNew: true, isRoot: true);
        }
        return const MainShell();
      },
    );
  }
}
