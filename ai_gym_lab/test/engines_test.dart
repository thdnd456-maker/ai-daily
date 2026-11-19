import 'package:ai_gym_lab/domain/catalog/exercise_catalog.dart';
import 'package:ai_gym_lab/domain/catalog/research.dart';
import 'package:ai_gym_lab/domain/engines/program_generator.dart';
import 'package:ai_gym_lab/domain/engines/progression_engine.dart';
import 'package:ai_gym_lab/domain/engines/recovery_engine.dart';
import 'package:ai_gym_lab/domain/engines/schedule_engine.dart';
import 'package:ai_gym_lab/domain/engines/stats_engine.dart';
import 'package:ai_gym_lab/domain/engines/substitution_engine.dart';
import 'package:ai_gym_lab/domain/engines/volume_engine.dart';
import 'package:ai_gym_lab/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

const pe = ProgressionEngine();
final bench = exerciseById['barbell_bench_press']!;
final now = DateTime(2026, 11, 19, 18);

ExercisePerformance perf(
  List<int> reps, {
  double w = 40,
  List<int?>? rir,
  int daysAgo = 3,
  bool pain = false,
  bool form = false,
  String id = 'barbell_bench_press',
}) => ExercisePerformance(
  date: now.subtract(Duration(days: daysAgo)),
  exerciseId: id,
  sets: [for (var i = 0; i < reps.length; i++) SetRecord(weight: w, reps: reps[i], rir: rir?[i])],
  pain: pain,
  formUnstable: form,
  targetSets: 3,
  repMin: 6,
  repMax: 8,
);

ProgressionRecommendation rec(List<ExercisePerformance> h, {Readiness r = Readiness.good, Exercise? ex, Experience exp = Experience.y1to3}) =>
    pe.recommend(exercise: ex ?? bench, targetSets: 3, repMin: 6, repMax: 8, history: h, increment: 2.5, now: now, readiness: r, experience: exp);

