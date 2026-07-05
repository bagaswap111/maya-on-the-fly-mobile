import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/home/presentation/home_page.dart';
import '../features/editor/presentation/editor_page.dart';
import '../features/chat/presentation/chat_list_page.dart';
import '../features/chat/presentation/chat_page.dart';
import '../features/chat/presentation/new_chat_page.dart';
import '../features/git/presentation/git_repo_list_page.dart';
import '../features/git/presentation/git_status_page.dart';
import '../features/git/presentation/git_diff_page.dart';
import '../features/git/presentation/git_commit_page.dart';
import '../features/git/presentation/git_conflict_page.dart';
import '../features/export/presentation/export_page.dart';
import '../features/settings/presentation/settings_page.dart';
import '../features/settings/presentation/model_manager_page.dart';
import '../features/settings/presentation/usage_dashboard_page.dart';
import '../features/settings/presentation/profile_page.dart';
import '../features/settings/presentation/appearance_page.dart';
import '../features/settings/presentation/editor_settings_page.dart';
import '../features/settings/presentation/privacy_security_page.dart';
import '../features/settings/presentation/keyboard_shortcuts_page.dart';
import '../features/settings/presentation/about_page.dart';
import '../features/cot/presentation/cot_project_list_page.dart';
import '../features/cot/presentation/cot_artifact_editor_page.dart';
import '../features/onboarding/presentation/onboarding_page.dart';
import '../features/onboarding/data/onboarding_service.dart';
import '../shared/widgets/shell_scaffold.dart';
import '../shared/widgets/not_found_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  redirect: (context, state) async {
    if (state.fullPath == '/onboarding') return null;
    final complete = await OnboardingService.instance.isOnboardingComplete();
    if (!complete) return '/onboarding';
    return null;
  },
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => ShellScaffold(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorKey,
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomePage(),
              routes: [
                GoRoute(path: 'doc/new', builder: (context, state) => const EditorPage(isNew: true)),
                GoRoute(path: 'doc/:id', builder: (context, state) => EditorPage(docId: state.pathParameters['id'])),
                GoRoute(path: 'doc/:id/preview', builder: (context, state) => const EditorPage(isPreview: true)),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/chat',
              builder: (context, state) => const ChatListPage(),
              routes: [
                GoRoute(path: 'new', builder: (context, state) => const NewChatPage()),
                GoRoute(path: ':id', builder: (context, state) => ChatPage(sessionId: state.pathParameters['id'])),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/git',
              builder: (context, state) => const GitStatusPage(),
              routes: [
                GoRoute(path: 'manage', builder: (context, state) => const GitRepoListPage()),
                GoRoute(path: ':repo/diff', builder: (context, state) => const GitDiffPage()),
                GoRoute(path: ':repo/commit', builder: (context, state) => const GitCommitPage()),
                GoRoute(path: ':repo/conflict', builder: (context, state) => const GitConflictPage()),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsPage(),
              routes: [
                GoRoute(path: 'profile', builder: (context, state) => const ProfilePage()),
                GoRoute(path: 'ai', builder: (context, state) => const ModelManagerPage()),
                GoRoute(path: 'usage', builder: (context, state) => const UsageDashboardPage()),
                GoRoute(path: 'appearance', builder: (context, state) => const AppearancePage()),
                GoRoute(path: 'editor', builder: (context, state) => const EditorSettingsPage()),
                GoRoute(path: 'privacy', builder: (context, state) => const PrivacySecurityPage()),
                GoRoute(path: 'shortcuts', builder: (context, state) => const KeyboardShortcutsPage()),
                GoRoute(path: 'about', builder: (context, state) => const AboutPage()),
              ],
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/cot',
      builder: (context, state) => const CotProjectListPage(),
      routes: [
        GoRoute(path: 'new', builder: (context, state) => const CotProjectListPage()),
        GoRoute(path: ':project', builder: (context, state) => const CotArtifactEditorPage()),
      ],
    ),
    GoRoute(
      path: '/export',
      builder: (context, state) => const ExportPage(),
      routes: [
        GoRoute(path: ':docId/format', builder: (context, state) => const ExportPage()),
        GoRoute(path: ':docId/destination', builder: (context, state) => const ExportPage()),
        GoRoute(path: ':docId/progress', builder: (context, state) => const ExportPage()),
      ],
    ),
  ],
  errorBuilder: (context, state) => const NotFoundPage(),
);
