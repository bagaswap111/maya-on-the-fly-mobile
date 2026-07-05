import 'package:flutter/material.dart';
import '../../../design/tokens.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(DesignTokens.spaceMd),
        children: [
          const SizedBox(height: DesignTokens.spaceXl),
          Center(
            child: Column(
              children: [
                Icon(Icons.auto_awesome, size: 64, color: theme.colorScheme.primary),
                const SizedBox(height: DesignTokens.spaceSm),
                Text('Maya on the Fly', style: theme.textTheme.headlineSmall),
                const SizedBox(height: DesignTokens.spaceXxs),
                Text('v1.0.0', style: theme.textTheme.bodyMedium?.copyWith(color: DesignTokens.muted)),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.spaceXl),
          const Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Version'),
                  trailing: Text('1.0.0'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.code),
                  title: Text('Flutter SDK'),
                  trailing: Text('3.10.6'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.memory),
                  title: Text('Core Model'),
                  trailing: Text('DeepSeek V4 Flash'),
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.spaceMd),
          Text(
            'AI-assisted document creation with multi-agent chat, '
            'Git version control, and multi-format export.',
            style: theme.textTheme.bodyMedium?.copyWith(color: DesignTokens.muted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
