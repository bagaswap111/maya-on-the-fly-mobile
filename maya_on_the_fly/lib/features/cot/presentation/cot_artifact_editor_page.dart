import 'package:flutter/material.dart';
import '../../../design/tokens.dart';

class CotArtifactEditorPage extends StatelessWidget {
  const CotArtifactEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Artifact Editor')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article, size: 48, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
            const SizedBox(height: DesignTokens.spaceMd),
            Text('Artifact Editor', style: theme.textTheme.titleLarge),
            const SizedBox(height: DesignTokens.spaceSm),
            Text(
              'Edit Chain of Truth artifacts.\nComing in a future update.',
              style: theme.textTheme.bodyMedium?.copyWith(color: DesignTokens.muted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
