import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../design/tokens.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spaceXxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.question_mark, size: 64, color: DesignTokens.muted.withValues(alpha: 0.5)),
              const SizedBox(height: DesignTokens.spaceLg),
              Text('Page Not Found', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: DesignTokens.spaceSm),
              Text("The page you're looking for doesn't exist.",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: DesignTokens.muted)),
              const SizedBox(height: DesignTokens.spaceXl),
              FilledButton.icon(
                icon: const Icon(Icons.home),
                label: const Text('Go Home'),
                onPressed: () => context.go('/'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
