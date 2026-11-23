import 'dart:convert';
import 'dart:io';

import 'package:ai_gym_lab/data/db/database.dart';
import 'package:ai_gym_lab/data/repository.dart';
import 'package:ai_gym_lab/domain/catalog/exercise_catalog.dart';
import 'package:ai_gym_lab/domain/engines/program_generator.dart';
import 'package:ai_gym_lab/domain/engines/progression_engine.dart';
import 'package:ai_gym_lab/domain/models.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory dir;
  late File file;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('gymlab');
    file = File('${dir.path}/test.sqlite');
  });
  tearDown(() => dir.deleteSync(recursive: true));

  Future<GymRepository> open() async {
    final repo = GymRepository(AppDatabase(NativeDatabase(file)));
    await repo.init();
    return repo;
  }

  const profile = UserProfile(daysPerWeek: 4, experience: Experience.y1to3, sessionMinutes: 90, environment: GymEnvironment.fullGym);

  test('시드: 운동 150개 이상이 DB에 저장되고 다시 읽힌다', () async {
    final repo = await open();
    expect(repo.exercises.length, greaterThanOrEqualTo(150));
    expect(repo.exercises['barbell_bench_press']!.primary, [Muscle.chest]);
    expect(repo.exercises['barbell_bench_press']!.alternatives, contains('machine_chest_press'));
    await repo.db.close();
  });

  test('전체 흐름(인터넷/AI 없이): 프로그램 생성 → 운동 기록 → 앱 재실행 후 유지 → 다음 운동 자동 증가', () async {
    var repo = await open();
    await repo.saveProfile(profile);
    final plan = ProgramGenerator(repo.exerciseList).generate(profile);
    final pid = await repo.saveProgram(plan, source: 'ai');
    var program = (await repo.getActiveProgram())!;
    expect(program.row.id, pid);
    expect(await repo.nextDayIndex(program), 0);

    final t0 = DateTime(2026, 11, 16, 18);
    final sid = await repo.startSession(program: program, dayIndex: 0, now: t0);
    var s = (await repo.getSession(sid))!;
    final bench = s.exercises.first;
    expect(bench.exercise.id, 'barbell_bench_press');
    expect(bench.recommendation!.action, ProgressionAction.establishBaseline);
    expect(bench.sets.first.targetWeight, isNull); // 기록이 없으면 중량 단정 안 함

    // 40kg × 8 × 3, RIR 2 기록
    for (final set in bench.sets) {
      await repo.updateSet(set.id, weight: 40, reps: 8, rir: 2);
      await repo.setCompleted(set.id, true);
      await repo.setCompleted(set.id, true); // 중복 탭
    }
    await repo.addSet(bench.row.id);
    await repo.removeLastSet(bench.row.id);

    // 앱 종료 후 재실행 → 진행 중 운동 유지
    await repo.db.close();
    repo = await open();
    final inProgress = await repo.inProgressSession();
    expect(inProgress?.id, sid);
    s = (await repo.getSession(sid))!;
    final restored = s.exercises.first.sets;
    expect(restored.length, 3); // 중복 저장 없음
    expect(restored.every((x) => x.completed && x.actualWeight == 40 && x.actualReps == 8), isTrue);

    // 이미 진행 중이면 새 세션을 만들지 않음
    program = (await repo.getActiveProgram())!;
    expect(await repo.startSession(program: program, dayIndex: 0), sid);

    await repo.finishSession(sid, at: t0.add(const Duration(minutes: 70)));
    expect(await repo.inProgressSession(), isNull);
    expect(await repo.nextDayIndex(program), 1); // 다음 순서: 하체 A

    // 상체 A를 다시 하면 벤치 42.5kg 추천
    final rec = await repo.recommendFor(
      repo.exercises['barbell_bench_press']!,
      sets: 3,
      repMin: 6,
      repMax: 8,
      targetRir: 2,
      now: t0.add(const Duration(days: 3)),
    );
    expect(rec.action, ProgressionAction.increaseWeight);
    expect(rec.weight, 42.5);
    await repo.db.close();
  });

  test('같은 세트 번호는 중복 저장되지 않는다(DB 제약)', () async {
    final repo = await open();
    await repo.saveProfile(profile);
    await repo.saveProgram(ProgramGenerator(repo.exerciseList).generate(profile), source: 'ai');
    final program = (await repo.getActiveProgram())!;
    final sid = await repo.startSession(program: program, dayIndex: 0);
    final s = (await repo.getSession(sid))!;
    final se = s.exercises.first;
    await expectLater(
      repo.db
          .into(repo.db.workoutSets)
          .insert(WorkoutSetsCompanion.insert(sessionId: sid, sessionExerciseId: se.row.id, exerciseId: se.exercise.id, setNumber: 1)),
      throwsA(isA<SqliteException>()),
    );
    await repo.db.close();
  });

  test('대체 운동은 기존 중량을 그대로 적용하지 않는다', () async {
    final repo = await open();
    await repo.saveProfile(profile);
    await repo.saveProgram(ProgramGenerator(repo.exerciseList).generate(profile), source: 'ai');
    final program = (await repo.getActiveProgram())!;
    final sid = await repo.startSession(program: program, dayIndex: 0);
    var s = (await repo.getSession(sid))!;
    final se = s.exercises.first;
    for (final x in se.sets) {
      await repo.updateSet(x.id, weight: 60, reps: 8);
    }
    await repo.substitute(se.row.id, 'machine_chest_press');
    s = (await repo.getSession(sid))!;
    final sub = s.exercises.first;
    expect(sub.exercise.id, 'machine_chest_press');
    expect(sub.row.substitutedFrom, 'barbell_bench_press');
    expect(sub.sets.every((x) => x.actualWeight == null), isTrue);
    await repo.db.close();
  });

  test('AI 프로그램을 수정하면 원본은 보존되고 사용자 버전이 저장된다', () async {
    final repo = await open();
    final pid = await repo.saveProgram(ProgramGenerator(exerciseCatalog).generate(profile), source: 'ai');
    final p = (await repo.getProgram(pid))!;
    final plan = p.toPlan();
    final edited = ProgramPlan(
      name: plan.name,
      split: plan.split,
      rationale: plan.rationale,
      days: [
        plan.days.first.copyWith(exercises: plan.days.first.exercises.sublist(1)),
        ...plan.days.skip(1),
      ],
    );
    final newId = await repo.updateProgram(pid, edited);
    expect(newId, isNot(pid));
    final all = await repo.listPrograms();
    expect(all.length, 2);
    expect(all.where((x) => x.isActive).single.id, newId);
    expect((await repo.getProgram(pid))!.days.first.exercises.length, plan.days.first.exercises.length);
    await repo.db.close();
  });

  test('데이터 내보내기 및 전체 삭제', () async {
    final repo = await open();
    await repo.saveProfile(profile);
    await repo.setSetting('ai.apiKey', 'secret');
    final json = await repo.exportAll();
    expect((json['user_profiles'] as List).length, 1);
    expect(json.toString(), isNot(contains('secret')));
    await repo.deleteAllUserData();
    expect(await repo.getProfile(), isNull);
    expect(await repo.db.exercises.count().getSingle(), greaterThanOrEqualTo(150));
    await repo.db.close();
  });
  test('기록 옮기기: 내보내기 → 새 설치(빈 DB)에 불러오기 → 기록·다음 추천이 같다', () async {
    // 이전 폰: 프로필·프로그램·운동 1회 기록
    final old = await open();
    await old.saveProfile(profile);
    await old.saveProgram(ProgramGenerator(old.exerciseList).generate(profile), source: 'ai');
    final program = (await old.getActiveProgram())!;
    final t0 = DateTime(2026, 11, 16, 18);
    final sid = await old.startSession(program: program, dayIndex: 0, now: t0);
    final bench = (await old.getSession(sid))!.exercises.first;
    for (final set in bench.sets) {
      await old.updateSet(set.id, weight: 40, reps: 8, rir: 2);
      await old.setCompleted(set.id, true);
    }
    await old.finishSession(sid, at: t0.add(const Duration(minutes: 70)));
    // 실제 앱처럼 JSON 문자열(클립보드)을 거쳐 옮김
    final text = jsonEncode(await old.exportAll());
    await old.db.close();

    // 새 폰: 빈 DB
    final newFile = File('${dir.path}/new.sqlite');
    final repo = GymRepository(AppDatabase(NativeDatabase(newFile)));
    await repo.init();
    expect(await repo.getProfile(), isNull);
    final r = await repo.importAll(jsonDecode(text) as Map<String, dynamic>);
    expect(r.sessions, 1);
    expect(r.sets, ((jsonDecode(text) as Map)['workout_sets'] as List).length);
    expect(r.sets, greaterThan(bench.sets.length));
    expect(r.skipped, 0);

    expect((await repo.getProfile())!.daysPerWeek, 4);
    final p2 = (await repo.getActiveProgram())!;
    expect(p2.days.length, program.days.length);
    expect(await repo.nextDayIndex(p2), 1);
    final s2 = (await repo.getSession(sid))!;
    expect(s2.exercises.first.sets.every((x) => x.completed && x.actualWeight == 40 && x.actualReps == 8), isTrue);
    final rec = await repo.recommendFor(
      repo.exercises['barbell_bench_press']!,
      sets: 3,
      repMin: 6,
      repMax: 8,
      targetRir: 2,
      now: t0.add(const Duration(days: 3)),
    );
    expect(rec.weight, 42.5);

    // 같은 내용을 두 번 불러와도 중복되지 않음
    await repo.importAll(jsonDecode(text) as Map<String, dynamic>);
    expect(await repo.db.workoutSessions.count().getSingle(), 1);
    await repo.db.close();
  });

  test('기록 불러오기: 잘못된 데이터는 거부하고 기존 기록을 지우지 않는다', () async {
    final repo = await open();
    await repo.saveProfile(profile);
    await expectLater(repo.importAll({'app': 'other'}), throwsA(isA<FormatException>()));
    // 형식은 맞지만 중간에 깨진 데이터 → 전체 취소
    await expectLater(
      repo.importAll({
        'app': 'AI GYM LAB',
        'schemaVersion': 1,
        'user_profiles': [
          {'userId': 1},
        ],
      }),
      throwsA(anything),
    );
    expect((await repo.getProfile())!.daysPerWeek, 4);
    await repo.db.close();
  });
  test('중량 이어 채우기: 첫 세트에 넣은 중량이 뒤 세트에 자동으로 들어간다', () async {
    final repo = await open();
    await repo.saveProfile(profile);
    await repo.saveProgram(ProgramGenerator(repo.exerciseList).generate(profile), source: 'ai');
    final program = (await repo.getActiveProgram())!;
    final sid = await repo.startSession(program: program, dayIndex: 0);
    Future<List<double?>> weights() async => (await repo.getSession(sid))!.exercises.first.sets.map((x) => x.actualWeight).toList();
    final sets = (await repo.getSession(sid))!.exercises.first.sets;
    expect(sets.length, greaterThanOrEqualTo(3));
    expect(await weights(), everyElement(isNull)); // 첫 기록: 비어 있음

    // 1세트에 40kg 입력 → 뒤 세트 모두 40kg
    await repo.updateSet(sets[0].id, weight: 40);
    expect(await weights(), everyElement(40.0));

    // 1세트 완료 후 2세트를 45kg로 바꾸면 → 1세트는 그대로, 뒤 세트만 45kg
    await repo.setCompleted(sets[0].id, true);
    await repo.updateSet(sets[1].id, weight: 45);
    var w = await weights();
    expect(w[0], 40);
    expect(w.skip(1), everyElement(45.0));

    // 마지막 세트를 따로 30kg(드롭 세트)로 바꾼 뒤 2세트를 50kg로 → 마지막 세트는 30kg 유지
    await repo.updateSet(sets.last.id, weight: 30);
    await repo.updateSet(sets[1].id, weight: 50);
    w = await weights();
    expect(w[1], 50);
    expect(w.last, 30);
    if (w.length > 3) expect(w.sublist(2, w.length - 1), everyElement(50.0));

    // 반복 횟수만 바꾸면 중량은 그대로
    await repo.updateSet(sets[1].id, reps: 5);
    expect(await weights(), w);
    await repo.db.close();
  });
}
