import 'package:uuid/uuid.dart';
import 'providers/ai_provider.dart';
import 'providers/deepseek_provider.dart';
import '../../chat/data/chat_service.dart';

const _uuid = Uuid();

class AiService {
  final List<AiProvider> _providers = [DeepSeekProvider()];
  final ChatService _chatService = ChatService();

  AiProvider? getProvider(String id) {
    return _providers.cast<AiProvider?>().firstWhere((p) => p?.id == id, orElse: () => null);
  }

  Future<AiCompletionResult> complete({
    required String providerId,
    required String model,
    required List<Map<String, String>> messages,
    String? sessionId,
    String? documentId,
    double temperature = 0.7,
    int maxTokens = 8192,
  }) async {
    final provider = getProvider(providerId);
    if (provider == null) throw Exception('Provider not found: $providerId');

    final result = await provider.complete(
      model: model,
      messages: messages,
      temperature: temperature,
      maxTokens: maxTokens,
    );

    await _recordUsage(result, documentId: documentId, sessionId: sessionId);
    return result;
  }

  Stream<String> completeStream({
    required String providerId,
    required String model,
    required List<Map<String, String>> messages,
    String? sessionId,
    String? documentId,
    double temperature = 0.7,
    int maxTokens = 8192,
  }) async* {
    final provider = getProvider(providerId);
    if (provider == null) throw Exception('Provider not found: $providerId');

    final buffer = StringBuffer();
    await for (final chunk in provider.completeStream(
      model: model,
      messages: messages,
      temperature: temperature,
      maxTokens: maxTokens,
    )) {
      buffer.write(chunk);
      yield chunk;
    }

    // Record usage with estimated tokens
    final fullContent = buffer.toString();
    final estimatedInputTokens = messages.fold<int>(0, (sum, m) => sum + (m['content']?.length ?? 0) ~/ 4);
    final estimatedOutputTokens = fullContent.length ~/ 4;
    await _recordUsage(
      AiCompletionResult(
        content: fullContent,
        inputTokens: estimatedInputTokens,
        outputTokens: estimatedOutputTokens,
        model: model,
        providerId: providerId,
      ),
      documentId: documentId,
      sessionId: sessionId,
    );
  }

  Future<void> _recordUsage(AiCompletionResult result, {String? documentId, String? sessionId}) async {
    try {
      await _chatService.recordUsage({
        'id': _uuid.v4(),
        'provider_id': result.providerId,
        'model_id': result.model,
        'task_type': 'chat',
        'input_tokens': result.inputTokens,
        'output_tokens': result.outputTokens,
        'cost': _estimateCost(result.providerId, result.model, result.inputTokens, result.outputTokens),
        'document_id': documentId,
        'session_id': sessionId,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (_) {}
  }

  double _estimateCost(String providerId, String model, int inputTokens, int outputTokens) {
    if (providerId == 'deepseek' && model == 'deepseek-v4-flash') {
      return (inputTokens / 1000000 * 0.14) + (outputTokens / 1000000 * 0.28);
    }
    return 0;
  }
}
