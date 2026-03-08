import '../local/database.dart';
import 'package:uuid/uuid.dart';

class EvidenceRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> saveEvidence(String type, String filePath, {required String accountId}) async {
    final db = await _dbHelper.database;
    await db.insert('daily_evidence', {
      'id': const Uuid().v4(),
      'accountId': accountId,
      'type': type, // 'screenshot', 'audio', 'export'
      'filePath': filePath,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getEvidenceByDate(DateTime date, {required String accountId}) async {
    final db = await _dbHelper.database;
    final dateStr = date.toIso8601String().split('T')[0];
    return await db.query(
      'daily_evidence',
      where: 'accountId = ? AND timestamp LIKE ?',
      whereArgs: [accountId, '$dateStr%'],
    );
  }
}