import '../app_database.dart';

class ChatDao {
  final AppDatabase _db = AppDatabase.instance;

  Future<List<Map<String, dynamic>>> getSessions() async {
    return _db.db.query('chat_sessions', orderBy: 'updated_at DESC');
  }

  Future<Map<String, dynamic>?> getSession(String id) async {
    final results = await _db.db.query('chat_sessions', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<List<Map<String, dynamic>>> getMessages(String sessionId) async {
    return _db.db.query('chat_messages',
      where: 'session_id = ?', whereArgs: [sessionId], orderBy: 'created_at ASC');
  }

  Future<void> insertSession(Map<String, dynamic> row) async {
    await _db.db.insert('chat_sessions', row);
  }

  Future<void> insertMessage(Map<String, dynamic> row) async {
    await _db.db.insert('chat_messages', row);
  }

  Future<void> deleteSession(String id) async {
    await _db.db.delete('chat_messages', where: 'session_id = ?', whereArgs: [id]);
    await _db.db.delete('chat_sessions', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateMessage(String id, {required String content}) async {
    await _db.db.update(
      'chat_messages',
      {'content': content},
      where: 'id = ?', whereArgs: [id],
    );
  }

  Future<void> deleteMessage(String id) async {
    await _db.db.delete('chat_messages', where: 'id = ?', whereArgs: [id]);
  }
}
