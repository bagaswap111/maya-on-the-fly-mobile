import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:maya_on_the_fly/features/settings/data/database/app_database.dart';
import 'package:maya_on_the_fly/features/settings/data/database/daos/chat_dao.dart';
import 'package:maya_on_the_fly/features/settings/data/database/daos/document_dao.dart';
import 'package:maya_on_the_fly/features/settings/data/database/daos/profile_dao.dart';
import 'package:maya_on_the_fly/features/settings/data/database/daos/usage_dao.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'dart:io';

/// Mock path provider for testing
class MockPathProvider extends PathProviderPlatform with MockPlatformInterfaceMixin {
  @override
  Future<String> getApplicationDocumentsPath() async {
    return Directory.systemTemp.path;
  }

  @override
  Future<String> getTemporaryPath() async {
    return Directory.systemTemp.path;
  }

  @override
  Future<String?> getApplicationSupportPath() async {
    return Directory.systemTemp.path;
  }

  @override
  Future<String?> getLibraryPath() async {
    return Directory.systemTemp.path;
  }

  @override
  Future<List<String>?> getExternalStoragePaths({StorageDirectory? type}) async {
    return [Directory.systemTemp.path];
  }

  @override
  Future<String?> getApplicationCachePath() async {
    return Directory.systemTemp.path;
  }

  @override
  Future<String?> getDownloadsPath() async {
    return Directory.systemTemp.path;
  }

  @override
  Future<List<String>?> getExternalCachePaths() async {
    return [Directory.systemTemp.path];
  }
}

