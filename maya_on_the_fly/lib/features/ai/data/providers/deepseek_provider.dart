import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ai_provider.dart';
import '../../../../utils/secure_storage.dart';

class DeepSeekProvider extends AiProvider {
  @override
  final String id = 'deepseek';
  @override
  final String name = 'DeepSeek';
  @override
  final String baseUrl = 'https://api.deepseek.com';
  @override
  final List<String> models = ['deepseek-v4-flash', 'deepseek-chat', 'deepseek-reasoner'];
  @override
  final bool isEnabled = true;

  String? _apiKey;

  Future<String?> get apiKey async {
    _apiKey ??= await AppSecureStorage.read('deepseek_api_key');
    return _apiKey;
  }

  @override
  Map<String, dynamic> defaultHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  @override
  Future<AiCompletionResult> complete({
    required String model,
    required List<Map<String, String>> messages,
    double temperature = 0.7,
    int maxTokens = 8192,
  }) async {
    final key = await apiKey;
    if (key == null) throw Exception('DeepSeek API key not configured');

    final response = await http.post(
      Uri.parse('$baseUrl/chat/completions'),
      headers: {
        ...defaultHeaders(),
        'Authorization': 'Bearer $key',
      },
      body: jsonEncode({
        'model': model,
        'messages': messages,
        'temperature': temperature,
        'max_tokens': maxTokens,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('DeepSeek API error ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final choice = (data['choices'] as List).first as Map<String, dynamic>;
    final usage = data['usage'] as Map<String, dynamic>?;

    return AiCompletionResult(
      content: (choice['message'] as Map<String, dynamic>)['content'] as String? ?? '',
      inputTokens: usage?['prompt_tokens'] as int? ?? 0,
      outputTokens: usage?['completion_tokens'] as int? ?? 0,
      model: model,
      providerId: id,
    );
  }

  @override
  Stream<String> completeStream({
    required String model,
    required List<Map<String, String>> messages,
    double temperature = 0.7,
    int maxTokens = 8192,
  }) async* {
    final key = await apiKey;
    if (key == null) throw Exception('DeepSeek API key not configured');

    final request = http.Request('POST', Uri.parse('$baseUrl/chat/completions'));
    request.headers.addAll({
      ...defaultHeaders(),
      'Authorization': 'Bearer $key',
    });
    request.body = jsonEncode({
      'model': model,
      'messages': messages,
      'temperature': temperature,
      'max_tokens': maxTokens,
      'stream': true,
    });

    final response = await http.Client().send(request);

    if (response.statusCode != 200) {
      throw Exception('DeepSeek API error ${response.statusCode}');
    }

    await for (final chunk in response.stream.transform(utf8.decoder)) {
      final lines = chunk.split('\n');
      for (final line in lines) {
        if (line.startsWith('data: ')) {
          final dataStr = line.substring(6).trim();
          if (dataStr == '[DONE]') return;
          if (dataStr.isEmpty) continue;

          try {
            final data = jsonDecode(dataStr) as Map<String, dynamic>;
            final choice = (data['choices'] as List).first as Map<String, dynamic>;
            final delta = choice['delta'] as Map<String, dynamic>?;
            final content = delta?['content'] as String?;
            if (content != null && content.isNotEmpty) {
              yield content;
            }
          } catch (_) {}
        }
      }
    }
  }
}
