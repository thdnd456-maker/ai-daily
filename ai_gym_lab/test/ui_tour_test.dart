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
import 'package:material_ui/material_ui.dart';

Future<void> settle(WidgetTester t, {int rounds = 15}) async {
  for (var i = 0; i < rounds; i++) {
    await t.runAsync(() => Future.delayed(const Duration(milliseconds: 30)));
    await t.pump(const Duration(milliseconds: 50));
  }
}

/// 지난 3주간 기록을 만들어 통계/추천/트레이너가 실제 데이터로 동작하는지 확인
Future<void> seedHistory(GymRepository repo) async {
  final program = (await repo.getActiveProgram())!;
  final start = DateTime.now().subtract(const Duration(days: 20));
  for (var k = 0; k < 8; k++) {
    final day = k % program.days.length;
    final t = start.add(Duration(days: k * 2 + (k ~/ 4)));
    final sid = await repo.startSession(program: program, dayIndex: day, now: t);
    final s = (await repo.getSession(sid))!;
    for (final e in s.exercises) {
      for (final set in e.sets) {
        await repo.updateSet(set.id, weight: set.actualWeight ?? 20.0 + k, reps: (set.actualReps ?? 8), rir: 2);
        await repo.setCompleted(set.id, true);
      }
    }
    await repo.finishSession(sid, at: t.add(const Duration(minutes: 62)));
  }
  await repo.addMeasurement(date: start, weight: 75);
  await repo.addMeasurement(date: start.add(const Duration(days: 10)), weight: 74.4);
  await repo.addMeasurement(date: DateTime.now(), weight: 74.0, bodyFat: 18);
}

