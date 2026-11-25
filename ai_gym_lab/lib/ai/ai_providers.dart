// AI 제공자 추상화 계층
//
// - 핵심 운동 처방(중량/세트/반복)은 규칙 기반 엔진이 담당하고, AI는 설명·질의응답·변경 제안에만 사용합니다.
// - API 키는 소스코드에 넣지 않습니다. 개발/개인 사용 시 설정 화면에서 입력하면 기기 로컬 DB에만 저장되며,
//   배포 버전에서는 [BackendProxyProvider]로 자체 백엔드 프록시를 통해 요청하는 것을 권장합니다.
import 'dart:convert';

import 'package:http/http.dart' as http;

class AiMessage {
  final String role; // user | assistant
  final String content;
  const AiMessage(this.role, this.content);
}

class AiReply {
  final String text;
  final String model;
  final int inputTokens;
  final int outputTokens;
  const AiReply(this.text, this.model, {this.inputTokens = 0, this.outputTokens = 0});
}

class AiException implements Exception {
  final String message;
  const AiException(this.message);
  @override
  String toString() => message;
}

abstract class AiProvider {
  String get id;
  String get label;
  Future<AiReply> reply({required String system, required List<AiMessage> messages});
}

/// Anthropic Messages API (raw HTTP — Dart용 공식 SDK가 없음)
class AnthropicProvider implements AiProvider {
  // 비용 절약: Opus 5.5 대비 약 1/40 가격. 설정에서 다른 모델로 바꿀 수 있음
  static const defaultModel = 'claude-haiku-5-5';
  // 서버 측 거절 시 대체 모델 라우팅을 지원하는 모델
  static const _fallbackModels = {'claude-opus-5-5', 'claude-fable-5-2', 'claude-fable-5-1', 'claude-opus-5', 'claude-sonnet-5-5'};

  final String apiKey;
  final String model;
  final String baseUrl;
  final http.Client client;

  AnthropicProvider({required this.apiKey, String? model, String? baseUrl, http.Client? client})
    : model = (model == null || model.isEmpty) ? defaultModel : model,
      baseUrl = (baseUrl == null || baseUrl.isEmpty) ? 'https://api.anthropic.com' : baseUrl,
      client = client ?? http.Client();

  @override
  String get id => 'anthropic';
  @override
  String get label => 'Anthropic ($model)';

  @override
  Future<AiReply> reply({required String system, required List<AiMessage> messages}) async {
    if (apiKey.isEmpty) throw const AiException('Anthropic API 키가 설정되지 않았습니다.');
    final useFallback = _fallbackModels.contains(model);
    final body = <String, dynamic>{
      'model': model,
      'max_tokens': 16000,
      'system': system,
      'messages': [
        for (final m in messages) {'role': m.role, 'content': m.content},
      ],
      if (useFallback) 'fallbacks': 'default',
    };
    final res = await client
        .post(
          Uri.parse('$baseUrl/v1/messages'),
          headers: {
            'content-type': 'application/json',
            'x-api-key': apiKey,
            'anthropic-version': '2023-06-01',
            if (useFallback) 'anthropic-beta': 'server-side-fallback-2026-07-01',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 120));
    final j = _decode(res);
    if (res.statusCode != 200) {
      final msg = (j['error'] as Map?)?['message'] ?? res.body;
      throw AiException('Anthropic 오류 ${res.statusCode}: $msg');
    }
    if (j['stop_reason'] == 'refusal') {
      throw const AiException('AI가 이 요청에 답변하지 않았습니다. 질문을 바꿔 다시 시도하세요.');
    }
    final text = [
      for (final b in (j['content'] as List? ?? const []))
        if (b is Map && b['type'] == 'text') b['text'] as String,
    ].join('\n').trim();
    final usage = (j['usage'] as Map?) ?? const {};
    return AiReply(
      text,
      (j['model'] as String?) ?? model,
      inputTokens: (usage['input_tokens'] as num?)?.toInt() ?? 0,
      outputTokens: (usage['output_tokens'] as num?)?.toInt() ?? 0,
    );
  }
}

