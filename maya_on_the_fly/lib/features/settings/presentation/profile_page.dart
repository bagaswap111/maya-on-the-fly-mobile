import 'package:flutter/material.dart';
import '../../../design/tokens.dart';
import '../../../utils/error_handler.dart';
import '../../settings/data/database/daos/profile_dao.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileDao _dao = ProfileDao();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _signatureController = TextEditingController();
  String _mode = 'free';
  bool _loading = true;
  final String _profileId = 'default';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _dao.getProfile(_profileId);
    if (mounted && profile != null) {
      setState(() {
        _nameController.text = profile['name'] as String? ?? '';
        _emailController.text = profile['email'] as String? ?? '';
        _signatureController.text = profile['signature'] as String? ?? '';
        _mode = profile['mode'] as String? ?? 'free';
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _dao.upsertProfile({
      'id': _profileId,
      'name': _nameController.text,
      'email': _emailController.text,
      'signature': _signatureController.text,
      'mode': _mode,
      'created_at': now,
      'updated_at': now,
    });
    if (mounted) {
      ErrorHandler.showSuccess(context, 'Profile saved');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _save)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(DesignTokens.spaceMd),
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name', hintText: 'Your display name'),
          ),
          const SizedBox(height: DesignTokens.spaceMd),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email', hintText: 'your@email.com'),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: DesignTokens.spaceMd),
          TextField(
            controller: _signatureController,
            decoration: const InputDecoration(labelText: 'Signature', hintText: 'Your name / title for documents'),
            maxLines: 2,
          ),
          const SizedBox(height: DesignTokens.spaceLg),
          Text('Mode', style: theme.textTheme.titleMedium),
          const SizedBox(height: DesignTokens.spaceSm),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'free', label: Text('Free'), icon: Icon(Icons.auto_awesome)),
              ButtonSegment(value: 'custom', label: Text('Custom'), icon: Icon(Icons.tune)),
            ],
            selected: {_mode},
            onSelectionChanged: (v) => setState(() => _mode = v.first),
          ),
          const SizedBox(height: DesignTokens.spaceSm),
          Text(
            _mode == 'free'
              ? 'One model handles all tasks automatically'
              : 'Assign different models per task and agent',
            style: theme.textTheme.bodySmall?.copyWith(color: DesignTokens.muted),
          ),
        ],
      ),
    );
  }
}
