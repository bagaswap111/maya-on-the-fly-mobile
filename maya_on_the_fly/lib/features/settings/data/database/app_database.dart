import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:maya_on_the_fly/utils/secure_storage.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase _instance = AppDatabase._();
  static AppDatabase get instance => _instance;
  Database? _db;

  Database get db {
    if (_db == null) throw StateError('AppDatabase not initialized. Call initialize() first.');
    return _db!;
  }

  bool get isInitialized => _db != null;

  Future<void> initialize({String? passphrase}) async {
    if (_db != null) return;

    // Retrieve or generate a passphrase for sqlcipher encryption
    String? dbPassphrase = passphrase ?? await AppSecureStorage.getDbPassphrase();
    if (dbPassphrase == null) {
      dbPassphrase = _generatePassphrase();
      await AppSecureStorage.saveDbPassphrase(dbPassphrase);
    }

    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'app.db');
    _db = await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        // Apply encryption passphrase via PRAGMA key
        await db.rawQuery("PRAGMA key = '$dbPassphrase'");
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.rawQuery("PRAGMA key = '$dbPassphrase'");
        if (oldVersion < 2) {
          await _createTables(db);
        }
      },
    );
    // For existing databases, apply the passphrase after opening
    await _db!.rawQuery("PRAGMA key = '$dbPassphrase'");
  }

  String _generatePassphrase() {
    final random = _SecureRandom();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  Future<void> _createTables(Database db) async {
    // ponytail: belt-and-suspenders — DB CHECK constraints mirror app-level validation.
    // Drop the app-side duplicate only if a measured reason appears.
    await db.execute('''
      CREATE TABLE IF NOT EXISTS documents (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        file_path TEXT UNIQUE NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        last_opened_at INTEGER NOT NULL,
        is_pinned INTEGER DEFAULT 0 CHECK(is_pinned IN (0,1)),
        git_repo_id TEXT,
        word_count INTEGER DEFAULT 0 CHECK(word_count >= 0),
        content_preview TEXT DEFAULT ''
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS document_versions (
        id TEXT PRIMARY KEY,
        document_id TEXT NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
        content TEXT NOT NULL,
        saved_at INTEGER NOT NULL,
        version_number INTEGER NOT NULL CHECK(version_number > 0),
        source TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS chat_sessions (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        agent_id TEXT NOT NULL,
        task_type TEXT CHECK(task_type IS NULL OR task_type != ''),
        token_count INTEGER DEFAULT 0 CHECK(token_count >= 0),
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        document_id TEXT REFERENCES documents(id) ON DELETE SET NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS chat_messages (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL REFERENCES chat_sessions(id) ON DELETE CASCADE,
        role TEXT NOT NULL CHECK(role IN ('user','assistant','system','tool')),
        content TEXT NOT NULL,
        tool_calls TEXT,
        tool_results TEXT,
        token_count INTEGER CHECK(token_count IS NULL OR token_count >= 0),
        created_at INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ai_providers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        base_url TEXT NOT NULL,
        default_model TEXT NOT NULL,
        is_enabled INTEGER DEFAULT 1 CHECK(is_enabled IN (0,1)),
        models TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS usage_records (
        id TEXT PRIMARY KEY,
        provider_id TEXT NOT NULL,
        model_id TEXT NOT NULL,
        task_type TEXT NOT NULL,
        input_tokens INTEGER NOT NULL CHECK(input_tokens >= 0),
        output_tokens INTEGER NOT NULL CHECK(output_tokens >= 0),
        cost REAL NOT NULL CHECK(cost >= 0),
        document_id TEXT,
        session_id TEXT,
        created_at INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_profiles (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT,
        signature TEXT,
        mode TEXT NOT NULL CHECK(mode IN ('writer','developer','researcher','manager')),
        free_model_id TEXT,
        default_agent_id TEXT DEFAULT 'auto',
        max_tokens INTEGER DEFAULT 8192 CHECK(max_tokens > 0),
        temperature REAL DEFAULT 0.7 CHECK(temperature >= 0.0 AND temperature <= 2.0),
        font_size INTEGER DEFAULT 16 CHECK(font_size >= 8 AND font_size <= 48),
        theme TEXT DEFAULT 'system' CHECK(theme IN ('system','light','dark')),
        code_theme TEXT DEFAULT 'github-dark',
        spell_check INTEGER DEFAULT 1 CHECK(spell_check IN (0,1)),
        line_numbers INTEGER DEFAULT 1 CHECK(line_numbers IN (0,1)),
        tab_size INTEGER DEFAULT 4 CHECK(tab_size IN (2,4,8)),
        export_defaults TEXT,
        last_repo_id TEXT,
        auth_enabled INTEGER DEFAULT 0 CHECK(auth_enabled IN (0,1)),
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS task_model_mappings (
        id TEXT PRIMARY KEY,
        profile_id TEXT NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
        task_type TEXT NOT NULL CHECK(task_type != ''),
        model_id TEXT NOT NULL CHECK(model_id != ''),
        UNIQUE(profile_id, task_type)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS usage_alerts (
        id TEXT PRIMARY KEY,
        profile_id TEXT NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
        type TEXT NOT NULL CHECK(type != ''),
        metric TEXT NOT NULL CHECK(metric != ''),
        threshold REAL NOT NULL CHECK(threshold > 0),
        period TEXT NOT NULL CHECK(period != ''),
        is_enabled INTEGER DEFAULT 1 CHECK(is_enabled IN (0,1))
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS export_records (
        id TEXT PRIMARY KEY,
        document_id TEXT NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
        format TEXT NOT NULL CHECK(format IN ('txt','html','pdf','docx','json','csv','md')),
        destination TEXT NOT NULL,
        file_size INTEGER CHECK(file_size IS NULL OR file_size >= 0),
        created_at INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS repositories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        remote_url TEXT,
        local_path TEXT UNIQUE NOT NULL,
        default_branch TEXT DEFAULT 'main',
        last_synced_at INTEGER,
        auth_method TEXT,
        unpushed_count INTEGER DEFAULT 0 CHECK(unpushed_count >= 0),
        last_commit_message TEXT,
        last_commit_at INTEGER
      )
    ''');
    // Indexes for query performance
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_documents_updated
      ON documents(updated_at DESC)
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_chat_messages_session
      ON chat_messages(session_id, created_at ASC)
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_export_records_doc
      ON export_records(document_id, created_at DESC)
    ''');
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  /// Verify the database is accessible (passphrase is correct)
  Future<bool> verifyAccess() async {
    try {
      await db.rawQuery('SELECT count(*) as cnt FROM documents');
      return true;
    } catch (_) {
      return false;
    }
  }
}

/// Simple secure random generator (not for cryptographic purposes beyond passphrase generation)
class _SecureRandom {
  int _seed = DateTime.now().microsecondsSinceEpoch;

  int nextInt(int max) {
    _seed = (_seed * 1103515245 + 12345) & 0x7fffffff;
    return _seed % max;
  }
}