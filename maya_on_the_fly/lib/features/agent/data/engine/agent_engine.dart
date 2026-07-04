import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../tools/tool.dart';
import '../tools/tool_registry.dart';
import '../agents/agent.dart';
import '../agents/agent_registry.dart';
import '../../../ai/data/ai_service.dart';
import '../../../ai/data/providers/ai_provider.dart';

const _uuid = Uuid();

class AgentTurn {
  final String turnId;
  final String agentId;
  final String userMessage;
  final String assistantResponse;
  final List<Map<String, dynamic>> toolCalls;
  final DateTime timestamp;

  AgentTurn({
    required this.turnId,
    required this.agentId,
    required this.userMessage,
    required this.assistantResponse,
    required this.toolCalls,
    required this.timestamp,
  });
}

class AgentEngine {
  final AiService _aiService = AiService();
  final ToolRegistry _toolRegistry = ToolRegistry.instance;
  final AgentRegistry _agentRegistry = AgentRegistry.instance;

  static const _defaultProvider = 'deepseek';
  static const _defaultModel = 'deepseek-v4-flash';

  AgentEngine() {
    _toolRegistry.init();
    _agentRegistry.init();
  }

  Agent? _selectAgent(String? agentId, String userMessage) {
    if (agentId != null && agentId != 'auto') {
      return _agentRegistry.get(agentId);
    }
    // Auto-detect based on message content
    final lower = userMessage.toLowerCase();
    if (lower.contains('code') || lower.contains('function') || lower.contains('implement') ||
        lower.contains('bug') || lower.contains('refactor') || lower.contains('debug')) {
      return _agentRegistry.get('coder') ?? _agentRegistry.get('auto');
    }
    if (lower.contains('translate')) return _agentRegistry.get('translator');
    if (lower.contains('summarize') || lower.contains('summary')) return _agentRegistry.get('summarizer');
    if (lower.contains('plan') || lower.contains('roadmap') || lower.contains('milestone')) return _agentRegistry.get('planner');
    if (lower.contains('review') || lower.contains('feedback')) return _agentRegistry.get('reviewer');
    if (lower.contains('research') || lower.contains('search') || lower.contains('find')) return _agentRegistry.get('researcher');
    if (lower.contains('data') || lower.contains('analyze') || lower.contains('stats')) return _agentRegistry.get('analyst');
    if (lower.contains('teach') || lower.contains('explain') || lower.contains('what is')) return _agentRegistry.get('tutor');
    return _agentRegistry.get('writer');
  }

  Future<String> processMessage({
    required String message,
    String? agentId,
    List<Map<String, String>>? history,
    String? sessionId,
    String? documentId,
  }) async {
    final agent = _selectAgent(agentId, message);
    final toolContext = agent != null ? _buildToolContext(agent) : '';
    final systemMessage = agent?.systemPrompt ?? 'You are a helpful AI assistant.';

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': '$systemMessage\n\n$toolContext'},
      ...?history,
      {'role': 'user', 'content': message},
    ];

    return _executeLoop(messages, sessionId: sessionId, documentId: documentId);
  }

  Stream<String> processMessageStream({
    required String message,
    String? agentId,
    List<Map<String, String>>? history,
    String? sessionId,
    String? documentId,
  }) async* {
    final agent = _selectAgent(agentId, message);
    final toolContext = agent != null ? _buildToolContext(agent) : '';
    final systemMessage = agent?.systemPrompt ?? 'You are a helpful AI assistant.';

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': '$systemMessage\n\n$toolContext'},
      ...?history,
      {'role': 'user', 'content': message},
    ];

    yield* _executeLoopStream(messages, sessionId: sessionId, documentId: documentId);
  }

  String _buildToolContext(Agent agent) {
    final tools = agent.toolIds.map((id) => _toolRegistry.get(id)).whereType<Tool>().toList();
    if (tools.isEmpty) return '';

    final buffer = StringBuffer('\n\nYou have access to the following tools:\n');
    for (final tool in tools) {
      buffer.writeln('- ${tool.name} (${tool.id}): ${tool.description}');
      if (tool.parameters.isNotEmpty) {
        for (final param in tool.parameters) {
          final req = param.required ? ' (required)' : '';
          buffer.writeln('  - ${param.name}: ${param.type}$req - ${param.description}');
        }
      }
    }
    buffer.writeln('\nTo use a tool, respond with JSON: {"tool": "tool_id", "args": {...}}');
    buffer.writeln('After receiving tool results, continue the conversation naturally.');
    return buffer.toString();
  }

  Future<String> _executeLoop(
    List<Map<String, String>> messages, {
    String? sessionId,
    String? documentId,
    int maxTurns = 5,
  }) async {
    for (var turn = 0; turn < maxTurns; turn++) {
      final result = await _aiService.complete(
        providerId: _defaultProvider,
        model: _defaultModel,
        messages: messages,
        sessionId: sessionId,
        documentId: documentId,
      );

      final response = result.content;
      final toolCall = _parseToolCall(response);

      if (toolCall == null) {
        return response;
      }

      messages.add({'role': 'assistant', 'content': response});
      final toolResult = await _executeToolCall(toolCall);
      messages.add({'role': 'user', 'content': 'Tool result: $toolResult'});
    }

    return 'Max turns reached. Please refine your request.';
  }

  Stream<String> _executeLoopStream(
    List<Map<String, String>> messages, {
    String? sessionId,
    String? documentId,
    int maxTurns = 5,
  }) async* {
    for (var turn = 0; turn < maxTurns; turn++) {
      final buffer = StringBuffer();
      String? toolCallJson;

      await for (final chunk in _aiService.completeStream(
        providerId: _defaultProvider,
        model: _defaultModel,
        messages: messages,
        sessionId: sessionId,
        documentId: documentId,
      )) {
        buffer.write(chunk);
        yield chunk;
      }

      final fullResponse = buffer.toString();
      final toolCall = _parseToolCall(fullResponse);

      if (toolCall == null) {
        return;
      }

      messages.add({'role': 'assistant', 'content': fullResponse});
      final toolResult = await _executeToolCall(toolCall);
      messages.add({'role': 'user', 'content': 'Tool result: $toolResult'});
      yield '\n\n[Tool: ${toolCall['tool']} completed]\n\n';
    }

    yield '\n\nMax turns reached. Please refine your request.';
  }

  Map<String, dynamic>? _parseToolCall(String response) {
    try {
      final trimmed = response.trim();
      if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
        final parsed = jsonDecode(trimmed) as Map<String, dynamic>;
        if (parsed.containsKey('tool') && parsed.containsKey('args')) {
          return parsed;
        }
      }
      // Try to find JSON block in text
      final start = trimmed.indexOf('{"tool"');
      if (start >= 0) {
        final end = trimmed.indexOf('}', start) + 1;
        if (end > start) {
          final json = trimmed.substring(start, end);
          final parsed = jsonDecode(json) as Map<String, dynamic>;
          if (parsed.containsKey('tool')) {
            return parsed;
          }
        }
      }
    } catch (_) {}
    return null;
  }

  Future<String> _executeToolCall(Map<String, dynamic> call) async {
    final toolId = call['tool'] as String?;
    final args = call['args'] as Map<String, dynamic>? ?? {};

    if (toolId == null) return 'Error: no tool specified';

    final tool = _toolRegistry.get(toolId);
    if (tool == null) return 'Error: tool "$toolId" not found';

    try {
      return await tool.execute(args);
    } catch (e) {
      return 'Error executing tool "$toolId": $e';
    }
  }
}
