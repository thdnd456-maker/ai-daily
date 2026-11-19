// AI 트레이너 서비스
//
// 1) 사용자 기록/프로그램/엔진 추천값으로 컨텍스트 구성
// 2) 설정된 제공자(Anthropic/OpenAI/프록시)로 답변, 미설정·실패·한도 초과 시 오프라인 규칙 기반 트레이너로 답변
// 3) 답변에 포함된 프로그램 변경 제안(```gymlab-action```)을 검증해 '대기' 상태로 저장
// 4) 사용자가 승인해야만 프로그램에 적용
import 'dart:convert';

import '../data/repository.dart';
import '../domain/catalog/research.dart';
import '../domain/engines/program_generator.dart';
import '../domain/engines/program_modifier.dart';
import '../domain/engines/progression_engine.dart';
import '../domain/engines/schedule_engine.dart';
import '../domain/engines/stats_engine.dart';
import '../domain/engines/substitution_engine.dart';
import '../domain/engines/volume_engine.dart';
import '../domain/models.dart';
import 'ai_providers.dart';

class TrainerResponse {
  final String text;
  final ProgramChange? change;
  final int? recommendationId;
  final String source;
  const TrainerResponse(this.text, this.change, this.recommendationId, this.source);
}

class TrainerContext {
  final UserProfile? profile;
  final ProgramView? program;
  final int? nextDayIndex;
  final List<SessionView> recent;
  final Map<Muscle, MuscleVolume> weekVolume;
  final VolumeTarget? target;
  final Map<String, ProgressionRecommendation> nextRecs;
  const TrainerContext(this.profile, this.program, this.nextDayIndex, this.recent, this.weekVolume, this.target, this.nextRecs);
}

class TrainerService {
  final GymRepository repo;
  final AiProvider? Function(Map<String, String?> settings)? providerFactory;
  TrainerService(this.repo, {this.providerFactory});

  static const settingKeys = ['ai.provider', 'ai.apiKey', 'ai.model', 'ai.baseUrl', 'ai.proxyUrl', 'ai.proxyToken', 'ai.dailyLimit'];

  Future<Map<String, String?>> settings() async => {for (final k in settingKeys) k: await repo.getSetting(k)};

  AiProvider? _provider(Map<String, String?> s) {
    if (providerFactory != null) return providerFactory!(s);
    switch (s['ai.provider']) {
      case 'anthropic':
        return AnthropicProvider(apiKey: s['ai.apiKey'] ?? '', model: s['ai.model'], baseUrl: s['ai.baseUrl']);
      case 'openai':
        return OpenAiProvider(apiKey: s['ai.apiKey'] ?? '', model: s['ai.model'] ?? '', baseUrl: s['ai.baseUrl']);
      case 'proxy':
        return BackendProxyProvider(url: s['ai.proxyUrl'] ?? '', appToken: s['ai.proxyToken'], model: s['ai.model']);
    }
    return null; // offline
  }

  Future<TrainerContext> buildContext({DateTime? now}) async {
    final t = now ?? DateTime.now();
    final profile = await repo.getProfile();
    final program = await repo.getActiveProgram();
    final recent = await repo.completedSessions(limit: 12);
    final weekStart = ScheduleEngine.weekStart(t);
    final vol = VolumeEngine(repo.exercises).compute([
      for (final s in recent.where((s) => !s.row.startedAt.isBefore(weekStart)))
        for (final e in s.exercises) (e.exercise.id, e.completedSets),
    ]);
    int? next;
    final recs = <String, ProgressionRecommendation>{};
    if (program != null && program.days.isNotEmpty) {
      next = await repo.nextDayIndex(program);
      for (final d in program.days) {
        for (final x in d.exercises) {
          if (recs.containsKey(x.exerciseId)) continue;
          recs[x.exerciseId] = await repo.recommendFor(
            repo.exercises[x.exerciseId]!,
            sets: x.sets,
            repMin: x.repMin,
            repMax: x.repMax,
            targetRir: x.targetRir,
            startWeight: x.startWeight,
            incrementOverride: x.incrementKg,
            now: t,
          );
        }
      }
    }
    return TrainerContext(profile, program, next, recent, vol, profile == null ? null : weeklyVolumeTarget(profile), recs);
  }

