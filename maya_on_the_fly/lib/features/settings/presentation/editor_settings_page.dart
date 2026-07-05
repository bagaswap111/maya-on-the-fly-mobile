import 'package:flutter/material.dart';
import '../../../design/tokens.dart';

class EditorSettingsPage extends StatelessWidget {
  const EditorSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Editor Settings')),
      body: ListView(
        padding: const EdgeInsets.all(DesignTokens.spaceMd),
        children: [
          const SizedBox(height: DesignTokens.spaceXl),
          Center(
            child: Column(
              children: [
                Icon(Icons.text_fields, size: 48, color: theme.colorScheme.primary),
                const SizedBox(height: DesignTokens.spaceMd),
                Text('Editor Settings', style: theme.textTheme.titleLarge),
                const SizedBox(height: DesignTokens.spaceSm),
                Text(
                  'Font size, line height, tab width, and other editor '
                  'preferences will appear here in a future update.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: DesignTokens.muted),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.spaceLg),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Spell Check'),
                  subtitle: Text('Enabled', style: theme.textTheme.bodySmall?.copyWith(color: DesignTokens.muted)),
                  value: true,
                  onChanged: null,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Auto-capitalization'),
                  subtitle: Text('Coming soon', style: theme.textTheme.bodySmall?.copyWith(color: DesignTokens.muted)),
                  value: false,
                  onChanged: null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
