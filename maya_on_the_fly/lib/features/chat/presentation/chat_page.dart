import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../utils/error_handler.dart';
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
  final TextEditingController _editController = TextEditingController();
  StreamSubscription<String>? _streamSub;

  List<Map<String, dynamic>> _messages = [];
  String? _sessionId;
  String? _agentId;
  bool _loading = true;
  bool _sending = false;
  String? _editingMessageId;
  bool _editSaving = false;

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
      _streamSub = _engine.processMessageStream(
        message: text,
        agentId: _agentId,
        history: history.sublist(0, history.length - 1),
        sessionId: _sessionId,
      ).listen((chunk) {
        fullResponse += chunk;
        _updateAssistantMessage(fullResponse);
      }, onError: (e) {
        _updateAssistantMessage('Sorry, something went wrong. Please try again.');
      }, onDone: () async {
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
      });
    } catch (e) {
      _updateAssistantMessage('Sorry, something went wrong. Please try again.');
      if (mounted) setState(() => _sending = false);
    }
  }

  void _cancelStream() {
    _streamSub?.cancel();
    _streamSub = null;
    if (mounted) setState(() => _sending = false);
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

  void _showMessageActions(Map<String, dynamic> msg) {
    final isUser = msg['role'] == 'user';
    final isTemp = msg['is_temp'] == true;
    final content = msg['content'] as String? ?? '';
    final messageId = msg['id'] as String?;

    if (messageId == null || isTemp) return;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy'),
              onTap: () {
                Clipboard.setData(ClipboardData(text: content));
                Navigator.pop(ctx);
                ErrorHandler.showSuccess(context, 'Copied to clipboard');
              },
            ),
            if (isUser)
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(ctx);
                  _startEditing(messageId, content);
                },
              ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.red),
              title: Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(messageId);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _startEditing(String messageId, String content) {
    _editController.text = content;
    setState(() => _editingMessageId = messageId);
  }

  Future<void> _saveEdit() async {
    final newContent = _editController.text.trim();
    if (newContent.isEmpty || _editingMessageId == null) return;

    setState(() => _editSaving = true);
    await _chatService.updateMessage(_editingMessageId!, content: newContent);
    final messages = await _chatService.getMessages(_sessionId!);
    if (mounted) {
      setState(() {
        _messages = messages;
        _editingMessageId = null;
        _editSaving = false;
      });
      ErrorHandler.showSuccess(context, 'Message updated');
    }
  }

  void _cancelEdit() {
    setState(() {
      _editingMessageId = null;
      _editController.clear();
    });
  }

  Future<void> _confirmDelete(String messageId) async {
    final confirmed = await ErrorHandler.showConfirmDialog(
      context,
      title: 'Delete message?',
      message: 'This cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed) return;

    await _chatService.deleteMessage(messageId);
    final messages = await _chatService.getMessages(_sessionId!);
    if (mounted) {
      setState(() => _messages = messages);
      ErrorHandler.showSuccess(context, 'Message deleted');
    }
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    _inputController.dispose();
    _scrollController.dispose();
    _editController.dispose();
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
                final isTemp = msg['is_temp'] == true;
                final messageId = msg['id'] as String?;
                final content = msg['content'] as String? ?? '';

                if (_editingMessageId == messageId) {
                  return _buildEditBubble(theme, content);
                }

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: GestureDetector(
                    onLongPress: messageId != null && !isTemp ? () => _showMessageActions(msg) : null,
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
                  ),
                );
              },
            ),
          ),
          if (_sending)
            const LinearProgressIndicator(),
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
                if (_sending)
                  IconButton(
                    icon: const Icon(Icons.stop),
                    onPressed: _cancelStream,
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditBubble(ThemeData theme, String content) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12).copyWith(
            bottomRight: const Radius.circular(0),
          ),
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _editController,
              autofocus: true,
              maxLines: 4,
              minLines: 1,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: const EdgeInsets.all(8),
                isDense: true,
              ),
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: _editSaving ? null : _cancelEdit,
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 4),
                TextButton(
                  onPressed: _editSaving ? null : _saveEdit,
                  child: _editSaving
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