  String _contextText(TrainerContext c) {
    final b = StringBuffer();
    final p = c.profile;
    if (p != null) {
      b.writeln(
        '[사용자] ${p.sex.ko}, ${p.age}세, ${p.heightCm}cm, ${p.weightKg}kg, 경험 ${p.experience.ko}, 주 ${p.daysPerWeek}일 × ${p.sessionMinutes}분, '
        '목표(우선순위) ${p.goals.map((g) => g.ko).join(' > ')}, 환경 ${p.environment.ko}',
      );
      if (p.limitations.isNotEmpty) {
        b.writeln('[통증 메모] ${p.limitations.map((l) => '${l.area.ko} 강도${l.severity}/10 ${l.timing}').join('; ')} (의료 진단 아님)');
      }
    }
    if (c.program != null) {
      b.writeln('[현재 프로그램] ${c.program!.row.name}');
      for (final d in c.program!.days) {
        final mark = d.row.dayIndex == c.nextDayIndex ? ' ← 다음 운동' : '';
        b.writeln(
          '- ${d.row.name}$mark: ${d.exercises.map((x) {
            final e = repo.exercises[x.exerciseId]!;
            final r = c.nextRecs[x.exerciseId];
            return '${e.nameKo}[id=${e.id}] ${x.sets}×${x.repMin}-${x.repMax}${r != null ? ' (엔진 추천: ${r.summary(timed: e.timed, assisted: e.assisted)}, ${r.action.ko})' : ''}';
          }).join(', ')}',
        );
      }
    }
    if (c.recent.isNotEmpty) {
      b.writeln('[최근 운동 기록]');
      for (final s in c.recent.take(6)) {
        b.writeln(
          '- ${_d(s.row.startedAt)} ${s.row.dayName}: ${s.exercises.where((e) => e.completedSets > 0).map((e) {
            final sets = e.sets.where((x) => x.completed).map((x) => '${fmtKg(x.actualWeight ?? 0)}×${x.actualReps}${x.rir != null ? '@RIR${x.rir}' : ''}').join(' ');
            return '${e.exercise.nameKo} $sets${e.row.pain ? ' [통증]' : ''}';
          }).join(' / ')}',
        );
      }
    } else {
      b.writeln('[최근 운동 기록] 없음');
    }
    if (c.target != null) {
      b.writeln(
        '[이번 주 근육별 직접 세트 / 시작 목표 ${c.target!.min}-${c.target!.max}] '
        '${trackedMuscles.map((m) => '${m.ko} ${c.weekVolume[m]!.direct.toStringAsFixed(0)}').join(', ')}',
      );
    }
    return b.toString();
  }

  String systemPrompt(TrainerContext c) =>
      '''
당신은 운동과학 기반 헬스 앱 'AI GYM LAB'의 AI 트레이너입니다. 한국어로 간결하고 실용적으로 답하세요.

원칙:
1. 아래 [사용자 데이터]의 실제 운동 기록과 현재 프로그램을 우선 참고합니다.
2. 근거가 부족하면 불확실하다고 분명히 말합니다.
3. 의학적 진단을 하지 않습니다. 통증이 지속·악화되면 운동을 중단하고 의료 전문가와 상담하도록 안내합니다.
4. 중량 추천은 앱의 규칙 기반 엔진 추천값을 따르고, 그보다 무리하게 올리도록 권하지 않습니다. 기록이 없으면 중량을 단정하지 말고 기준 중량 찾는 방법을 안내합니다.
5. 사용자의 목표와 운동 경험을 고려합니다.
6. 연구를 언급할 때는 아래 [연구 목록] 범위에서만 인용하고, 논문에 없는 수치를 만들지 않습니다. 앱 기본값과 연구 결과를 구분해서 말합니다.
7. 프로그램 변경을 제안할 때는 이유를 설명하고, 답변 마지막에 아래 형식의 블록을 정확히 하나만 추가합니다. 변경은 사용자가 승인해야 적용된다고 알려주세요.
```gymlab-action
{"type":"set_session_minutes","minutes":40}
```
   지원 type: set_session_minutes{minutes}, replace_exercise{from,to}(운동 id 사용), set_days_per_week{days 2~6}, adjust_sets{exercise,delta -3~3}
   운동 id는 [현재 프로그램]의 id 또는 일반적인 운동 id(예: machine_chest_press, leg_press, goblet_squat)를 사용합니다.

[연구 목록]
${researchReferences.map((r) => '- ${r.id}: ${r.authors} ${r.year}, ${r.keyFindings}').join('\n')}

[사용자 데이터]
${_contextText(c)}''';

  Future<TrainerResponse> ask(String question, {DateTime? now}) async {
    await repo.addChat('user', question);
    final ctx = await buildContext(now: now);
    final s = await settings();
    final provider = _provider(s);
    String text;
    String source = 'offline';
    ProgramChange? change;
    String? note;
    if (provider != null) {
      final limit = int.tryParse(s['ai.dailyLimit'] ?? '') ?? 30;
      final used = await repo.aiRequestsToday();
      if (used >= limit) {
        note = '오늘 AI 사용 한도($limit회)에 도달해 오프라인 트레이너가 답변합니다.';
      } else {
        try {
          final history = await repo.chatHistory(limit: 12);
          final msgs = [for (final m in history) AiMessage(m.role, m.content)];
          final r = await provider.reply(system: systemPrompt(ctx), messages: msgs);
          await repo.logAiUsage(provider.id, r.model, r.inputTokens, r.outputTokens);
          final parsed = parseAction(r.text);
          text = parsed.$1;
          change = parsed.$2;
          source = provider.label;
          return await _finish(text, change, source);
        } catch (e) {
          note = 'AI 연결에 실패해 오프라인 트레이너가 답변합니다. ($e)';
        }
      }
    }
    final off = await OfflineTrainer(repo).answer(question, ctx, now: now ?? DateTime.now());
    text = note == null ? off.$1 : '$note\n\n${off.$1}';
    change = off.$2;
    return _finish(text, change, source);
  }

  Future<TrainerResponse> _finish(String text, ProgramChange? change, String source) async {
    int? recId;
    if (change != null) {
      recId = await repo.addAiRecommendation(
        kind: 'program_change',
        title: change.title,
        body: ProgramModifier(ProgramGenerator(repo.exerciseList)).describe(change),
        payload: change.toJson(),
      );
    }
    await repo.addChat('assistant', text, provider: source, recommendationId: recId);
    return TrainerResponse(text, change, recId, source);
  }

  /// ```gymlab-action {...}``` 블록을 분리·검증합니다. 잘못된 제안은 무시합니다.
  (String, ProgramChange?) parseAction(String text) {
    final re = RegExp(r'```gymlab-action\s*([\s\S]*?)```');
    final m = re.firstMatch(text);
    if (m == null) return (text.trim(), null);
    final clean = text.replaceAll(re, '').trim();
    try {
      final j = jsonDecode(m.group(1)!.trim()) as Map<String, dynamic>;
      return (clean, ProgramChange.fromJson(j, repo.exercises));
    } catch (_) {
      return (clean, null);
    }
  }

  /// 승인된 변경 적용. 반환: 결과 메시지
  Future<String> applyRecommendation(int recId) async {
    final r = await repo.aiRecommendation(recId);
    if (r == null || r.status != 'pending') return '이미 처리된 제안입니다.';
    final change = ProgramChange.fromJson(jsonDecode(r.payload) as Map<String, dynamic>, repo.exercises);
    final program = await repo.getActiveProgram();
    final profile = await repo.getProfile();
    if (change == null || profile == null) return '제안을 적용할 수 없습니다.';
    final modifier = ProgramModifier(ProgramGenerator(repo.exerciseList));
    if (change is SetDaysPerWeek || program == null) {
      final (p, plan) = modifier.apply(change, program?.toPlan() ?? ProgramGenerator(repo.exerciseList).generate(profile), profile);
      if (p != null) await repo.saveProfile(p);
      await repo.saveProgram(plan, source: 'ai', activate: true, basedOn: program?.row.id);
    } else {
      final (p, plan) = modifier.apply(change, program.toPlan(), profile);
      if (p != null) await repo.saveProfile(p);
      await repo.updateProgram(program.row.id, plan);
    }
    await repo.setAiRecommendationStatus(recId, 'accepted');
    return '적용했습니다: ${change.title}';
  }

  Future<void> rejectRecommendation(int recId) => repo.setAiRecommendationStatus(recId, 'rejected');
}

