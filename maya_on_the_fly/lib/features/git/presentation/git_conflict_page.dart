import 'package:flutter/material.dart';
import '../data/git_service.dart';

class GitConflictPage extends StatelessWidget {
  const GitConflictPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Resolve Conflicts')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.merge_type, size: 48, color: Colors.orange.shade400),
              const SizedBox(height: 16),
              Text('No conflicts detected', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('Conflicts will appear here during merge operations.', style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