/// OpenAI Chat Completions 호환 API
class OpenAiProvider implements AiProvider {
  final String apiKey;
  final String model;
  final String baseUrl;
  final http.Client client;

  OpenAiProvider({required this.apiKey, required this.model, String? baseUrl, http.Client? client})
    : baseUrl = (baseUrl == null || baseUrl.isEmpty) ? 'https://api.openai.com' : baseUrl,
      client = client ?? http.Client();

  @override
  String get id => 'openai';
  @override
  String get label => 'OpenAI ($model)';

  @override
  Future<AiReply> reply({required String system, required List<AiMessage> messages}) async {
    if (apiKey.isEmpty) throw const AiException('OpenAI API 키가 설정되지 않았습니다.');
    if (model.isEmpty) throw const AiException('OpenAI 모델명을 설정에서 입력하세요.');
    final res = await client
        .post(
          Uri.parse('$baseUrl/v1/chat/completions'),
          headers: {'content-type': 'application/json', 'authorization': 'Bearer $apiKey'},
          body: jsonEncode({
            'model': model,
            'messages': [
              {'role': 'system', 'content': system},
              for (final m in messages) {'role': m.role, 'content': m.content},
            ],
          }),
        )
        .timeout(const Duration(seconds: 120));
    final j = _decode(res);
    if (res.statusCode != 200) {
      throw AiException('OpenAI 오류 ${res.statusCode}: ${(j['error'] as Map?)?['message'] ?? res.body}');
    }
    final text = ((j['choices'] as List).first as Map)['message']['content'] as String? ?? '';
    final usage = (j['usage'] as Map?) ?? const {};
    return AiReply(
      text.trim(),
      (j['model'] as String?) ?? model,
      inputTokens: (usage['prompt_tokens'] as num?)?.toInt() ?? 0,
      outputTokens: (usage['completion_tokens'] as num?)?.toInt() ?? 0,
    );
  }
}

/// 배포용 백엔드 프록시. API 키는 서버에만 있고 앱은 아래 계약으로 요청합니다.
///   POST {url}  {"system": "...", "messages": [{"role","content"}], "model": "..."}
///   → 200 {"text": "...", "model": "...", "usage": {"input_tokens": n, "output_tokens": n}}
/// 서버는 사용자 인증과 사용량 제한(요금 관리)을 담당해야 합니다.
class BackendProxyProvider implements AiProvider {
  final String url;
  final String? appToken;
  final String? model;
  final http.Client client;

  BackendProxyProvider({required this.url, this.appToken, this.model, http.Client? client}) : client = client ?? http.Client();

  @override
  String get id => 'proxy';
  @override
  String get label => '백엔드 프록시';

  @override
  Future<AiReply> reply({required String system, required List<AiMessage> messages}) async {
    if (url.isEmpty) throw const AiException('프록시 URL이 설정되지 않았습니다.');
    final res = await client
        .post(
          Uri.parse(url),
          headers: {'content-type': 'application/json', if (appToken != null && appToken!.isNotEmpty) 'authorization': 'Bearer $appToken'},
          body: jsonEncode({
            'system': system,
            'messages': [
              for (final m in messages) {'role': m.role, 'content': m.content},
            ],
            if (model != null && model!.isNotEmpty) 'model': model,
          }),
        )
        .timeout(const Duration(seconds: 120));
    final j = _decode(res);
    if (res.statusCode != 200) throw AiException('프록시 오류 ${res.statusCode}');
    final usage = (j['usage'] as Map?) ?? const {};
    return AiReply(
      (j['text'] as String? ?? '').trim(),
      (j['model'] as String?) ?? 'proxy',
      inputTokens: (usage['input_tokens'] as num?)?.toInt() ?? 0,
      outputTokens: (usage['output_tokens'] as num?)?.toInt() ?? 0,
    );
  }
}

Map<String, dynamic> _decode(http.Response res) {
  try {
    final d = jsonDecode(utf8.decode(res.bodyBytes));
    return d is Map<String, dynamic> ? d : {'_': d};
  } catch (_) {
    return {};
  }
}