String _d(DateTime d) => '${d.month}/${d.day}';

/// 인터넷/AI 없이 동작하는 규칙 기반 트레이너
class OfflineTrainer {
  final GymRepository repo;
  OfflineTrainer(this.repo);

  static String norm(String s) => s.replaceAll(RegExp(r'\s+'), '').toLowerCase();

  static const _jointWords = {'무릎': JointArea.knee, '허리': JointArea.lowBack, '어깨': JointArea.shoulder, '손목': JointArea.wrist, '팔꿈치': JointArea.elbow};

  static const _muscleWords = <String, List<Muscle>>{
    '가슴': [Muscle.chest],
    '광배': [Muscle.lats],
    '등': [Muscle.lats, Muscle.upperBack],
    '어깨': [Muscle.sideDelt, Muscle.frontDelt, Muscle.rearDelt],
    '이두': [Muscle.biceps],
    '삼두': [Muscle.triceps],
    '팔': [Muscle.biceps, Muscle.triceps],
    '허벅지': [Muscle.quads, Muscle.hamstrings],
    '대퇴': [Muscle.quads],
    '햄스트링': [Muscle.hamstrings],
    '하체': [Muscle.quads, Muscle.hamstrings, Muscle.glutes],
    '다리': [Muscle.quads, Muscle.hamstrings],
    '엉덩이': [Muscle.glutes],
    '둔근': [Muscle.glutes],
    '종아리': [Muscle.calves],
    '복근': [Muscle.abs],
  };

