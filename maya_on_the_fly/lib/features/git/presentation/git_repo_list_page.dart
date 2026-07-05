import 'package:flutter/material.dart';
import '../data/git_service.dart';

class GitRepoListPage extends StatefulWidget {
  const GitRepoListPage({super.key});

  @override
  State<GitRepoListPage> createState() => _GitRepoListPageState();
}

class _GitRepoListPageState extends State<GitRepoListPage> {
  final GitService _git = GitService();
  List<Map<String, String>> _remotes = [];
  final _urlController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    try { _remotes = _git.getRemotes(); } catch (_) { _remotes = []; }
    if (mounted) setState(() {});
  }

  void _addRemote() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Remote'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name', hintText: 'origin')),
            TextField(controller: _urlController, decoration: const InputDecoration(labelText: 'URL', hintText: 'https://github.com/user/repo.git')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(onPressed: () {
            _git.addRemote(_nameController.text, _urlController.text);
            _nameController.clear();
            _urlController.clear();
            Navigator.pop(ctx);
            _load();
          }, child: const Text('Add')),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remotes'),
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: _addRemote)],
      ),
      body: _remotes.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_off, size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                const SizedBox(height: 12),
                Text('No remotes configured', style: theme.textTheme.bodyMedium),
                const SizedBox(height: 8),
                FilledButton.tonal(onPressed: _addRemote, child: const Text('Add Remote')),
              ],
            ),
          )
        : ListView(
            children: _remotes.map((r) => ListTile(
              leading: const Icon(Icons.cloud),
              title: Text(r['name'] ?? ''),
              subtitle: Text(r['url'] ?? ''),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  _git.removeRemote(r['name']!);
                  _load();
                },
              ),
            )).toList(),
          ),
    );
  }
}
