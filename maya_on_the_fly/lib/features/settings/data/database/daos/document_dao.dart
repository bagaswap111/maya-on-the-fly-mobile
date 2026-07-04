import '../app_database.dart';

class DocumentDao {
  final AppDatabase _db = AppDatabase.instance;

  Future<List<Map<String, dynamic>>> getAll() async {
    return _db.db.query('documents', orderBy: 'updated_at DESC');
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    final results = await _db.db.query('documents', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> insert(Map<String, dynamic> row) async {
    await _db.db.insert('documents', row);
  }

  Future<void> update(String id, Map<String, dynamic> row) async {
    await _db.db.update('documents', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> delete(String id) async {
    await _db.db.delete('documents', where: 'id = ?', whereArgs: [id]);
  }
}
