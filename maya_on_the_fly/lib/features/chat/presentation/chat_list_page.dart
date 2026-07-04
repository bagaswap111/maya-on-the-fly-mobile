import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/chat_service.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final ChatService _chatService = ChatService();
  List<Map<String, dynamic>> _sessions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final sessions = await _chatService.getSessions();
    if (mounted) setState(() { _sessions = sessions; _loading = false; });
  }

  Future<void> _newSession() async {
    final id = await _chatService.createSession();
    if (mounted) context.push('/chat/$id');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.add), onPressed: _newSession),
        ],
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _sessions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 48, color: theme.colorScheme.onSurface.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('No conversations yet', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5))),
                  const SizedBox(height: 16),
                  FilledButton.tonal(onPressed: _newSession, child: const Text('Start a chat')),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadSessions,
              child: ListView.builder(
                itemCount: _sessions.length,
                itemBuilder: (context, index) {
                  final session = _sessions[index];
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.chat)),
                    title: Text(session['title'] as String? ?? 'Chat'),
                    subtitle: Text(session['agent_id'] as String? ?? ''),
                    trailing: Text(session['token_count'].toString()),
                    onTap: () => context.push('/chat/${session['id']}'),
                  );
                },
              ),
            ),
    );
  }
}
