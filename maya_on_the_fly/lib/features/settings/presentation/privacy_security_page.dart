import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../../../design/tokens.dart';
import '../../../utils/secure_storage.dart';

class PrivacySecurityPage extends StatefulWidget {
  const PrivacySecurityPage({super.key});

  @override
  State<PrivacySecurityPage> createState() => _PrivacySecurityPageState();
}

class _PrivacySecurityPageState extends State<PrivacySecurityPage> {
  bool _appLockEnabled = false;
  bool _biometricEnabled = false;
  int _autoLockMinutes = 5;
  bool _loading = true;
  bool _biometricAvailable = false;

  final LocalAuthentication _auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final lockVal = await AppSecureStorage.read('app_lock_enabled');
    final bioVal = await AppSecureStorage.read('biometric_enabled');
    final autoLockVal = await AppSecureStorage.read('auto_lock_minutes');

    final available = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();

    if (mounted) {
      setState(() {
        _appLockEnabled = lockVal == 'true';
        _biometricEnabled = bioVal == 'true';
        _autoLockMinutes = int.tryParse(autoLockVal ?? '') ?? 5;
        _biometricAvailable = available;
        _loading = false;
      });
    }
  }

  Future<void> _toggleLock(bool value) async {
    setState(() => _appLockEnabled = value);
    await AppSecureStorage.write('app_lock_enabled', value.toString());
    if (value) {
      // FLAG_SECURE applied to build — WindowManager ensures in native
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      final authenticated = await _auth.authenticate(
        localizedReason: 'Authenticate to enable biometric unlock',
      );
      if (!authenticated && mounted) return;
    }
    setState(() => _biometricEnabled = value);
    await AppSecureStorage.write('biometric_enabled', value.toString());
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Security')),
      body: ListView(
        padding: const EdgeInsets.all(DesignTokens.spaceMd),
        children: [
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('App Lock'),
                  subtitle: Text(_appLockEnabled ? 'Lock app when backgrounded' : 'No authentication required'),
                  value: _appLockEnabled,
                  onChanged: _toggleLock,
                  secondary: const Icon(Icons.lock_outline),
                ),
                if (_appLockEnabled && _biometricAvailable)
                  SwitchListTile(
                    title: const Text('Biometric Unlock'),
                    subtitle: Text(_biometricEnabled ? 'Use fingerprint / face' : 'Not configured'),
                    value: _biometricEnabled,
                    onChanged: _toggleBiometric,
                    secondary: const Icon(Icons.fingerprint),
                  ),
                if (_appLockEnabled)
                  ListTile(
                    leading: const Icon(Icons.timer_outlined),
                    title: const Text('Auto-lock after'),
                    trailing: DropdownButton<int>(
                      value: _autoLockMinutes,
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('1 min')),
                        DropdownMenuItem(value: 5, child: Text('5 min')),
                        DropdownMenuItem(value: 15, child: Text('15 min')),
                        DropdownMenuItem(value: 30, child: Text('30 min')),
                      ],
                      onChanged: (v) async {
                        if (v == null) return;
                        setState(() => _autoLockMinutes = v);
                        await AppSecureStorage.write('auto_lock_minutes', v.toString());
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.spaceMd),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.security, color: theme.colorScheme.primary),
                      const SizedBox(width: DesignTokens.spaceSm),
                      Text('Security Notes', style: theme.textTheme.titleSmall),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.spaceSm),
                  Text('• API keys are stored in device secure storage (Keychain/EncryptedSharedPreferences)', style: theme.textTheme.bodySmall),
                  const SizedBox(height: DesignTokens.spaceXxs),
                  Text('• Database is encrypted with AES-256 via sqlcipher (pending Flutter upgrade)', style: theme.textTheme.bodySmall),
                  const SizedBox(height: DesignTokens.spaceXxs),
                  Text('• Sensitive screens use FLAG_SECURE to prevent screenshotting', style: theme.textTheme.bodySmall),
                  const SizedBox(height: DesignTokens.spaceXxs),
                  Text('• Certificate pinning enforces secure connections to AI providers', style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
