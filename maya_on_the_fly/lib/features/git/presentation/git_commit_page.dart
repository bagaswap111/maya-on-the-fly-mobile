import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  bool _messageTouched = false;

  bool get _canCommit => _messageController.text.trim().isNotEmpty;

  Future<void> _commit() async {
    final msg = _messageController.text.trim();
    if (!_canCommit) {
      setState(() => _messageTouched = true);
      return;
    }
    final confirmed = await ErrorHandler.showConfirmDialog(
      context,
      title: 'Confirm Commit',
      message: 'Stage all changes and commit?',
      confirmLabel: 'Commit',
      isDestructive: false,
    );
    if (!confirmed) return;

    setState(() => _staging = true);

    try {
      _git.stageAll();
      final sha = _git.commit(msg);
      if (mounted) {
        ErrorHandler.showSuccess(context, 'Committed: ${sha.substring(0, 7)}');
        context.pop();
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
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Git concepts',
            onPressed: () => ErrorHandler.showInfo(context,
              'A commit saves a snapshot of all staged changes.\n'
              'Write a clear summary of what changed and why.',
            ),
          ),
          TextButton(
            onPressed: _staging ? null : _commit,
            child: _staging
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : Text('Commit', style: TextStyle(color: _canCommit ? null : Theme.of(context).disabledColor)),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_staging)
            const LinearProgressIndicator(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
          TextField(
            controller: _messageController,
            onChanged: (_) {
              if (_messageTouched) setState(() {});
            },
            decoration: InputDecoration(
              labelText: 'Commit message',
              hintText: 'Summary of changes (required)',
              border: const OutlineInputBorder(),
              errorText: _messageTouched && !_canCommit ? 'Commit message is required' : null,
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
          ),
        ],
      ),
    );
  }
}
