import 'package:ai_gym_lab/app/providers.dart';
import 'package:ai_gym_lab/data/db/database.dart';
import 'package:ai_gym_lab/data/repository.dart';
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

void main() {
  testWidgets('작은 화면 + 큰 글씨 + 키보드: 시작하기·다음 버튼을 누를 수 있다', (t) async {
    t.view.physicalSize = const Size(640, 1136); // 320 × 568
    t.view.devicePixelRatio = 2;
    t.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(t.view.reset);
    addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
    late GymRepository repo;
    await t.runAsync(() async {
      await initializeDateFormatting('ko_KR');
      repo = GymRepository(AppDatabase(NativeDatabase.memory()));
      await repo.init();
    });
    await t.pumpWidget(ProviderScope(overrides: [repositoryProvider.overrideWithValue(repo)], child: const GymLabApp()));
    await settle(t);

    // 시작하기 버튼이 화면 안에 있고 눌린다 (warnIfMissed=false 대신 실제 히트 확인)
    final start = find.text('시작하기');
    expect(t.getRect(start).bottom, lessThanOrEqualTo(568));
    await t.tap(start);
    await settle(t);
    expect(find.text('기본 정보'), findsOneWidget);

    // 키보드가 화면 절반을 덮어도 '다음' 버튼이 키보드 위에 보인다
    t.view.viewInsets = const FakeViewPadding(bottom: 560);
    await t.tap(find.byType(TextField).at(0));
    await t.enterText(find.byType(TextField).at(0), '29');
    await settle(t);
    final next = find.text('다음');
    expect(t.getRect(next).bottom, lessThanOrEqualTo(568 - 280));
    final list = find.byType(Scrollable).first;
    for (final (label, v) in [('키', '175'), ('체중', '72')]) {
      final f = find.widgetWithText(TextField, label);
      await t.scrollUntilVisible(f, 80, scrollable: list);
      await t.enterText(f, v);
      await t.pump();
    }
    await t.tap(next);
    await settle(t);
    expect(find.text('운동 목적'), findsOneWidget);
    await t.runAsync(() => repo.db.close());
  });
}
