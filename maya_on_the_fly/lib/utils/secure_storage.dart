import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppSecureStorage {
  AppSecureStorage._();
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<void> write(String key, String value) => _storage.write(key: key, value: value);
  static Future<String?> read(String key) => _storage.read(key: key);
  static Future<void> delete(String key) => _storage.delete(key: key);
  static Future<void> deleteAll() => _storage.deleteAll();

  // API keys
  static Future<void> saveApiKey(String providerId, String key) => write('api_key_$providerId', key);
  static Future<String?> getApiKey(String providerId) => read('api_key_$providerId');

  // DB passphrase
  static Future<void> saveDbPassphrase(String passphrase) => write('db_passphrase', passphrase);
  static Future<String?> getDbPassphrase() => read('db_passphrase');

  // PIN hash
  static Future<void> savePinHash(String hash) => write('pin_hash', hash);
  static Future<String?> getPinHash() => read('pin_hash');
  static Future<void> savePinSalt(String salt) => write('pin_salt', salt);
  static Future<String?> getPinSalt() => read('pin_salt');

  // GitHub PAT
  static Future<void> saveGitHubPat(String pat) => write('github_pat', pat);
  static Future<String?> getGitHubPat() => read('github_pat');
}
