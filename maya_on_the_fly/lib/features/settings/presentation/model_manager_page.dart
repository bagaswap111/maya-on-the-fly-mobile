import 'package:flutter/material.dart';
import '../../../design/tokens.dart';
import '../../../utils/error_handler.dart';
import '../../ai/data/providers/deepseek_provider.dart';
import '../../../utils/secure_storage.dart';

class ModelManagerPage extends StatefulWidget {
  const ModelManagerPage({super.key});

  @override
  State<ModelManagerPage> createState() => _ModelManagerPageState();
}

class _ModelManagerPageState extends State<ModelManagerPage> {
  final DeepSeekProvider _deepseek = DeepSeekProvider();
  final _apiKeyController = TextEditingController();
  bool _obscureKey = true;
  bool _loading = true;
  bool _showKeyWarning = false;
  bool _keyTouched = false;

  bool get _keyValid => _apiKeyController.text.trim().isEmpty || _apiKeyController.text.trim().startsWith('sk-');
  bool get _canSaveKey => _keyValid;

  @override
  void initState() {
    super.initState();
    _loadKey();
  }

  Future<void> _loadKey() async {
    final key = await AppSecureStorage.read('deepseek_api_key');
    if (mounted) {
      setState(() {
        if (key != null) _apiKeyController.text = key;
        _loading = false;
      });
    }
  }

  Future<void> _saveKey() async {
    if (!_canSaveKey) {
      setState(() => _keyTouched = true);
      return;
    }
    final key = _apiKeyController.text.trim();
    if (key.isEmpty) {
      await AppSecureStorage.delete('deepseek_api_key');
    } else {
      await AppSecureStorage.write('deepseek_api_key', key);
    }
    setState(() { _showKeyWarning = false; _keyTouched = false; });
    if (mounted) {
      ErrorHandler.showSuccess(context, 'API key saved');
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Model Manager'),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _saveKey)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(DesignTokens.spaceMd),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.psychology, color: theme.colorScheme.primary),
                      const SizedBox(width: DesignTokens.spaceSm),
                      Text('DeepSeek', style: theme.textTheme.titleMedium),
                      const Spacer(),
                      Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 20),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.spaceMd),
                  TextField(
                    controller: _apiKeyController,
                    obscureText: _obscureKey,
                    decoration: InputDecoration(
                      labelText: 'API Key',
                      hintText: 'sk-...',
                      suffixIcon: IconButton(
                        icon: Icon(_obscureKey ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscureKey = !_obscureKey),
                      ),
                      errorText: _keyTouched && !_keyValid ? 'API key should start with "sk-"' : null,
                    ),
                    onChanged: (_) {
                      if (!_showKeyWarning) setState(() => _showKeyWarning = true);
                      if (_keyTouched) setState(() {});
                    },
                  ),
                  if (_showKeyWarning)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('Save your changes', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
                    ),
                  const SizedBox(height: DesignTokens.spaceSm),
                  Text('Get a free API key at platform.deepseek.com', style: theme.textTheme.bodySmall?.copyWith(color: DesignTokens.muted)),
                ],
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.spaceMd),
          Text('Available Models', style: theme.textTheme.titleMedium),
          const SizedBox(height: DesignTokens.spaceSm),
          ...(_deepseek.models.map((m) => Card(
            child: ListTile(
              leading: const Icon(Icons.memory),
              title: Text(m),
              subtitle: Text(m == 'deepseek-v4-flash' ? 'Primary model (recommended)' : ''),
              trailing: const Icon(Icons.check_circle, size: 18),
            ),
          ))),
        ],
      ),
    );
  }
}
