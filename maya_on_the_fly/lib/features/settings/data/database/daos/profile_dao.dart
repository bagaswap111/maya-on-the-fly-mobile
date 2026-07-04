import 'package:sqflite/sqflite.dart';
import '../app_database.dart';

class ProfileDao {
  final AppDatabase _db = AppDatabase.instance;

  Future<Map<String, dynamic>?> getProfile(String id) async {
    final results = await _db.db.query('user_profiles', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> upsertProfile(Map<String, dynamic> row) async {
    await _db.db.insert('user_profiles', row,
      conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
