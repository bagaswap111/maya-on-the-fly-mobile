import 'package:flutter/material.dart';
import '../../../design/tokens.dart';

class CotProjectListPage extends StatelessWidget {
  const CotProjectListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Chain of Truth')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_tree, size: 48, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
            const SizedBox(height: DesignTokens.spaceMd),
            Text('Chain of Truth Projects', style: theme.textTheme.titleLarge),
            const SizedBox(height: DesignTokens.spaceSm),
            Text(
              'Structured reasoning projects with evidence chains.\nComing in a future update.',
              style: theme.textTheme.bodyMedium?.copyWith(color: DesignTokens.muted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
