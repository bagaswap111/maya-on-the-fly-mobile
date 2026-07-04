# Data Model Detail — SoT #6

**Status:** Draft | **Last Updated:** 2026-07-04 | **Engine:** drift (SQLite)

## 1. Migration Strategy

- **Initial schema:** `schema_version = 1` with all 11 tables
- **Migration approach:** Drift `onUpgrade` with sequential version checks
- **Destructive changes:** Never drop columns — use additive migrations (new tables, new nullable columns)
- **Data retention:** All data local; no cloud sync

## 2. Drift Table Definitions

### 2.1 Documents

```dart
// lib/features/settings/data/drift/tables.dart

class Documents extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get title => text()();
  TextColumn get content => text()();
  TextColumn get filePath => text().unique()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get lastOpenedAt => dateTime()();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  TextColumn get gitRepoId => text().nullable()(); // FK -> Repository.id
  IntColumn get wordCount => integer().withDefault(const Constant(0))();
  TextColumn get contentPreview => text().withDefault(const Constant(''))(); // first 200 chars

  @override
  Set<Column> get primaryKey => {id};
}
```

**Indexes:**
- `INDEX idx_documents_lastOpenedAt ON documents(lastOpenedAt DESC)`
- `INDEX idx_documents_gitRepoId ON documents(gitRepoId)`
- `INDEX idx_documents_isPinned ON documents(isPinned) WHERE isPinned = 1`

### 2.2 DocumentVersions

```dart
class DocumentVersions extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get documentId => text().references(Documents, #id)();
  TextColumn get content => text()();
  DateTimeColumn get savedAt => dateTime()();
  IntColumn get versionNumber => integer()();
  TextColumn get source => text()(); // 'auto_save' | 'manual_save' | 'git_commit'

  @override
  Set<Column> get primaryKey => {id};
}
```

**Indexes:**
- `INDEX idx_docversions_docId ON document_versions(documentId, versionNumber DESC)`
- **Max 100 versions per document** (enforced in DocumentService: delete oldest on insert)

### 2.3 ChatSessions

```dart
class ChatSessions extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get title => text()();
  TextColumn get agentId => text()();
  TextColumn get taskType => text().nullable()();
  IntColumn get tokenCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get documentId => text().nullable().references(Documents, #id)();

  @override
  Set<Column> get primaryKey => {id};
}
```

**Indexes:**
- `INDEX idx_chatsessions_updatedAt ON chat_sessions(updatedAt DESC)`

### 2.4 ChatMessages

```dart
class ChatMessages extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get sessionId => text().references(ChatSessions, #id)();
  TextColumn get role => text()(); // 'user' | 'assistant' | 'system' | 'tool'
  TextColumn get content => text()();
  TextColumn get toolCalls => text().nullable()(); // JSON string
  TextColumn get toolResults => text().nullable()(); // JSON string
  IntColumn get tokenCount => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
```

**Indexes:**
- `INDEX idx_chatmessages_session ON chat_messages(sessionId, createdAt)`

### 2.5 AIProviders

```dart
class AIProviders extends Table {
  TextColumn get id => text()(); // 'deepseek', 'openai', 'anthropic', etc.
  TextColumn get name => text()();
  TextColumn get baseUrl => text()();
  TextColumn get defaultModel => text()();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  TextColumn get models => text()(); // JSON array of {id, inputPrice, outputPrice, contextWindow}
  DateTimeColumn get createdAt => dateTime()();

  /// API key is stored ONLY in flutter_secure_storage, NOT in drift.
  /// Retrieved via secureStorage.read(key: 'api_key_{providerId}')

  @override
  Set<Column> get primaryKey => {id};
}
```

**Business Rule BR-DM-006:** API keys never stored in drift — only in `flutter_secure_storage`.

### 2.6 UsageRecords

```dart
class UsageRecords extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get providerId => text()();
  TextColumn get modelId => text()();
  TextColumn get taskType => text()();
  IntColumn get inputTokens => integer()();
  IntColumn get outputTokens => integer()();
  RealColumn get cost => real()();
  TextColumn get documentId => text().nullable()();
  TextColumn get sessionId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
```

**Indexes:**
- `INDEX idx_usagerecords_createdAt ON usage_records(createdAt)`
- `INDEX idx_usagerecords_provider ON usage_records(providerId, createdAt)`

