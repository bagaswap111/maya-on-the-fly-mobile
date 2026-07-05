import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:git2dart/git2dart.dart' show GitStatus;
import '../../../utils/error_handler.dart';
import '../data/git_service.dart';

class GitStatusPage extends StatefulWidget {
  const GitStatusPage({super.key});

  @override
  State<GitStatusPage> createState() => _GitStatusPageState();
}

class _GitStatusPageState extends State<GitStatusPage> {
  final GitService _git = GitService();
  Map<String, Set<GitStatus>> _statusEntries = {};
  String _currentBranch = '';
  String _repoPath = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final appDir = await getApplicationDocumentsDirectory();
    final repoPath = p.join(appDir.path, 'git_repo');
    await _git.openOrInit(repoPath);
    _refresh();
  }

  void _refresh() {
    setState(() {
      try {
        _statusEntries = _git.status;
        _currentBranch = _git.repo.head.shorthand;
        _repoPath = _git.repo.workdir;
      } catch (e) {
        debugPrint('GitStatusPage._refresh error: $e');
        if (mounted) ErrorHandler.showError(context, 'Error reading git status');
      }
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentBranch.isNotEmpty ? _currentBranch : 'Git'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
          IconButton(icon: const Icon(Icons.dns_outlined), onPressed: () => context.push('/git/manage')),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Git concepts',
            onPressed: () => ErrorHandler.showInfo(context,
              '• Stage: mark files to include in the next commit\n'
              '• Commit: save staged changes as a snapshot\n'
              '• Branch: independent line of development\n'
              '• Unpushed: commits not yet sent to remote',
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(child: Text(p.basename(_repoPath), style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis)),
                Text('${_git.getUnpushedCount()} unpushed', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          const Divider(height: 1),
          if (_statusEntries.entries.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 48, color: Colors.green.shade300),
                    const SizedBox(height: 12),
                    Text('Working tree clean', style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView(
                children: _statusEntries.entries.map((e) {
                  final flags = e.value;
                  final path = e.key;
                  final isNew = flags.contains(GitStatus.wtNew) || flags.contains(GitStatus.indexNew);
                  final isDeleted = flags.contains(GitStatus.wtDeleted) || flags.contains(GitStatus.indexDeleted);
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      isNew ? Icons.add_circle_outline :
                      isDeleted ? Icons.remove_circle_outline :
                      Icons.edit,
                      color: isNew ? Colors.green : isDeleted ? Colors.red : Colors.orange,
                      size: 20,
                    ),
                    title: Text(path, style: theme.textTheme.bodySmall),
                    trailing: IconButton(
                      icon: const Icon(Icons.add, size: 18),
                      tooltip: 'Stage',
                      onPressed: () { _git.stageFile(path); _refresh(); },
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
      floatingActionButton: _statusEntries.isNotEmpty
        ? FloatingActionButton.extended(
            onPressed: () => context.push('/git/:repo/commit'),
            icon: const Icon(Icons.commit),
            label: Text('Commit (${_statusEntries.length})'),
          )
        : null,
    );
  }
}
