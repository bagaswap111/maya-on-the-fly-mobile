import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/chat_service.dart';

class NewChatPage extends StatefulWidget {
  const NewChatPage({super.key});

  @override
  State<NewChatPage> createState() => _NewChatPageState();
}

class _NewChatPageState extends State<NewChatPage> {
  final ChatService _chatService = ChatService();

  static const _agents = [
    {'id': 'auto', 'name': 'Auto', 'icon': Icons.auto_awesome, 'desc': 'Let AI choose the best agent'},
    {'id': 'writer', 'name': 'Writer', 'icon': Icons.edit_note, 'desc': 'Draft and refine documents'},
    {'id': 'coder', 'name': 'Coder', 'icon': Icons.code, 'desc': 'Generate and review code'},
  ];

  Future<void> _startChat(String agentId, String agentName) async {
    final id = await _chatService.createSession(agentId: agentId, title: agentName);
    if (mounted) context.push('/chat/$id');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('New Chat')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
        ),
        itemCount: _agents.length,
        itemBuilder: (context, index) {
          final agent = _agents[index];
          return Card(
            child: InkWell(
              onTap: () => _startChat(agent['id']! as String, agent['name']! as String),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(agent['icon'] as IconData, size: 36, color: theme.colorScheme.primary),
                    const SizedBox(height: 8),
                    Text(agent['name']! as String, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(agent['desc']! as String, style: theme.textTheme.bodySmall, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
