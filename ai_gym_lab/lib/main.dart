import 'package:drift_flutter/drift_flutter.dart';
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
  await initializeDateFormatting('ko_KR');
  final db = AppDatabase(driftDatabase(name: 'ai_gym_lab'));
  final repo = GymRepository(db);
  await repo.init();
  await Notifications.init();
  runApp(ProviderScope(overrides: [repositoryProvider.overrideWithValue(repo)], child: const GymLabApp()));
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
    home: const RootGate(),
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
