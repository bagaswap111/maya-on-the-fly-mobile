import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: ListView(
        children: [
          _Section(title: 'Profile', children: [
            _Tile(icon: Icons.person, title: 'Profile', trailing: const Icon(Icons.chevron_right), onTap: () => context.push('/settings/profile')),
          ]),
          _Section(title: 'AI Configuration', children: [
            _Tile(icon: Icons.psychology, title: 'Model Manager', trailing: const Icon(Icons.chevron_right), onTap: () => context.push('/settings/ai')),
            _Tile(icon: Icons.bar_chart, title: 'Usage Dashboard', trailing: const Icon(Icons.chevron_right), onTap: () => context.push('/settings/usage')),
          ]),
          _Section(title: 'Appearance', children: [
            _Tile(icon: Icons.sunny, title: 'Theme', trailing: const Icon(Icons.chevron_right), onTap: () => context.push('/settings/appearance')),
          ]),
          _Section(title: 'Editor', children: [
            _Tile(icon: Icons.text_fields, title: 'Editor Settings', trailing: const Icon(Icons.chevron_right), onTap: () => context.push('/settings/editor')),
          ]),
          _Section(title: 'Privacy & Security', children: [
            _Tile(icon: Icons.lock, title: 'App Lock', trailing: const Icon(Icons.chevron_right), onTap: () => context.push('/settings/privacy')),
          ]),
          _Section(title: 'About', children: [
            _Tile(icon: Icons.info_outline, title: 'About', trailing: const Text('v1.0.0'), onTap: () => context.push('/settings/about')),
          ]),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(DesignTokens.spaceMd, DesignTokens.spaceLg, DesignTokens.spaceMd, DesignTokens.spaceXs),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: DesignTokens.muted)),
        ),
        ...children,
        const Divider(height: 1),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _Tile({required this.icon, required this.title, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