void main() {
  late AppDatabase appDb;

  setUpAll(() {
    // Initialize FFI for sqflite
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Mock path provider
    PathProviderPlatform.instance = MockPathProvider();

    // Initialize AppDatabase
    appDb = AppDatabase.instance;
  });

  setUp(() async {
    // Ensure fresh database for each test
    await appDb.close();
    // Delete the old database file
    final dir = Directory(Directory.systemTemp.path);
    final dbFile = File('${dir.path}/app.db');
    if (await dbFile.exists()) {
      await dbFile.delete();
    }
  });

  group('AppDatabase', () {
    test('initializes with encryption', () async {
      await appDb.initialize(passphrase: 'test-passphrase-1234567890abcdef');
      expect(appDb.isInitialized, true);

      // Verify access works
      final accessible = await appDb.verifyAccess();
      expect(accessible, true);

      // Query tables exist
      final tables = await appDb.db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name"
      );
      final tableNames = tables.map((t) => t['name'] as String).toList();
      expect(tableNames, contains('documents'));
      expect(tableNames, contains('chat_sessions'));
      expect(tableNames, contains('chat_messages'));
      expect(tableNames, contains('user_profiles'));
      expect(tableNames, contains('usage_records'));
      expect(tableNames, contains('export_records'));
      expect(tableNames, contains('repositories'));
    });

    test('creates all tables on initialization', () async {
      await appDb.initialize(passphrase: 'test-passphrase-1234567890abcdef');
      final tables = await appDb.db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name"
      );
      final tableNames = tables.map((t) => t['name'] as String).toList();
      expect(tableNames.length, greaterThanOrEqualTo(9));
    });

    test('creates indexes on initialization', () async {
      await appDb.initialize(passphrase: 'test-passphrase-1234567890abcdef');
      final indexes = await appDb.db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' ORDER BY name"
      );
      final indexNames = indexes.map((i) => i['name'] as String).toList();
      expect(indexNames, contains('idx_documents_updated'));
      expect(indexNames, contains('idx_chat_messages_session'));
    });

    test('handles re-initialization gracefully', () async {
      await appDb.initialize(passphrase: 'test-passphrase-1234567890abcdef');
      await appDb.initialize(passphrase: 'test-passphrase-1234567890abcdef');
      expect(appDb.isInitialized, true);
    });

    test('close releases database', () async {
      await appDb.initialize(passphrase: 'test-passphrase-1234567890abcdef');
      await appDb.close();
      expect(appDb.isInitialized, false);
    });
  });

  group('DocumentDao', () {
    late DocumentDao documentDao;

    setUp(() async {
      await appDb.initialize(passphrase: 'test-passphrase-1234567890abcdef');
      documentDao = DocumentDao();
    });

    test('inserts and retrieves document', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await documentDao.insert({
        'id': 'doc1',
        'title': 'Test Document',
        'content': 'Hello World',
        'file_path': '/test/doc1.md',
        'created_at': now,
        'updated_at': now,
        'last_opened_at': now,
        'is_pinned': 0,
        'word_count': 2,
        'content_preview': 'Hello World',
      });

      final doc = await documentDao.getById('doc1');
      expect(doc, isNotNull);
      expect(doc!['title'], 'Test Document');
      expect(doc['content'], 'Hello World');
    });

    test('updates document', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await documentDao.insert({
        'id': 'doc2',
        'title': 'Original',
        'content': 'Original content',
        'file_path': '/test/doc2.md',
        'created_at': now,
        'updated_at': now,
        'last_opened_at': now,
        'is_pinned': 0,
        'word_count': 2,
        'content_preview': 'Original',
      });

      await documentDao.update('doc2', {
        'title': 'Updated',
        'content': 'Updated content',
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'word_count': 2,
        'content_preview': 'Updated',
      });

      final doc = await documentDao.getById('doc2');
      expect(doc!['title'], 'Updated');
      expect(doc['content'], 'Updated content');
    });

    test('deletes document', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await documentDao.insert({
        'id': 'doc3',
        'title': 'To Delete',
        'content': 'Content',
        'file_path': '/test/doc3.md',
        'created_at': now,
        'updated_at': now,
        'last_opened_at': now,
        'is_pinned': 0,
        'word_count': 1,
        'content_preview': 'Content',
      });

      await documentDao.delete('doc3');
      final doc = await documentDao.getById('doc3');
      expect(doc, isNull);
    });

    test('lists all documents', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      for (var i = 0; i < 3; i++) {
        await documentDao.insert({
          'id': 'list_doc_$i',
          'title': 'Doc $i',
          'content': 'Content $i',
          'file_path': '/test/doc_$i.md',
          'created_at': now,
          'updated_at': now + i,
          'last_opened_at': now,
          'is_pinned': i == 0 ? 1 : 0,
          'word_count': 2,
          'content_preview': 'Content $i',
        });
      }

      final docs = await documentDao.getAll();
      expect(docs.length, 3);
    });
  });

  group('ChatDao', () {
    late ChatDao chatDao;

    setUp(() async {
      await appDb.initialize(passphrase: 'test-passphrase-1234567890abcdef');
      chatDao = ChatDao();
    });

    test('inserts and retrieves chat session', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await chatDao.insertSession({
        'id': 'session1',
        'title': 'Test Chat',
        'agent_id': 'auto',
        'token_count': 0,
        'created_at': now,
        'updated_at': now,
      });

      final session = await chatDao.getSession('session1');
      expect(session, isNotNull);
      expect(session!['title'], 'Test Chat');
    });

    test('inserts and retrieves messages', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await chatDao.insertSession({
        'id': 'session_msg',
        'title': 'Messages Test',
        'agent_id': 'auto',
        'token_count': 0,
        'created_at': now,
        'updated_at': now,
      });

      await chatDao.insertMessage({
        'id': 'msg1',
        'session_id': 'session_msg',
        'role': 'user',
        'content': 'Hello',
        'created_at': now,
      });

      await chatDao.insertMessage({
        'id': 'msg2',
        'session_id': 'session_msg',
        'role': 'assistant',
        'content': 'Hi there!',
        'created_at': now + 1,
      });

      final messages = await chatDao.getMessages('session_msg');
      expect(messages.length, 2);
      expect(messages[0]['role'], 'user');
      expect(messages[1]['role'], 'assistant');
    });

    test('deletes session with messages', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await chatDao.insertSession({
        'id': 'session_del',
        'title': 'To Delete',
        'agent_id': 'auto',
        'token_count': 0,
        'created_at': now,
        'updated_at': now,
      });
      await chatDao.insertMessage({
        'id': 'msg_del',
        'session_id': 'session_del',
        'role': 'user',
        'content': 'Delete me',
        'created_at': now,
      });

      await chatDao.deleteSession('session_del');
      final session = await chatDao.getSession('session_del');
      expect(session, isNull);
      final messages = await chatDao.getMessages('session_del');
      expect(messages, isEmpty);
    });
  });

  group('ProfileDao', () {
    late ProfileDao profileDao;

    setUp(() async {
      await appDb.initialize(passphrase: 'test-passphrase-1234567890abcdef');
      profileDao = ProfileDao();
    });

    test('inserts and retrieves profile', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await profileDao.upsertProfile({
        'id': 'profile1',
        'name': 'Test User',
        'email': 'test@example.com',
        'mode': 'writer',
        'created_at': now,
        'updated_at': now,
      });

      final profile = await profileDao.getProfile('profile1');
      expect(profile, isNotNull);
      expect(profile!['name'], 'Test User');
      expect(profile['mode'], 'writer');
    });

    test('upserts profile (replaces existing)', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await profileDao.upsertProfile({
        'id': 'profile_upsert',
        'name': 'Original Name',
        'mode': 'writer',
        'created_at': now,
        'updated_at': now,
      });

      await profileDao.upsertProfile({
        'id': 'profile_upsert',
        'name': 'Updated Name',
        'mode': 'developer',
        'created_at': now,
        'updated_at': now + 1,
      });

      final profile = await profileDao.getProfile('profile_upsert');
      expect(profile!['name'], 'Updated Name');
      expect(profile['mode'], 'developer');
    });
  });

  group('UsageDao', () {
    late UsageDao usageDao;

    setUp(() async {
      await appDb.initialize(passphrase: 'test-passphrase-1234567890abcdef');
      usageDao = UsageDao();
    });

    test('inserts and retrieves usage records', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await usageDao.insertRecord({
        'id': 'usage1',
        'provider_id': 'deepseek',
        'model_id': 'deepseek-v3',
        'task_type': 'chat',
        'input_tokens': 100,
        'output_tokens': 50,
        'cost': 0.0015,
        'created_at': now,
      });

      final records = await usageDao.getRecords();
      expect(records.length, 1);
      expect(records.first['input_tokens'], 100);
    });

    test('filters usage records by provider', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await usageDao.insertRecord({
        'id': 'usage_a',
        'provider_id': 'provider_a',
        'model_id': 'model1',
        'task_type': 'chat',
        'input_tokens': 10,
        'output_tokens': 5,
        'cost': 0.0001,
        'created_at': now,
      });
      await usageDao.insertRecord({
        'id': 'usage_b',
        'provider_id': 'provider_b',
        'model_id': 'model2',
        'task_type': 'code',
        'input_tokens': 20,
        'output_tokens': 10,
        'cost': 0.0002,
        'created_at': now,
      });

      final filtered = await usageDao.getRecords(providerId: 'provider_a');
      expect(filtered.length, 1);
      expect(filtered.first['provider_id'], 'provider_a');
    });
  });
}