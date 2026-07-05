import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../agent/data/agents/agent_registry.dart';
import '../data/chat_service.dart';

const _agentIconMapping = {
  'auto': Icons.auto_awesome,
  'writer': Icons.edit_note,
  'coder': Icons.code,
  'editor': Icons.rate_review,
  'researcher': Icons.travel_explore,
  'analyst': Icons.analytics,
  'tutor': Icons.school,
  'translator': Icons.translate,
  'summarizer': Icons.summarize,
  'reviewer': Icons.feedback,
  'planner': Icons.account_tree,
  'debugger': Icons.bug_report,
  'devops': Icons.cloud,
};

class NewChatPage extends StatefulWidget {
  const NewChatPage({super.key});

  @override
  State<NewChatPage> createState() => _NewChatPageState();
}

class _NewChatPageState extends State<NewChatPage> {
  final ChatService _chatService = ChatService();
  final AgentRegistry _registry = AgentRegistry.instance;

  bool _loading = true;
  bool _creating = false;
  List<Map<String, dynamic>> _agents = [];

  @override
  void initState() {
    super.initState();
    _registry.init();
    _agents = _registry.getAll().map((a) {
      final id = a.id;
      String description = a.description;
      if (id == 'auto') {
        description = 'Automatically routes your request to the best specialist agent';
      }
      return {
        'id': id,
        'name': a.name,
        'desc': description,
        'icon': _agentIconMapping[id] ?? Icons.smart_toy,
      };
    }).toList();
    _loading = false;
  }

  Future<void> _startChat(String agentId, String agentName) async {
    setState(() => _creating = true);
    try {
      final id = await _chatService.createSession(agentId: agentId, title: agentName);
      if (mounted) context.push('/chat/$id');
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text('New Chat')),
      body: Stack(
        children: [
          _agents.isEmpty
        ? Center(child: Text('No agents available', style: theme.textTheme.bodyMedium))
        : GridView.builder(
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
                    Text(agent['desc']! as String, style: theme.textTheme.bodySmall, textAlign: TextAlign.center, maxLines: 3, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
          );
        },
      ),
          if (_creating)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
