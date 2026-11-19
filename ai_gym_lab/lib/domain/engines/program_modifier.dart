// 프로그램 변경 제안(AI/오프라인 트레이너) → 사용자가 승인하면 적용되는 순수 로직
import '../models.dart';
import 'program_generator.dart';

sealed class ProgramChange {
  const ProgramChange();
  String get title;
  Map<String, dynamic> toJson();

  static ProgramChange? fromJson(Map<String, dynamic> j, Map<String, Exercise> exercises) {
    switch (j['type']) {
      case 'set_session_minutes':
        final m = (j['minutes'] as num?)?.toInt();
        if (m == null || m < 15 || m > 180) return null;
        return SetSessionMinutes(m);
      case 'replace_exercise':
        final from = j['from'] as String?, to = j['to'] as String?;
        if (from == null || to == null || !exercises.containsKey(from) || !exercises.containsKey(to) || from == to) return null;
        return ReplaceExercise(from, to);
      case 'set_days_per_week':
        final d = (j['days'] as num?)?.toInt();
        if (d == null || d < 2 || d > 6) return null;
        return SetDaysPerWeek(d);
      case 'adjust_sets':
        final id = j['exercise'] as String?;
        final delta = (j['delta'] as num?)?.toInt();
        if (id == null || !exercises.containsKey(id) || delta == null || delta == 0 || delta.abs() > 3) return null;
        return AdjustSets(id, delta);
    }
    return null;
  }
}

class SetSessionMinutes extends ProgramChange {
  final int minutes;
  const SetSessionMinutes(this.minutes);
  @override
  String get title => '1회 운동 시간을 $minutes분으로 조정';
  @override
  Map<String, dynamic> toJson() => {'type': 'set_session_minutes', 'minutes': minutes};
}

class ReplaceExercise extends ProgramChange {
  final String from, to;
  const ReplaceExercise(this.from, this.to);
  @override
  String get title => '운동 교체';
  @override
  Map<String, dynamic> toJson() => {'type': 'replace_exercise', 'from': from, 'to': to};
}

class SetDaysPerWeek extends ProgramChange {
  final int days;
  const SetDaysPerWeek(this.days);
  @override
  String get title => '주 $days일 프로그램으로 재생성';
  @override
  Map<String, dynamic> toJson() => {'type': 'set_days_per_week', 'days': days};
}

class AdjustSets extends ProgramChange {
  final String exerciseId;
  final int delta;
  const AdjustSets(this.exerciseId, this.delta);
  @override
  String get title => '세트 수 ${delta > 0 ? '+' : ''}$delta';
  @override
  Map<String, dynamic> toJson() => {'type': 'adjust_sets', 'exercise': exerciseId, 'delta': delta};
}

class ProgramModifier {
  final ProgramGenerator generator;
  const ProgramModifier(this.generator);

  String describe(ProgramChange c) => switch (c) {
    SetSessionMinutes(:final minutes) => '각 운동일을 약 $minutes분 안에 끝나도록 뒤쪽 운동의 세트/운동 수를 줄입니다.',
    ReplaceExercise(:final from, :final to) => '${generator.byId[from]!.nameKo} → ${generator.byId[to]!.nameKo}. 새 운동은 기존 중량을 쓰지 않고 기준 중량부터 찾습니다.',
    SetDaysPerWeek(:final days) => '프로필의 주당 운동일을 $days일로 바꾸고 새 AI 추천 프로그램을 생성합니다(기존 프로그램은 보존).',
    AdjustSets(:final exerciseId, :final delta) => '${generator.byId[exerciseId]!.nameKo}의 세트를 ${delta > 0 ? '+' : ''}$delta 조정합니다(1~6세트 범위).',
  };

  /// 프로필 변경이 필요한 변경은 (새 프로필, 새 계획), 그 외는 (null, 새 계획)
  (UserProfile?, ProgramPlan) apply(ProgramChange c, ProgramPlan plan, UserProfile profile) {
    switch (c) {
      case SetSessionMinutes(:final minutes):
        final days = [for (final d in plan.days) d.copyWith(exercises: ProgramGenerator.fitToTime(d.exercises, minutes))];
        return (profile.copyWith(sessionMinutes: minutes), ProgramPlan(name: plan.name, split: plan.split, days: days, rationale: plan.rationale));
      case ReplaceExercise(:final from, :final to):
        final ex = generator.byId[to]!;
        final days = [
          for (final d in plan.days)
            d.copyWith(
              exercises: [
                for (final x in d.exercises)
                  x.exerciseId == from
                      ? PlannedExercise(
                          exerciseId: to,
                          sets: x.sets,
                          repMin: ex.timed ? ex.repMin : x.repMin,
                          repMax: ex.timed ? ex.repMax : x.repMax,
                          targetRir: x.targetRir,
                          restSec: ex.restSec,
                          notes: x.notes,
                        )
                      : x,
              ],
            ),
        ];
        return (null, ProgramPlan(name: plan.name, split: plan.split, days: days, rationale: plan.rationale));
      case SetDaysPerWeek(:final days):
        final p = profile.copyWith(daysPerWeek: days);
        return (p, generator.generate(p));
      case AdjustSets(:final exerciseId, :final delta):
        final days = [
          for (final d in plan.days)
            d.copyWith(exercises: [for (final x in d.exercises) x.exerciseId == exerciseId ? x.copyWith(sets: (x.sets + delta).clamp(1, 6)) : x]),
        ];
        return (null, ProgramPlan(name: plan.name, split: plan.split, days: days, rationale: plan.rationale));
    }
  }
}
