import 'package:flutter/material.dart';
import '../../../utils/error_handler.dart';
import '../data/git_service.dart';

class GitCommitPage extends StatefulWidget {
  const GitCommitPage({super.key});

  @override
  State<GitCommitPage> createState() => _GitCommitPageState();
}

class _GitCommitPageState extends State<GitCommitPage> {
  final GitService _git = GitService();
  final _messageController = TextEditingController();
  final _descController = TextEditingController();
  bool _staging = false;

  void _commit() {
    final msg = _messageController.text.trim();
    if (msg.isEmpty) return;
    setState(() => _staging = true);

    try {
      _git.stageAll();
      final sha = _git.commit(msg);
      if (mounted) {
        ErrorHandler.showSuccess(context, 'Committed: ${sha.substring(0, 7)}');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, 'Commit failed: $e');
        setState(() => _staging = false);
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Commit'),
        actions: [
          TextButton(
            onPressed: _staging ? null : _commit,
            child: _staging
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Commit'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _messageController,
            decoration: const InputDecoration(
              labelText: 'Commit message',
              hintText: 'Summary of changes (required)',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.newline,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              hintText: 'Detailed explanation of changes...',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
          ),
          const SizedBox(height: 16),
          Text(
            'All changes will be staged before committing.',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }
}
