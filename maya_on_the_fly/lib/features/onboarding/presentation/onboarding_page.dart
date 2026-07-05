import 'package:flutter/material.dart';
import '../../../design/tokens.dart';
import '../data/onboarding_service.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final OnboardingService _service = OnboardingService.instance;
  final PageController _pageController = PageController();
  int _currentStep = 0;
  late List<OnboardingStep> _steps;

  @override
  void initState() {
    super.initState();
    _steps = _service.getSteps();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentStep < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _finish() async {
    await _service.completeOnboarding();
    if (mounted) Navigator.of(context).pushReplacementNamed('/');
  }

  void _skip() async {
    await _service.completeOnboarding();
    if (mounted) Navigator.of(context).pushReplacementNamed('/');
  }

  IconData _iconFor(String name) {
    switch (name) {
      case 'rocket': return Icons.auto_awesome;
      case 'edit': return Icons.edit_note;
      case 'chat': return Icons.chat_bubble_outline;
      case 'git': return Icons.source_outlined;
      case 'export': return Icons.file_download_outlined;
      default: return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLast = _currentStep == _steps.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _skip,
                child: Text(isLast ? '' : 'Skip'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentStep = i),
                itemCount: _steps.length,
                itemBuilder: (context, index) {
                  final step = _steps[index];
                  return Padding(
                    padding: const EdgeInsets.all(DesignTokens.spaceXl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _iconFor(step.icon),
                          size: 80,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: DesignTokens.spaceLg),
                        Text(
                          step.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: DesignTokens.spaceMd),
                        Text(
                          step.description,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(DesignTokens.spaceLg),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_steps.length, (i) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _currentStep ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _currentStep
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: DesignTokens.spaceLg),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _next,
                      child: Text(isLast ? 'Start Using Maya' : 'Next'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
