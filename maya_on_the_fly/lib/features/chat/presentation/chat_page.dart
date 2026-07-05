import 'package:flutter/material.dart';
import '../../agent/data/engine/agent_engine.dart';
import '../data/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String? sessionId;
  final String? agentId;
  const ChatPage({super.key, this.sessionId, this.agentId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final AgentEngine _engine = AgentEngine();
  final ChatService _chatService = ChatService();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _messages = [];
  String? _sessionId;
  String? _agentId;
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _agentId = widget.agentId;
    _initSession();
  }

  Future<void> _initSession() async {
    String? sid = widget.sessionId;
    if (sid == null) {
      sid = await _chatService.createSession(
        title: '${_agentId ?? 'New'} Chat',
        agentId: _agentId,
      );
    } else {
      final session = await _chatService.getSession(sid);
      if (session != null && _agentId == null) {
        _agentId = session['agent_id'] as String?;
      }
    }
    final messages = await _chatService.getMessages(sid);
    if (mounted) {
      setState(() {
        _sessionId = sid;
        _messages = messages;
        _loading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _sessionId == null || _sending) return;

    _inputController.clear();
    setState(() => _sending = true);

    await _chatService.addMessage(
      sessionId: _sessionId!,
      role: 'user',
      content: text,
    );

    final updatedMessages = await _chatService.getMessages(_sessionId!);
    setState(() { _messages = updatedMessages; });

    final history = updatedMessages
      .where((m) => m['role'] != 'system')
      .map((m) => {'role': m['role'] as String, 'content': m['content'] as String})
      .toList();

    String fullResponse = '';
    try {
      await for (final chunk in _engine.processMessageStream(
        message: text,
        agentId: _agentId,
        history: history.sublist(0, history.length - 1),
        sessionId: _sessionId,
      )) {
        fullResponse += chunk;
        _updateAssistantMessage(fullResponse);
      }
    } catch (e) {
      _updateAssistantMessage('Error: ${e.toString()}');
    }

    if (fullResponse.isNotEmpty) {
      await _chatService.addMessage(
        sessionId: _sessionId!,
        role: 'assistant',
        content: fullResponse,
      );
    }

    final finalMessages = await _chatService.getMessages(_sessionId!);
    if (mounted) {
      setState(() {
        _messages = finalMessages;
        _sending = false;
      });
    }
    _scrollToBottom();
  }

  void _updateAssistantMessage(String content) {
    setState(() {
      final existingIndex = _messages.indexWhere((m) => m['role'] == 'assistant' && m['is_temp'] == true);
      if (existingIndex >= 0) {
        _messages[existingIndex]['content'] = content;
      } else {
        _messages.add({'role': 'assistant', 'content': content, 'is_temp': true});
      }
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                final content = msg['content'] as String? ?? '';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isUser ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12).copyWith(
                        bottomRight: isUser ? const Radius.circular(0) : null,
                        bottomLeft: isUser ? null : const Radius.circular(0),
                      ),
                    ),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                    child: Text(
                      content,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                );
              },
            ),
          ),
          if (_sending)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: LinearProgressIndicator(),
            ),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(top: BorderSide(color: theme.dividerColor)),
            ),
            padding: EdgeInsets.only(
              left: 12, right: 12, bottom: MediaQuery.of(context).padding.bottom + 8, top: 8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sending ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
