abstract class AiProvider {
  String get id;
  String get name;
  String get baseUrl;
  List<String> get models;
  bool get isEnabled;

  Map<String, dynamic> defaultHeaders();

  Future<AiCompletionResult> complete({
    required String model,
    required List<Map<String, String>> messages,
    double temperature = 0.7,
    int maxTokens = 8192,
  });

  Stream<String> completeStream({
    required String model,
    required List<Map<String, String>> messages,
    double temperature = 0.7,
    int maxTokens = 8192,
  });
}

class AiCompletionResult {
  final String content;
  final int inputTokens;
  final int outputTokens;
  final String model;
  final String providerId;

  AiCompletionResult({
    required this.content,
    required this.inputTokens,
    required this.outputTokens,
    required this.model,
    required this.providerId,
  });
}
