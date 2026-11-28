import 'dart:convert';
import 'dart:io';

import 'package:ai_gym_lab/app/research_sync.dart';
import 'package:ai_gym_lab/data/db/database.dart';
import 'package:ai_gym_lab/data/repository.dart';
import 'package:ai_gym_lab/domain/catalog/nutrition_catalog.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

String feed(int version, {String title = '새 논문'}) => jsonEncode({
  'app': 'AI GYM LAB',
  'version': version,
  'updated': '2026-12-01',
  'references': [
    {'id': 'new_1', 'category': 'nutrition', 'title': title, 'authors': 'Kim A', 'year': 2026, 'journal': 'J', 'keyFindings': '요약'},
    {'id': 'bad', 'category': 'other', 'title': 'x', 'year': 2026}, // 분류가 틀리면 버림
    {'id': '', 'category': 'training', 'title': 'y', 'year': 2026}, // id 없으면 버림
  ],
});

void main() {
  test('저장소의 remote/research.json 이 올바른 형식이다', () {
    final r = parseRemoteResearch(File('remote/research.json').readAsStringSync());
    expect(r.version, greaterThanOrEqualTo(1));
    expect(r.items, isNotEmpty);
    final ids = r.items.map((e) => e.$2.id).toList();
    expect(ids.toSet().length, ids.length);
  });

  test('잘못된 파일은 거부', () {
    expect(() => parseRemoteResearch('{"app":"x"}'), throwsFormatException);
    expect(() => parseRemoteResearch('not json'), throwsFormatException);
    expect(parseRemoteResearch(feed(1)).items.length, 1);
  });

  test('새 버전이면 반영, 하루 안에는 다시 받지 않음, 낮은 버전은 무시', () async {
    final repo = GymRepository(AppDatabase(NativeDatabase.memory()));
    await repo.init();
    // 식단 논문도 라이브러리에 들어 있음
    final lib0 = await repo.researchLibrary();
    expect(lib0.map((r) => r.id), containsAll(nutritionReferences.map((r) => r.id)));

    var body = feed(2);
    var calls = 0;
    final client = MockClient((req) async {
      calls++;
      expect(req.url.toString(), researchFeedUrl);
      return http.Response.bytes(utf8.encode(body), 200);
    });
    final sync = ResearchSync(repo, client: client);
    final t = DateTime(2026, 12, 1, 9);

    expect(await sync.run(now: t), isTrue);
    expect((await repo.researchLibrary()).any((r) => r.id == 'new_1'), isTrue);
    expect((await ResearchSync.cached(repo))!.category('nutrition').single.title, '새 논문');

    // 같은 날 다시 켜면 인터넷 확인 안 함
    expect(await sync.run(now: t.add(const Duration(hours: 3))), isFalse);
    expect(calls, 1);

    // 다음 날, 버전이 같거나 낮으면 그대로
    body = feed(1, title: '옛 내용');
    expect(await sync.run(now: t.add(const Duration(days: 1))), isFalse);
    expect((await ResearchSync.cached(repo))!.version, 2);

    // 버전이 오르면 고친 내용 반영
    body = feed(3, title: '고친 논문');
    expect(await sync.run(now: t.add(const Duration(days: 2))), isTrue);
    expect((await repo.researchLibrary()).firstWhere((r) => r.id == 'new_1').title, '고친 논문');

    // 서버 오류면 조용히 넘어감
    final down = ResearchSync(repo, client: MockClient((_) async => http.Response('', 500)));
    expect(await down.run(force: true), isFalse);
    await repo.db.close();
  });
}