**Aggregate Query Examples:**
```sql
-- Month-to-date tokens
SELECT SUM(inputTokens + outputTokens) FROM usage_records
WHERE createdAt >= date('now', 'start of month', '+0 months');

-- Cost by provider this month
SELECT providerId, SUM(cost) FROM usage_records
WHERE createdAt >= date('now', 'start of month')
GROUP BY providerId;

-- Usage by task type
SELECT taskType, SUM(inputTokens), SUM(outputTokens) FROM usage_records
WHERE createdAt >= date('now', '-30 days')
GROUP BY taskType;
```

### 2.7 UserProfiles

```dart
class UserProfiles extends Table {
  TextColumn get id => text()(); // 'default' | 'balanced' | 'economy'
  TextColumn get mode => text()(); // 'free' | 'custom'
  TextColumn get freeModelId => text().nullable()();
  TextColumn get defaultAgentId => text().withDefault(const Constant('auto'))();
  IntColumn get maxTokens => integer().withDefault(const Constant(8192))();
  RealColumn get temperature => real().withDefault(const Constant(0.7))();
  IntColumn get fontSize => integer().withDefault(const Constant(16))();
  TextColumn get theme => text().withDefault(const Constant('system'))(); // 'light' | 'dark' | 'system'
  TextColumn get codeTheme => text().withDefault(const Constant('github-dark'))();
  BoolColumn get spellCheck => boolean().withDefault(const Constant(true))();
  BoolColumn get lineNumbers => boolean().withDefault(const Constant(true))();
  IntColumn get tabSize => integer().withDefault(const Constant(4))();
  TextColumn get exportDefaults => text().nullable()(); // JSON {format, destination}
  TextColumn get lastRepoId => text().nullable()(); // FK -> Repository.id — last viewed git repo
  BoolColumn get authEnabled => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
```

### 2.8 TaskModelMappings

```dart
class TaskModelMappings extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get profileId => text().references(UserProfiles, #id)();
  TextColumn get taskType => text()();
  TextColumn get modelId => text()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<UniqueConstraint> get uniqueConstraints => [
    UniqueConstraint([profileId, taskType], name: 'uq_task_per_profile'),
  ];
}
```

### 2.9 UsageAlerts

```dart
class UsageAlerts extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get profileId => text().references(UserProfiles, #id)();
  TextColumn get type => text()(); // 'warn' | 'block'
  TextColumn get metric => text()(); // 'cost' | 'tokens'
  RealColumn get threshold => real()();
  TextColumn get period => text()(); // 'session' | 'day' | 'month'
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}
```

### 2.10 ExportRecords

```dart
class ExportRecords extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get documentId => text().references(Documents, #id)();
  TextColumn get format => text()(); // 'html' | 'pdf' | 'docx' | 'txt'
  TextColumn get destination => text()(); // 'local' | 'share' | 'icloud' | 'gdrive'
  IntColumn get fileSize => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
```

**Indexes:**
- `INDEX idx_exportrecords_doc ON export_records(documentId, createdAt)`

### 2.11 Repositories

```dart
class Repositories extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get name => text()();
  TextColumn get remoteUrl => text().nullable()();
  TextColumn get localPath => text().unique()();
  TextColumn get defaultBranch => text().withDefault(const Constant('main'))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  TextColumn get authMethod => text().nullable()(); // 'pat' | 'oauth' | 'ssh'
  IntColumn get unpushedCount => integer().withDefault(const Constant(0))();
  TextColumn get lastCommitMessage => text().nullable()();
  DateTimeColumn get lastCommitAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
```

## 3. Drift DAOs