  /// 질문에서 운동 찾기 (현재 프로그램 운동 우선)
  Exercise? findExercise(String q, ProgramView? program) {
    final nq = norm(q);
    final inProgram = {
      for (final d in program?.days ?? <DayView>[])
        for (final x in d.exercises) x.exerciseId,
    };
    Exercise? best;
    var bestScore = 0;
    for (final e in repo.exerciseList) {
      final full = norm(e.nameKo);
      final aliases = {full, norm(e.nameKo.replaceFirst(RegExp(r'^(바벨|덤벨|머신|케이블|스미스머신|스미스|시티드|스탠딩)\s*'), ''))};
      var score = 0;
      for (final a in aliases) {
        if (a.length >= 2 && nq.contains(a)) score = a.length * 10 > score ? a.length * 10 : score;
      }
      if (score == 0) continue;
      if (full.isNotEmpty && nq.contains(full)) score += 5;
      if (inProgram.contains(e.id)) score += 100;
      if (score > bestScore) {
        bestScore = score;
        best = e;
      }
    }
    return best;
  }

  Future<(String, ProgramChange?)> answer(String q, TrainerContext c, {required DateTime now}) async {
    final nq = norm(q);
    final hasPain = RegExp(r'(아파|아픈|아프|통증|시려|찌릿)').hasMatch(nq);
    if (hasPain) return _pain(q, c);

    final mins = RegExp(r'(\d{2,3})\s*분').firstMatch(q);
    if (mins != null && RegExp(r'(줄여|맞춰|바꿔|늘려|변경|으로|로)').hasMatch(nq)) {
      final m = int.parse(mins.group(1)!);
      final change = SetSessionMinutes(m);
      final day = c.program?.days.isNotEmpty == true ? c.program!.days[c.nextDayIndex ?? 0] : null;
      final after = day == null
          ? null
          : ProgramGenerator.estimateMinutes(
              ProgramGenerator.fitToTime([
                for (final x in day.exercises) PlannedExercise(exerciseId: x.exerciseId, sets: x.sets, repMin: x.repMin, repMax: x.repMax, restSec: x.restSec),
              ], m),
            );
      return (
        '1회 운동 시간을 $m분으로 조정하는 변경을 제안합니다.\n'
            '• 각 날의 첫 복합운동은 유지하고, 뒤쪽 운동부터 세트를 줄인 뒤(최소 2세트) 필요하면 마지막 운동을 뺍니다.\n'
            '${after != null ? '• 예: ${day!.row.name} 예상 시간 약 $after분\n' : ''}'
            '• 시간을 줄이면 일부 근육의 주간 세트가 줄어들 수 있습니다. 시간이 생기는 날에 보충할 수 있어요.\n\n아래 [적용]을 눌러야 프로그램이 바뀝니다.',
        change,
      );
    }
    final days = RegExp(r'주\s*(\d)\s*(일|회)').firstMatch(q);
    if (days != null && RegExp(r'(바꿔|변경|으로|로|줄여|늘려)').hasMatch(nq)) {
      final d = int.parse(days.group(1)!);
      if (d >= 2 && d <= 6) {
        return ('주 $d일 프로그램으로 다시 생성하는 것을 제안합니다. 기존 프로그램과 기록은 보존되며, 새 프로그램이 활성화됩니다.\n\n아래 [적용]을 눌러야 바뀝니다.', SetDaysPerWeek(d));
      }
    }
    if (RegExp(r'(몇kg|몇키로|몇킬로|중량|무게|얼마나들|몇개|몇회)').hasMatch(nq)) return (_weight(q, c), null);
    if (RegExp(r'(또해도|연속|어제|오늘도|매일)').hasMatch(nq)) return (_consecutive(c, now), null);
    if (RegExp(r'(안크|안커|안늘|정체|안올라|성장|발전이없)').hasMatch(nq)) return (await _plateau(q, c, now), null);
    if (RegExp(r'(대신|대체|없어|못써|사용중)').hasMatch(nq)) return _substitute(q, c, null);
    return (_help(c), null);
  }