void main() {
  testWidgets('UI 투어 (360pt 폭): 모든 탭·주요 화면이 오류 없이 렌더링된다', (t) async {
    t.view.physicalSize = const Size(1080, 2400);
    t.view.devicePixelRatio = 3; // 360 × 800 논리 픽셀
    addTearDown(t.view.reset);
    late GymRepository repo;
    const profile = UserProfile(
      daysPerWeek: 4,
      experience: Experience.m6to12,
      sessionMinutes: 60,
      environment: GymEnvironment.standardGym,
      goals: [Goal.hypertrophy, Goal.fatLoss],
      limitations: [Limitation(area: JointArea.knee, severity: 4, timing: '깊게 앉을 때')],
    );
    await t.runAsync(() async {
      await initializeDateFormatting('ko_KR');
      repo = GymRepository(AppDatabase(NativeDatabase.memory()));
      await repo.init();
      await repo.saveProfile(profile);
      await repo.saveProgram(ProgramGenerator(repo.exerciseList).generate(profile), source: 'ai');
      await seedHistory(repo);
    });
    await t.pumpWidget(ProviderScope(overrides: [repositoryProvider.overrideWithValue(repo)], child: const GymLabApp()));
    await settle(t, rounds: 25);

    // 홈: 기록이 있으므로 이번 주 운동/최근 성과
    expect(find.text('오늘의 운동'), findsOneWidget);
    expect(find.textContaining('이번 주 운동'), findsOneWidget);

    // 운동 탭
    await t.tap(find.text('운동').last);
    await settle(t);
    expect(find.text('주간 운동 일정'), findsOneWidget);
    await t.tap(find.text('구성 이유'));
    await settle(t);
    expect(find.text('프로그램 구성 이유'), findsOneWidget);
    expect(find.text('연구 근거'), findsWidgets);
    expect(find.text('앱 기본값(개발자 실용 권장값)'), findsWidgets);
    await t.tapAt(const Offset(180, 40));
    await settle(t);

    // 프로그램 수정 화면
    await t.tap(find.text('수정'));
    await settle(t);
    expect(find.text('운동 추가'), findsOneWidget);
    await t.pageBack();
    await settle(t);

    // 운동 데이터베이스 → 상세
    await t.tap(find.byTooltip('운동 데이터베이스'));
    await settle(t);
    await t.enterText(find.byType(TextField).first, '벤치');
    await settle(t);
    await t.tap(find.text('바벨 벤치프레스').first);
    await settle(t);
    expect(find.text('올바른 자세'), findsOneWidget);
    await t.pageBack();
    await settle(t);
    await t.pageBack();
    await settle(t);

    // 기록 탭
    await t.tap(find.text('기록').last);
    await settle(t);
    expect(find.textContaining('세트 · 볼륨'), findsWidgets);
    await t.tap(find.text('신체 변화'));
    await settle(t);
    expect(find.text('현재 체중'), findsOneWidget);

    // 통계 탭
    await t.tap(find.text('통계').last);
    await settle(t, rounds: 25);
    expect(find.text('최근 4주 분석'), findsOneWidget);
    expect(find.textContaining('근육별 주간 세트'), findsOneWidget);
    await t.scrollUntilVisible(find.text('체중 변화'), 400, scrollable: find.byType(Scrollable).last);
    await settle(t);

    // AI 트레이너 (오프라인): 중량 질문 + 시간 변경 제안 → 승인
    await t.tap(find.text('AI 트레이너').last);
    await settle(t);
    await t.tap(find.text('오늘 벤치프레스 몇 kg으로 해야 해?').first);
    await settle(t, rounds: 30);
    expect(find.textContaining('추천:'), findsWidgets);
    await t.enterText(find.byType(TextField).last, '운동 시간을 40분으로 줄여줘.');
    await t.tap(find.byIcon(Icons.send));
    await settle(t, rounds: 30);
    expect(find.textContaining('프로그램 변경 제안'), findsOneWidget);
    await t.ensureVisible(find.text('적용').last);
    await t.pump();
    await t.tap(find.text('적용').last);
    await settle(t, rounds: 30);
    expect(find.text('적용됨'), findsOneWidget);
    final p = await t.runAsync(() => repo.getProfile());
    expect(p!.sessionMinutes, 40);
    final active = (await t.runAsync(() => repo.getActiveProgram()))!;
    expect(active.row.source, 'user'); // AI 원본은 보존, 수정본 활성화
    for (final d in active.toPlan().days) {
      expect(ProgramGenerator.estimateMinutes(d.exercises), lessThanOrEqualTo(40));
    }

    // 설정 → AI 설정 / 연구 라이브러리
    await t.tap(find.text('홈').last);
    await settle(t);
    await t.tap(find.byIcon(Icons.settings_outlined));
    await settle(t);
    await t.tap(find.text('연구 근거 라이브러리'));
    await settle(t);
    expect(find.textContaining('2024'), findsWidgets);
    await t.pageBack();
    await settle(t);
    await t.tap(find.text('AI 트레이너 연결 · 사용량 제한'));
    await settle(t);
    expect(find.text('오프라인 트레이너'), findsOneWidget);
    await t.pageBack();
    await settle(t);

    await t.runAsync(() => repo.db.close());
  });

  testWidgets('온보딩 전 단계 (360pt 폭) → 추천 프로그램 화면', (t) async {
    t.view.physicalSize = const Size(1080, 2400);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    late GymRepository repo;
    await t.runAsync(() async {
      await initializeDateFormatting('ko_KR');
      repo = GymRepository(AppDatabase(NativeDatabase.memory()));
      await repo.init();
    });
    await t.pumpWidget(ProviderScope(overrides: [repositoryProvider.overrideWithValue(repo)], child: const GymLabApp()));
    await settle(t);
    await t.tap(find.text('시작하기'));
    await settle(t);
    final fields = find.byType(TextField);
    await t.enterText(fields.at(0), '29');
    await t.enterText(fields.at(1), '175');
    await t.enterText(fields.at(2), '72');
    await t.tap(find.text('다음'));
    await settle(t);
    await t.tap(find.text('근육량 증가'));
    await t.tap(find.text('체지방 감소'));
    await settle(t);
    expect(find.text('우선순위'), findsOneWidget);
    await t.tap(find.text('다음'));
    await settle(t);
    await t.tap(find.text('3개월 미만'));
    await t.tap(find.text('다음'));
    await settle(t);
    await t.tap(find.text('주 5일'));
    await t.tap(find.text('다음'));
    await settle(t);
    await t.tap(find.text('다음'));
    await settle(t);
    await t.tap(find.text('무릎 통증'));
    await settle(t);
    expect(find.textContaining('강도 4/10'), findsOneWidget);
    await t.tap(find.text('내 프로그램 만들기'));
    await settle(t, rounds: 25);
    expect(find.text('추천 운동 프로그램'), findsOneWidget);
    // 초보자 + 주 5일 → 주 4일로 시작 안내
    await t.scrollUntilVisible(find.textContaining('주 4일로 시작'), 500, scrollable: find.byType(Scrollable).last);
    expect(find.textContaining('주 4일로 시작'), findsWidgets);
    await t.tap(find.text('이 프로그램으로 시작'));
    await settle(t, rounds: 25);
    expect(find.text('오늘의 운동'), findsOneWidget);
    final prog = (await t.runAsync(() => repo.getActiveProgram()))!;
    expect(prog.days.length, 4);
    final saved = await t.runAsync(() => repo.getProfile());
    expect(saved!.goals, [Goal.hypertrophy, Goal.fatLoss]);
    expect(saved.limitations.single.area, JointArea.knee);
    await t.runAsync(() => repo.db.close());
  });
}