void main() {
  group('운동 데이터베이스', () {
    test('150개 이상의 운동, ID 중복 없음, 모든 참조 유효', () {
      expect(exerciseCatalog.length, greaterThanOrEqualTo(150));
      expect(exerciseById.length, exerciseCatalog.length);
      for (final e in exerciseCatalog) {
        expect(e.primary, isNotEmpty, reason: e.id);
        expect(e.repMin <= e.repMax, isTrue, reason: e.id);
        for (final a in e.alternatives) {
          expect(exerciseById.containsKey(a), isTrue, reason: '${e.id} → $a');
        }
        for (final r in e.referenceIds) {
          expect(researchById.containsKey(r), isTrue, reason: '${e.id} → $r');
        }
      }
    });
  });

  group('점진적 과부하 엔진', () {
    test('기록이 없으면 중량을 단정하지 않는다', () {
      final r = rec([]);
      expect(r.action, ProgressionAction.establishBaseline);
      expect(r.weight, isNull);
      expect(r.confidence, Confidence.low);
    });

    test('8/8/8 + 여유(RIR≥1) → 40kg → 42.5kg, 반복은 하단부터', () {
      final r = rec([
        perf([8, 8, 8], rir: [2, 2, 1]),
      ]);
      expect(r.action, ProgressionAction.increaseWeight);
      expect(r.weight, 42.5);
      expect(r.targetReps, [6, 6, 6]);
    });

    test('8/8/7 → 40kg 유지 (반복 늘리기)', () {
      final r = rec([
        perf([8, 8, 7], rir: [2, 1, 1]),
      ]);
      expect(r.weight, 40);
      expect(r.action, ProgressionAction.increaseReps);
      expect(r.targetReps, [8, 8, 8]);
    });

    test('7/6/5 → 피로와 난이도 확인(중량 유지)', () {
      final r = rec([
        perf([7, 6, 5]),
      ]);
      expect(r.action, ProgressionAction.maintain);
      expect(r.weight, 40);
      expect(r.reasons.join(), contains('피로와 난이도'));
    });

    test('2회 연속 범위 미달 → 중량 감소', () {
      final r = rec([
        perf([7, 6, 5], daysAgo: 3),
        perf([7, 6, 5], daysAgo: 6),
      ]);
      expect(r.action, ProgressionAction.decreaseWeight);
      expect(r.weight!, lessThan(40));
    });

    test('8/8/8이어도 통증이 있으면 증가 보류', () {
      final r = rec([
        perf([8, 8, 8], rir: [2, 2, 2], pain: true),
      ]);
      expect(r.action, ProgressionAction.maintain);
      expect(r.weight, 40);
    });

    test('통증 2회 연속 → 감량', () {
      final r = rec([
        perf([8, 8, 8], pain: true),
        perf([8, 8, 8], pain: true, daysAgo: 6),
      ]);
      expect(r.action, ProgressionAction.decreaseWeight);
    });

    test('자세 불안정 → 증가 중단', () {
      final r = rec([
        perf([8, 8, 8], rir: [2, 2, 2], form: true),
      ]);
      expect(r.action, ProgressionAction.maintain);
    });

    test('2주 공백 → 복귀 강도 재평가(감량)', () {
      final r = rec([
        perf([8, 8, 8], daysAgo: 15),
      ]);
      expect(r.action, ProgressionAction.decreaseWeight);
      expect(r.weight, 35); // 40 × 0.9 = 36 → 2.5 단위 내림 = 35
    });

    test('RIR 0 도달 → 유지', () {
      final r = rec([
        perf([8, 8, 8], rir: [1, 1, 0]),
      ]);
      expect(r.action, ProgressionAction.maintain);
    });

    test('회복 상태가 낮으면 증가 보류', () {
      final r = rec([
        perf([8, 8, 8], rir: [2, 2, 2]),
      ], r: Readiness.low);
      expect(r.action, ProgressionAction.maintain);
      expect(r.weight, 40);
    });

    test('세트 미완료 → 유지', () {
      final r = rec([
        perf([8, 8]),
      ]);
      expect(r.action, ProgressionAction.maintain);
    });

    test('어시스트 운동은 보조 중량을 줄이는 것이 진행', () {
      final ap = exerciseById['assisted_pull_up']!;
      final r = rec([
        perf([8, 8, 8], w: 30, rir: [2, 2, 2], id: ap.id),
      ], ex: ap);
      expect(r.action, ProgressionAction.increaseWeight);
      expect(r.weight, 27.5);
    });

    test('머신 5kg·덤벨 2kg 단위 반올림', () {
      expect(ProgressionEngine.roundTo(47, 5), 45);
      expect(ProgressionEngine.roundTo(13, 2, down: true), 12);
    });
  });

  group('프로그램 생성 엔진', () {
    final gen = ProgramGenerator(exerciseCatalog);
    final volume = VolumeEngine(exerciseById);

    test('주 4일 + 일반 헬스장 → 상체/하체 2분할 기본 템플릿', () {
      final p = gen.generate(const UserProfile(daysPerWeek: 4, experience: Experience.y1to3, sessionMinutes: 90, environment: GymEnvironment.fullGym));
      expect(p.split, SplitType.upperLower);
      expect(p.days.map((d) => d.name), ['상체 A', '하체 A', '상체 B', '하체 B']);
      expect(p.days.first.exercises.first.exerciseId, 'barbell_bench_press');
    });

    for (final days in [2, 3, 4, 5, 6]) {
      test('초보자에게 과도한 운동량을 추천하지 않는다 (주 $days일)', () {
        const base = UserProfile(experience: Experience.none, sessionMinutes: 90, environment: GymEnvironment.fullGym);
        final p = gen.generate(base.copyWith(daysPerWeek: days));
        final t = weeklyVolumeTarget(base);
        expect(p.days.length, lessThanOrEqualTo(4));
        final v = volume.plannedVolume(p.days);
        for (final m in trackedMuscles) {
          expect(v[m]!.direct, lessThanOrEqualTo(t.max), reason: '${m.ko} ${v[m]!.direct}');
        }
        for (final d in p.days) {
          for (final x in d.exercises) {
            expect(exerciseById[x.exerciseId]!.difficulty, lessThanOrEqualTo(Experience.none.maxDifficulty), reason: x.exerciseId);
          }
        }
      });
    }

    test('홈트레이닝: 사용 불가 기구 운동은 포함되지 않는다', () {
      final p = gen.generate(const UserProfile(daysPerWeek: 3, environment: GymEnvironment.home));
      final eq = GymEnvironment.home.defaultEquipment;
      for (final d in p.days) {
        for (final x in d.exercises) {
          expect(SubstitutionEngine.isAvailable(exerciseById[x.exerciseId]!, eq), isTrue, reason: x.exerciseId);
        }
      }
    });

    test('심한 허리 통증 → 허리 부담 높은 운동 제외', () {
      final p = gen.generate(
        const UserProfile(
          daysPerWeek: 4,
          experience: Experience.y3plus,
          limitations: [Limitation(area: JointArea.lowBack, severity: 7)],
        ),
      );
      for (final d in p.days) {
        for (final x in d.exercises) {
          expect(exerciseById[x.exerciseId]!.stressOn(JointArea.lowBack), lessThan(2), reason: x.exerciseId);
        }
      }
    });

    test('운동 시간 제한을 지킨다', () {
      final p = gen.generate(const UserProfile(daysPerWeek: 4, sessionMinutes: 45));
      for (final d in p.days) {
        expect(ProgramGenerator.estimateMinutes(d.exercises), lessThanOrEqualTo(45));
      }
    });

    test('근거에 연구/앱 기본값이 구분되어 있다', () {
      final p = gen.generate(const UserProfile());
      expect(p.rationale.any((r) => r.kind == EvidenceKind.research && r.referenceIds.isNotEmpty), isTrue);
      expect(p.rationale.any((r) => r.kind == EvidenceKind.appDefault), isTrue);
      for (final r in p.rationale) {
        for (final id in r.referenceIds) {
          expect(researchById.containsKey(id), isTrue, reason: id);
        }
      }
    });
  });

  group('대체 운동 엔진', () {
    final sub = SubstitutionEngine(exerciseCatalog);
    test('바벨이 없으면 벤치프레스 대체로 머신/덤벨 프레스 추천', () {
      final eq = Equipment.values.toSet()..remove(Equipment.barbell);
      final c = sub.suggest(bench, equipment: eq);
      expect(c, isNotEmpty);
      expect(c.every((x) => !x.exercise.equipment.contains(Equipment.barbell)), isTrue);
      expect(c.take(3).every((x) => x.exercise.primary.contains(Muscle.chest)), isTrue);
    });
    test('기구가 덤벨/맨몸뿐이면 그 안에서만 추천', () {
      final c = sub.suggest(exerciseById['leg_press']!, equipment: {Equipment.dumbbell, Equipment.bodyweight});
      expect(c, isNotEmpty);
      expect(c.every((x) => SubstitutionEngine.isAvailable(x.exercise, {Equipment.dumbbell})), isTrue);
    });
    test('어깨 통증 심하면 어깨 부담 큰 운동 제외', () {
      final c = sub.suggest(
        exerciseById['machine_shoulder_press']!,
        equipment: Equipment.values.toSet(),
        limitations: [const Limitation(area: JointArea.shoulder, severity: 7)],
        limit: 20,
      );
      expect(c.every((x) => x.exercise.stressOn(JointArea.shoulder) < 2), isTrue);
    });
  });

  group('근육별 운동량', () {
    test('직접/간접 세트 분리 계산', () {
      final v = VolumeEngine(exerciseById).compute([('barbell_bench_press', 3), ('cable_fly', 2)]);
      expect(v[Muscle.chest]!.direct, 5);
      expect(v[Muscle.triceps]!.indirect, 1.5);
      expect(v[Muscle.triceps]!.direct, 0);
    });
    test('많다고 좋은 것으로 평가하지 않는다', () {
      final a = assessVolume(Muscle.chest, 25, const VolumeTarget(10, 16));
      expect(a.status, VolumeStatus.above);
    });
  });

  group('회복 엔진', () {
    const re = RecoveryEngine();
    test('좋은 상태 → 양호', () {
      final r = re.analyze(const RecoveryInput(sleepHours: 8, fatigue: 1, soreness: 1, motivation: 5));
      expect(r.readiness, Readiness.good);
      expect(r.setMultiplier, 1);
    });
    test('수면 부족 + 피로 → 운동량 감소 제안', () {
      final r = re.analyze(const RecoveryInput(sleepHours: 4.5, fatigue: 5, soreness: 4, motivation: 2, recentPerformanceDrops: 2));
      expect(r.readiness == Readiness.low || r.readiness == Readiness.rest, isTrue);
      expect(r.setMultiplier, lessThan(1));
    });
  });

  group('일정 재조정 엔진', () {
    const se = ScheduleEngine();
    final days = [
      for (final n in ['상체 A', '하체 A', '상체 B', '하체 B']) PlannedDay(name: n, weekday: 1, exercises: const []),
    ];
    test('운동을 건너뛰어도 다음 순서가 유지된다', () {
      // 월요일 상체A 완료, 화·수 건너뜀 → 목요일에 열면 하체A가 다음
      expect(se.nextDayIndex(dayCount: 4, lastCompletedDayIndex: 0), 1);
      final thu = DateTime(2026, 11, 19); // 목요일
      final plan = se.planRemainingWeek(days: days, completedDates: [DateTime(2026, 11, 16)], lastCompletedDayIndex: 0, now: thu, daysPerWeek: 4);
      expect(plan.first.dayIndex, 1);
      expect(plan.length, 3); // 목·금·토·일 중 3일
      expect(plan.map((p) => p.dayIndex), [1, 2, 3]);
    });
    test('남은 날보다 운동이 많으면 가능한 만큼만 배치', () {
      final sun = DateTime(2026, 11, 22);
      final plan = se.planRemainingWeek(days: days, completedDates: const [], lastCompletedDayIndex: null, now: sun, daysPerWeek: 4);
      expect(plan.length, 1);
    });
    test('주간 진행률', () {
      final w = se.weekProgress([DateTime(2026, 11, 16), DateTime(2026, 11, 17), DateTime(2026, 11, 10)], now, 4);
      expect(w.done, 2);
    });
  });

  group('통계 엔진', () {
    test('추정 1RM (Epley)', () {
      expect(estimate1rm(100, 5).value, closeTo(116.67, 0.01));
      expect(estimate1rm(50, 20).reliable, isFalse);
    });
    test('정체 감지', () {
      final st = StatsEngine(exerciseById);
      final h = [
        perf([7, 7, 6], daysAgo: 1),
        perf([7, 7, 6], daysAgo: 8),
        perf([7, 7, 6], daysAgo: 15),
      ];
      expect(st.detectPlateau(h), isNotNull);
      expect(
        st.detectPlateau([
          perf([8, 8, 8], w: 42.5, daysAgo: 1),
          ...h.skip(1),
        ]),
        isNull,
      );
    });
  });
}
