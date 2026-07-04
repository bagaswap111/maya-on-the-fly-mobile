import 'package:flutter/material.dart';
import '../../settings/data/database/daos/profile_dao.dart';
import '../../settings/data/database/app_database.dart';

class AppearancePage extends StatefulWidget {
  const AppearancePage({super.key});

  @override
  State<AppearancePage> createState() => _AppearancePageState();
}

class _AppearancePageState extends State<AppearancePage> {
  final ProfileDao _dao = ProfileDao();
  String _theme = 'system';
  String _codeTheme = 'github-dark';
  int _fontSize = 16;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await _dao.getProfile('default');
    if (mounted && profile != null) {
      setState(() {
        _theme = profile['theme'] as String? ?? 'system';
        _fontSize = profile['font_size'] as int? ?? 16;
        _codeTheme = profile['code_theme'] as String? ?? 'github-dark';
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _dao.upsertProfile({
      'id': 'default',
      'name': '',
      'mode': 'free',
      'theme': _theme,
      'code_theme': _codeTheme,
      'font_size': _fontSize,
      'created_at': now,
      'updated_at': now,
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appearance saved'), duration: Duration(seconds: 1)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _save)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Theme', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'light', label: Text('Light'), icon: Icon(Icons.light_mode)),
              ButtonSegment(value: 'dark', label: Text('Dark'), icon: Icon(Icons.dark_mode)),
              ButtonSegment(value: 'system', label: Text('System'), icon: Icon(Icons.settings)),
            ],
            selected: {_theme},
            onSelectionChanged: (v) => setState(() => _theme = v.first),
          ),
          const SizedBox(height: 24),
          Text('Editor Font Size', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.remove), onPressed: _fontSize > 12 ? () => setState(() => _fontSize--) : null),
              Text('$_fontSize', style: theme.textTheme.titleLarge),
              IconButton(icon: const Icon(Icons.add), onPressed: _fontSize < 24 ? () => setState(() => _fontSize++) : null),
            ],
          ),
        ],
      ),
    );
  }
}
