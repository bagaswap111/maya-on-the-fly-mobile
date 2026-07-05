import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens.dart';
import '../../documents/data/document_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DocumentService _docService = DocumentService();
  List<Map<String, dynamic>> _documents = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    final docs = await _docService.getDocuments();
    if (mounted) setState(() { _documents = docs; _loading = false; });
  }

  Future<void> _createDocument() async {
    final id = await _docService.createDocument();
    if (mounted) context.push('/doc/$id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Maya on the Fly')),
      body: RefreshIndicator(
        onRefresh: _loadDocuments,
        child: ListView(
          padding: const EdgeInsets.all(DesignTokens.spaceMd),
          children: [
            _QuickActions(onNewDoc: _createDocument),
            const SizedBox(height: DesignTokens.spaceLg),
            const SectionHeader(title: 'Recent Documents', action: 'See All'),
            const SizedBox(height: DesignTokens.spaceSm),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_documents.isEmpty)
              _EmptyState(
                icon: Icons.description_outlined,
                message: 'No documents yet',
                action: 'Create your first document',
                onAction: _createDocument,
              )
            else
              ..._documents.map((doc) => _DocumentTile(doc: doc)),
            const SizedBox(height: DesignTokens.spaceLg),
            const SectionHeader(title: 'Recent Chats'),
            const SizedBox(height: DesignTokens.spaceSm),
            _EmptyState(
              icon: Icons.chat_bubble_outline,
              message: 'No chats yet',
              action: 'Start a conversation',
              onAction: () {},
              compact: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onNewDoc;
  const _QuickActions({required this.onNewDoc});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionCard(icon: Icons.note_add_outlined, label: 'New Doc', onTap: onNewDoc),
        const SizedBox(width: DesignTokens.spaceSm),
        const _ActionCard(icon: Icons.add_comment_outlined, label: 'New Chat'),
        const SizedBox(width: DesignTokens.spaceSm),
        const _ActionCard(icon: Icons.source_outlined, label: 'Open Repo'),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _ActionCard({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(DesignTokens.spaceMd),
            child: Column(
              children: [
                Icon(icon, size: 24),
                const SizedBox(height: DesignTokens.spaceXxs),
                Text(label, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final Map<String, dynamic> doc;
  const _DocumentTile({required this.doc});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: DesignTokens.spaceXs),
      child: ListTile(
        title: Text(doc['title'] as String? ?? 'Untitled'),
        subtitle: Text(doc['content_preview'] as String? ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Text('${doc['word_count'] ?? 0}w', style: Theme.of(context).textTheme.bodySmall),
        onTap: () => context.push('/doc/${doc['id']}'),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  const SectionHeader({super.key, required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        if (action != null)
          TextButton(onPressed: () {}, child: Text(action!)),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String action;
  final VoidCallback onAction;
  final bool compact;
  const _EmptyState({required this.icon, required this.message, required this.action, required this.onAction, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? DesignTokens.spaceMd : DesignTokens.spaceXl),
        child: Column(
          children: [
            Icon(icon, size: 48, color: DesignTokens.muted.withValues(alpha: 0.5)),
            const SizedBox(height: DesignTokens.spaceSm),
            Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: DesignTokens.muted)),
            const SizedBox(height: DesignTokens.spaceSm),
            TextButton(onPressed: onAction, child: Text(action)),
          ],
        ),
      ),
    );
  }
}
