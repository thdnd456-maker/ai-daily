import 'package:ai_gym_lab/app/providers.dart';
import 'package:ai_gym_lab/data/db/database.dart';
import 'package:ai_gym_lab/data/repository.dart';
import 'package:ai_gym_lab/domain/engines/program_generator.dart';
import 'package:ai_gym_lab/domain/models.dart';
import 'package:ai_gym_lab/main.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart' show Size;

Future<void> settle(WidgetTester t, {int rounds = 15}) async {
  for (var i = 0; i < rounds; i++) {
    await t.runAsync(() => Future.delayed(const Duration(milliseconds: 30)));
    await t.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  testWidgets('신규 사용자: 온보딩 시작 화면이 표시된다', (t) async {
    late GymRepository repo;
    await t.runAsync(() async {
      await initializeDateFormatting('ko_KR');
      repo = GymRepository(AppDatabase(NativeDatabase.memory()));
      await repo.init();
    });
    await t.pumpWidget(ProviderScope(overrides: [repositoryProvider.overrideWithValue(repo)], child: const GymLabApp()));
    await settle(t);
    expect(find.text('AI GYM LAB'), findsWidgets);
    expect(find.text('시작하기'), findsOneWidget);
    await t.runAsync(() => repo.db.close());
  });

  testWidgets('홈 → 오늘의 운동 시작 → 세트 완료 → 기록 저장 (오프라인)', (t) async {
    t.view.physicalSize = const Size(1170, 2532);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    late GymRepository repo;
    const profile = UserProfile(daysPerWeek: 4, experience: Experience.y1to3, sessionMinutes: 90, environment: GymEnvironment.fullGym);
    await t.runAsync(() async {
      await initializeDateFormatting('ko_KR');
      repo = GymRepository(AppDatabase(NativeDatabase.memory()));
      await repo.init();
      await repo.saveProfile(profile);
      await repo.saveProgram(ProgramGenerator(repo.exerciseList).generate(profile), source: 'ai');
    });
    await t.pumpWidget(ProviderScope(overrides: [repositoryProvider.overrideWithValue(repo)], child: const GymLabApp()));
    await settle(t);

    expect(find.text('오늘의 운동'), findsOneWidget);
    expect(find.text('상체 A'), findsWidgets);
    expect(find.text('홈'), findsOneWidget);
    expect(find.text('AI 트레이너'), findsWidgets);

    await t.ensureVisible(find.text('오늘의 운동 시작'));
    await t.pump();
    await t.tap(find.text('오늘의 운동 시작'));
    await settle(t);
    // 오늘의 상태: 건너뛰기 → 바로 시작
    expect(find.textContaining('오늘의 상태'), findsOneWidget);
    await t.ensureVisible(find.text('상태 분석'));
    await t.pump();
    await t.tap(find.text('상태 분석'));
    await settle(t);
    expect(find.textContaining('운동 준비 상태'), findsOneWidget);
    await t.ensureVisible(find.text('이대로 시작'));
    await t.pump();
    await t.tap(find.text('이대로 시작'));
    await settle(t, rounds: 25);

    expect(find.text('바벨 벤치프레스'), findsOneWidget);
    expect(find.text('기준 중량 찾기'), findsWidgets); // 기록이 없으므로 중량 단정 안 함

    final session = await t.runAsync(() => repo.inProgressSession());
    expect(session, isNotNull);
    final view = (await t.runAsync(() => repo.getSession(session!.id)))!;
    final firstSet = view.exercises.first.sets.first;
    // 중량 입력(다이얼로그 대신 저장소로) 후 UI에서 완료 버튼 탭
    await t.runAsync(() => repo.updateSet(firstSet.id, weight: 40));
    await t.runAsync(() async {});
    t.container().read(dataVersionProvider.notifier).bump();
    await settle(t);
    await t.tap(find.byTooltip('세트 완료').first);
    await settle(t);

    final after = (await t.runAsync(() => repo.getSession(session!.id)))!;
    expect(after.exercises.first.sets.first.completed, isTrue);
    // 세트 완료 시 휴식 타이머 자동 시작
    expect(find.byTooltip('휴식 종료'), findsOneWidget);
    expect(await t.runAsync(() => repo.getSetting('rest.endAt')), isNotNull);
    await t.runAsync(() => repo.db.close());
  });
}
