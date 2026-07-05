import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Tracks onboarding progress and manages first-run experience
class OnboardingService {
  OnboardingService._();
  static final OnboardingService _instance = OnboardingService._();
  static OnboardingService get instance => _instance;

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _onboardingCompleteKey = 'onboarding_complete';
  static const _onboardingStepKey = 'onboarding_step';

  /// Check if onboarding has been completed
  Future<bool> isOnboardingComplete() async {
    final value = await _storage.read(key: _onboardingCompleteKey);
    return value == 'true';
  }

  /// Get current onboarding step (0-based)
  Future<int> getCurrentStep() async {
    final value = await _storage.read(key: _onboardingStepKey);
    return int.tryParse(value ?? '0') ?? 0;
  }

  /// Mark a step as completed and advance to next
  Future<void> completeStep(int step) async {
    await _storage.write(key: _onboardingStepKey, value: (step + 1).toString());
  }

  /// Mark onboarding as fully complete
  Future<void> completeOnboarding() async {
    await _storage.write(key: _onboardingCompleteKey, value: 'true');
    await _storage.write(key: _onboardingStepKey, value: '5');
  }

  /// Reset onboarding (for testing or re-onboarding)
  Future<void> resetOnboarding() async {
    await _storage.write(key: _onboardingCompleteKey, value: 'false');
    await _storage.write(key: _onboardingStepKey, value: '0');
  }

  /// Get onboarding steps with content
  List<OnboardingStep> getSteps() => const [
    OnboardingStep(
      step: 0,
      title: 'Welcome to Maya on the Fly',
      description: 'Your AI-powered document creation assistant. Create, edit, and export documents with the help of intelligent agents.',
      icon: 'rocket',
      actionLabel: 'Get Started',
    ),
    OnboardingStep(
      step: 1,
      title: 'Create Documents',
      description: 'Write in Markdown with live preview. Use the editor to create rich documents with formatting, code blocks, and images.',
      icon: 'edit',
      actionLabel: 'Next',
    ),
    OnboardingStep(
      step: 2,
      title: 'Chat with AI Agents',
      description: 'Use the chat feature to collaborate with AI agents. Ask questions, generate content, or get help with your writing.',
      icon: 'chat',
      actionLabel: 'Next',
    ),
    OnboardingStep(
      step: 3,
      title: 'Version Control with Git',
      description: 'Track changes, commit versions, and sync with remote repositories. Your documents are always safe.',
      icon: 'git',
      actionLabel: 'Next',
    ),
    OnboardingStep(
      step: 4,
      title: 'Export & Share',
      description: 'Export your documents to TXT, HTML, PDF, DOCX, and more. Share directly or save for later.',
      icon: 'export',
      actionLabel: 'Start Using Maya',
    ),
  ];
}

class OnboardingStep {
  final int step;
  final String title;
  final String description;
  final String icon;
  final String actionLabel;

  const OnboardingStep({
    required this.step,
    required this.title,
    required this.description,
    required this.icon,
    required this.actionLabel,
  });
}