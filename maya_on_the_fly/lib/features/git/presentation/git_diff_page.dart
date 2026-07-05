import 'package:flutter/material.dart';
import '../data/git_service.dart';

class GitDiffPage extends StatefulWidget {
  const GitDiffPage({super.key});

  @override
  State<GitDiffPage> createState() => _GitDiffPageState();
}

class _GitDiffPageState extends State<GitDiffPage> {
  final GitService _git = GitService();
  String _diff = '';
  bool _staged = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final d = _staged ? _git.getStagedDiff() : _git.getDiff();
    setState(() => _diff = d ?? '(no changes)');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diff'),
        actions: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Working'), icon: Icon(Icons.edit_note)),
              ButtonSegment(value: true, label: Text('Staged'), icon: Icon(Icons.sticky_note_2)),
            ],
            selected: {_staged},
            onSelectionChanged: (v) { setState(() => _staged = v.first); _load(); },
          ),
        ],
      ),
      body: _diff == '(no changes)'
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 48, color: Colors.green.shade300),
                const SizedBox(height: 12),
                const Text('No changes'),
              ],
            ),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: SelectableText(
              _diff,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
    );
  }
}