  String _weight(String q, TrainerContext c) {
    final e = findExercise(q, c.program);
    if (e == null) {
      return '어떤 운동인지 찾지 못했어요. 예: "오늘 벤치프레스 몇 kg으로 해야 해?"처럼 운동 이름을 넣어 주세요.';
    }
    final r = c.nextRecs[e.id];
    if (r == null) {
      return '${e.nameKo}는 현재 프로그램에 없어 처방 기준(세트·반복)이 없습니다. 프로그램에 추가하면 기록 기반으로 중량을 추천해 드려요.';
    }
    return '${e.nameKo} 추천: ${r.summary(timed: e.timed, assisted: e.assisted)} (${r.action.ko}, 신뢰도 ${r.confidence.ko})\n\n'
        '근거:\n${r.reasons.map((x) => '• $x').join('\n')}\n\n'
        '첫 세트가 예상보다 무겁거나 가벼우면 그 자리에서 조정해도 됩니다. 기록한 결과가 다음 추천에 반영됩니다.';
  }

  String _consecutive(TrainerContext c, DateTime now) {
    if (c.recent.isEmpty) return '최근 운동 기록이 없어 연속 운동에 대한 판단 근거가 없습니다. 오늘 계획된 운동을 진행해도 좋습니다.';
    final last = c.recent.first;
    final hours = now.difference(last.row.finishedAt ?? last.row.startedAt).inMinutes / 60;
    final lastM = {for (final e in last.exercises.where((e) => e.completedSets > 0)) ...e.exercise.primary};
    final next = c.program != null && c.nextDayIndex != null ? c.program!.days[c.nextDayIndex!] : null;
    final nextM = {for (final x in next?.exercises ?? <dynamic>[]) ...repo.exercises[x.exerciseId]!.primary};
    final warn = const ScheduleEngine().consecutiveWarning(lastSessionMuscles: lastM, nextMuscles: nextM, hoursSinceLast: hours);
    final b = StringBuffer('마지막 운동: ${last.row.dayName} (${hours.round()}시간 전)\n');
    if (next != null) b.writeln('다음 순서: ${next.row.name}');
    if (warn != null) {
      b.writeln('\n$warn');
      b.writeln('같은 근육을 연속으로 운동하는 것이 금지된 것은 아니지만, 근육통이 크거나 수행이 떨어진다면 회복 후 진행하는 편이 기록 향상에 유리할 수 있습니다. (앱 기본 판단)');
    } else {
      b.writeln('\n다음 운동과 겹치는 주요 근육이 적거나 충분한 시간이 지나 계획대로 진행해도 됩니다.');
    }
    b.writeln('\n운동 전 "오늘의 상태" 체크를 하면 회복 점수(앱 자체 추정값)에 따라 운동량을 자동 조정합니다.');
    return b.toString().trim();
  }

