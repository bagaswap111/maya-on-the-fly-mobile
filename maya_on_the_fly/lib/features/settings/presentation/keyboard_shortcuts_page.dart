import 'package:flutter/material.dart';
import '../../../design/tokens.dart';

class KeyboardShortcutsPage extends StatelessWidget {
  const KeyboardShortcutsPage({super.key});

  static const _shortcuts = [
    {'keys': 'Cmd/Ctrl + S', 'action': 'Save document'},
    {'keys': 'Cmd/Ctrl + B', 'action': 'Toggle bold'},
    {'keys': 'Cmd/Ctrl + I', 'action': 'Toggle italic'},
    {'keys': 'Cmd/Ctrl + K', 'action': 'Insert link'},
    {'keys': 'Cmd/Ctrl + Shift + P', 'action': 'Toggle preview'},
    {'keys': 'Esc', 'action': 'Close dialog or cancel'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Keyboard Shortcuts')),
      body: ListView(
        padding: const EdgeInsets.all(DesignTokens.spaceMd),
        children: [
          Text(
            'Available when using an external keyboard.',
            style: theme.textTheme.bodyMedium?.copyWith(color: DesignTokens.muted),
          ),
          const SizedBox(height: DesignTokens.spaceMd),
          Card(
            child: Column(
              children: _shortcuts.map((s) => ListTile(
                title: Text(s['action']!),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    s['keys']!,
                    style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                  ),
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
