import '../app_database.dart';

class UsageDao {
  final AppDatabase _db = AppDatabase.instance;

  Future<List<Map<String, dynamic>>> getRecords({
    String? providerId, String? startDate, String? endDate,
  }) async {
    final conditions = <String>[];
    final args = <dynamic>[];
    if (providerId != null) { conditions.add('provider_id = ?'); args.add(providerId); }
    if (startDate != null) { conditions.add('created_at >= ?'); args.add(startDate); }
    if (endDate != null) { conditions.add('created_at <= ?'); args.add(endDate); }
    final where = conditions.isNotEmpty ? conditions.join(' AND ') : null;
    return _db.db.query('usage_records', where: where, whereArgs: args.isNotEmpty ? args : null, orderBy: 'created_at DESC');
  }

  Future<void> insertRecord(Map<String, dynamic> row) async {
    await _db.db.insert('usage_records', row);
  }

  Future<List<Map<String, dynamic>>> getAlerts() async {
    return _db.db.query('usage_alerts', where: 'is_enabled = 1');
  }
}