  (String, ProgramChange?) _pain(String q, TrainerContext c) {
    final nq = norm(q);
    JointArea? area;
    for (final kv in _jointWords.entries) {
      if (nq.contains(kv.key)) area = kv.value;
    }
    final profile = c.profile ?? const UserProfile();
    final lims = [...profile.limitations, if (area != null) Limitation(area: area, severity: 6)];
    final head = '앱은 통증을 진단하지 않습니다. 날카로운 통증, 붓기, 저림이 있거나 통증이 지속되면 운동을 멈추고 의료 전문가와 상담하세요.\n\n';
    final ex = findExercise(q, c.program);
    if (ex == null) {
      final b = StringBuffer(head);
      if (area != null) {
        final heavy = <String>[];
        for (final d in c.program?.days ?? <DayView>[]) {
          for (final x in d.exercises) {
            final e = repo.exercises[x.exerciseId]!;
            if (e.stressOn(area) >= 2) heavy.add(e.nameKo);
          }
        }
        b.writeln('${area.ko} 부담이 큰 편인 현재 프로그램 운동: ${heavy.isEmpty ? '없음' : heavy.toSet().join(', ')}');
        b.writeln('운동 중 해당 운동의 [대체] 버튼을 누르면 ${area.ko} 부담이 낮은 대체 운동을 추천합니다. 프로필의 신체 상태에 통증을 추가하면 프로그램 생성 시 자동 반영됩니다.');
      } else {
        b.writeln('어느 부위가 아픈지(무릎·허리·어깨·손목·팔꿈치)와 운동 이름을 알려주시면 대체 운동을 추천해 드릴게요.');
      }
      return (b.toString().trim(), null);
    }
    final sub = SubstitutionEngine(repo.exerciseList);
    final cands = sub.suggest(
      ex,
      equipment: profile.equipment.isEmpty ? profile.environment.defaultEquipment : profile.equipment,
      limitations: lims,
      experience: profile.experience,
      limit: 4,
    );
    if (cands.isEmpty) return ('$head${ex.nameKo}의 적절한 대체 운동을 찾지 못했습니다. 통증 없는 범위로 가동범위·중량을 줄이는 것을 고려하세요.', null);
    final b = StringBuffer(head);
    b.writeln('${area != null ? '${area.ko} 통증이 있을 때 ' : ''}${ex.nameKo} 대신 고려할 운동:');
    for (var i = 0; i < cands.length; i++) {
      final cnd = cands[i];
      final st = area == null ? '' : ' · ${area.ko} 부담 ${['낮음', '보통', '높음'][cnd.exercise.stressOn(area)]}';
      b.writeln('${i + 1}. ${cnd.exercise.nameKo} — ${cnd.reasons.take(2).join(', ')}$st');
    }
    b.writeln('\n대체 운동은 기존 중량을 그대로 쓰지 않고 가벼운 중량으로 기준을 다시 찾습니다. 통증 없는 범위에서 수행하세요.');
    final inProgram = c.program?.days.any((d) => d.exercises.any((x) => x.exerciseId == ex.id)) ?? false;
    if (inProgram) {
      b.writeln('\n프로그램의 ${ex.nameKo}를 ${cands.first.exercise.nameKo}(으)로 바꾸려면 [적용]을 누르세요.');
      return (b.toString().trim(), ReplaceExercise(ex.id, cands.first.exercise.id));
    }
    return (b.toString().trim(), null);
  }

  (String, ProgramChange?) _substitute(String q, TrainerContext c, JointArea? area) {
    final ex = findExercise(q, c.program);
    if (ex == null) return ('어떤 운동을 대체하고 싶은지 운동 이름을 알려주세요.', null);
    final profile = c.profile ?? const UserProfile();
    final eq = {...(profile.equipment.isEmpty ? profile.environment.defaultEquipment : profile.equipment)}
      ..removeAll(ex.equipment.where((e) => e != Equipment.bodyweight && e != Equipment.bench));
    final cands = SubstitutionEngine(repo.exerciseList).suggest(ex, equipment: eq, limitations: profile.limitations, experience: profile.experience, limit: 4);
    if (cands.isEmpty) return ('${ex.nameKo}의 대체 운동을 찾지 못했습니다.', null);
    final b = StringBuffer('${ex.nameKo}를 쓸 수 없을 때 추천:\n');
    for (var i = 0; i < cands.length; i++) {
      b.writeln('${i + 1}. ${cands[i].exercise.nameKo} — ${cands[i].reasons.take(2).join(', ')}');
    }
    b.writeln('\n오늘만 바꾸려면 운동 화면의 [대체] 버튼을 사용하세요. 대체 운동은 기존 중량을 그대로 적용하지 않습니다.');
    return (b.toString().trim(), null);
  }