```dart
// lib/features/settings/data/drift/daos/document_dao.dart
@DriftAccessor(tables: [Documents, DocumentVersions])
class DocumentDao extends DatabaseAccessor<AppDatabase> with _$DocumentDaoMixin {
  DocumentDao(super.db);

  // Queries
  Future<List<Document>> recentDocuments({int limit = 20}) =>
      (select(documents)
        ..orderBy([(d) => OrderingTerm(expression: d.lastOpenedAt, mode: OrderingMode.desc)])
        ..limit(limit))
      .get();

  Future<List<Document>> pinnedDocuments() =>
      (select(documents)..where((d) => d.isPinned.equals(true))).get();

  Future<Document?> documentById(String id) =>
      (select(documents)..where((d) => d.id.equals(id))).getSingleOrNull();

  Future<List<DocumentVersion>> versionsForDocument(String docId, {int limit = 100}) =>
      (select(documentVersions)
        ..where((v) => v.documentId.equals(docId))
        ..orderBy([(v) => OrderingTerm(expression: v.versionNumber, mode: OrderingMode.desc)])
        ..limit(limit))
      .get();

  // Writes
  Future<int> insertDocument(Document doc) => into(documents).insert(doc);
  Future<int> updateDocument(Document doc) => update(documents).replace(doc);
  Future<int> deleteDocument(String id) =>
      (delete(documents)..where((d) => d.id.equals(id))).go();

  Future<int> insertVersion(DocumentVersion version) =>
      into(documentVersions).insert(version);

  Future<int> deleteOldestVersions(String docId, int keepCount) async {
    final oldVersions = await (select(documentVersions)
      ..where((v) => v.documentId.equals(docId))
      ..orderBy([(v) => OrderingTerm(expression: v.versionNumber, mode: OrderingMode.asc)])
      ..limit(200 - keepCount, offset: keepCount))
    .get();
    for (final v in oldVersions) {
      await delete(documentVersions).delete(v);
    }
    return oldVersions.length;
  }
}
```

## 4. Relationship Summary

| Parent | Child | Foreign Key | Cascade |
|--------|-------|-------------|---------|
| `Documents` | `DocumentVersions` | `documentVersions.documentId` → `Documents.id` | ON DELETE CASCADE |
| `Documents` | `ChatSessions` | `chatSessions.documentId` → `Documents.id` | ON DELETE SET NULL |
| `Documents` | `ExportRecords` | `exportRecords.documentId` → `Documents.id` | ON DELETE CASCADE |
| `Documents` | `UsageRecords` | `usageRecords.documentId` → `Documents.id` | ON DELETE SET NULL |
| `ChatSessions` | `ChatMessages` | `chatMessages.sessionId` → `ChatSessions.id` | ON DELETE CASCADE |
| `ChatSessions` | `UsageRecords` | `usageRecords.sessionId` → `ChatSessions.id` | ON DELETE SET NULL |
| `UserProfiles` | `TaskModelMappings` | `taskModelMappings.profileId` → `UserProfiles.id` | ON DELETE CASCADE |
| `UserProfiles` | `UsageAlerts` | `usageAlerts.profileId` → `UserProfiles.id` | ON DELETE CASCADE |
| `Repositories` | `Documents` | `documents.gitRepoId` → `Repositories.id` | ON DELETE SET NULL |

## 5. Type Mappings (Drift → Dart)

| Drift Column Type | Dart Type | JSON Type | Notes |
|-------------------|-----------|-----------|-------|
| `text()` | `String` | `string` | UUID, text, JSON-encoded lists/maps |
| `integer()` | `int` | `number` | Counts, version numbers |
| `real()` | `double` | `number` | Cost, temperature |
| `boolean()` | `bool` | `boolean` | Toggles, flags |
| `dateTime()` | `DateTime` | `string (ISO 8601)` | All timestamps UTC |

## 6. Data Volume Estimates

| Table | Est. Rows (1yr) | Est. Size | Notes |
|-------|-----------------|-----------|-------|
| `Documents` | 500 | 50 MB | Average doc: 100KB markdown |
| `DocumentVersions` | 50,000 | 500 MB | 100 versions/doc × 500 docs |
| `ChatSessions` | 2,000 | 1 MB | Mostly metadata |
| `ChatMessages` | 100,000 | 200 MB | ~2KB per message avg |
| `UsageRecords` | 50,000 | 10 MB | One per API call |
| `ExportRecords` | 2,000 | 1 MB | Metadata only |

- **Est. total database size after 1 year:** ~762 MB (includes documents, versions, messages)
- **Mitigation:** Document and message content is the primary driver. Auto-cleanup settings (Settings → Storage) allow user to delete old versions and messages.
- **Export files cached separately:** Not in database. Cached exports stored in `{appDocDir}/exports/` and deletable via "Clear Export Cache"