  Future<String> _plateau(String q, TrainerContext c, DateTime now) async {
    final nq = norm(q);
    List<Muscle>? muscles;
    for (final kv in _muscleWords.entries) {
      if (nq.contains(kv.key)) {
        muscles = kv.value;
        break;
      }
    }
    final ex = findExercise(q, c.program);
    muscles ??= ex?.primary;
    if (muscles == null) return '어느 근육(예: 가슴, 등, 하체) 또는 어떤 운동이 정체되었는지 알려주세요.';
    final t = c.target ?? const VolumeTarget(10, 16);
    final b = StringBuffer('원인을 단정할 수는 없지만, 기록으로 확인할 수 있는 항목은 다음과 같습니다.\n\n');
    // 최근 4주 평균 주간 직접 세트
    final from = now.subtract(const Duration(days: 28));
    final s4 = c.recent.where((s) => s.row.startedAt.isAfter(from)).toList();
    final vol4 = VolumeEngine(repo.exercises).compute([
      for (final s in s4)
        for (final e in s.exercises) (e.exercise.id, e.completedSets),
    ]);
    for (final m in muscles) {
      final weekly = vol4[m]!.direct / 4;
      final st = assessVolume(m, weekly, t);
      b.writeln(
        '• 최근 기록 기준 ${m.ko} 주평균 직접 ${weekly.toStringAsFixed(1)}세트 — ${switch (st.status) {
          VolumeStatus.below || VolumeStatus.none => '시작 목표(${t.min}~${t.max})보다 적음 → 운동량 부족 가능성',
          VolumeStatus.above => '시작 목표 상한 초과 → 피로 누적 가능성',
          VolumeStatus.within => '목표 범위 안',
        }}',
      );
    }
    // 해당 근육 운동 정체
    final stats = StatsEngine(repo.exercises);
    final checked = <String>{};
    for (final s in c.recent) {
      for (final e in s.exercises) {
        if (!e.exercise.primary.any(muscles.contains) || !checked.add(e.exercise.id)) continue;
        final h = await repo.performanceHistory(e.exercise.id);
        final p = stats.detectPlateau(h);
        if (p != null) b.writeln('• ${e.exercise.nameKo}: 같은 중량(${fmtKg(p.weight)}kg)에서 ${p.sessions}회 연속 추정 1RM 변화 없음');
      }
    }
    final logs = await repo.recoveryLogs(since: from);
    if (logs.isNotEmpty) {
      final sleep = logs.map((l) => l.sleepHours).reduce((a, b) => a + b) / logs.length;
      final fat = logs.map((l) => l.fatigue).reduce((a, b) => a + b) / logs.length;
      b.writeln(
        '• 최근 평균 수면 ${sleep.toStringAsFixed(1)}시간, 피로도 ${fat.toStringAsFixed(1)}/5${sleep < 6.5 ? ' → 수면 부족 가능성' : ''}${fat >= 3.5 ? ' → 피로 누적 가능성' : ''}',
      );
    }
    final planned = (c.profile?.daysPerWeek ?? 4) * 4;
    b.writeln('• 최근 4주 출석 ${s4.length}/$planned회${s4.length < planned * 0.75 ? ' → 운동 수행의 일관성 확인 필요' : ''}');
    b.writeln('\n기록으로 알 수 없는 요인: 식사(총 섭취량·단백질), 운동 자세와 가동범위, 수면의 질.');
    b.writeln('참고: 단백질 보충 연구에서는 하루 약 1.6 g/kg 이후 추가 이득이 뚜렷하지 않았습니다(Morton 2018). 식단 처방이 아닌 참고 정보입니다.');
    b.writeln('\n조정 방안 예시: 해당 근육 주간 세트 +2~4, 다른 각도의 운동으로 1개 교체, 피로가 높다면 1주간 운동량 축소.');
    return b.toString().trim();
  }

  String _help(TrainerContext c) {
    final next = c.program != null && c.nextDayIndex != null ? c.program!.days[c.nextDayIndex!].row.name : null;
    return '${next != null ? '다음 운동은 $next입니다.\n\n' : ''}'
        '오프라인 트레이너가 답할 수 있는 질문 예시:\n'
        '• "오늘 벤치프레스 몇 kg으로 해야 해?"\n'
        '• "어제 하체 운동했는데 오늘 또 해도 돼?"\n'
        '• "무릎이 아픈데 스쿼트 대신 무엇을 하면 좋아?"\n'
        '• "가슴 근육이 잘 안 크는 이유가 뭘까?"\n'
        '• "운동 시간을 40분으로 줄여줘."\n\n'
        '설정에서 AI 제공자를 연결하면 더 자유로운 대화가 가능합니다. 중량 추천은 어느 경우든 기록 기반 규칙 엔진을 따릅니다.';
  }
}
