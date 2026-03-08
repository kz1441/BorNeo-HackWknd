import '../local/database.dart';

class RecapRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> saveRecap(Map<String, dynamic> recap, {required String accountId}) async {
    final db = await _dbHelper.database;
    await db.insert('transcript_records', {
      'id': recap['id'],
      'accountId': accountId,
      'evidenceId': recap['evidenceId'],
      'rawText': recap['rawText'],
      'parsedJson': recap['parsedJson'], // Store as a JSON string
      'confidence': recap['confidence'],
    });
  }

  Future<List<Map<String, dynamic>>> getRecapsByEvidence(String evidenceId, {required String accountId}) async {
    final db = await _dbHelper.database;
    return await db.query(
      'transcript_records',
      where: 'accountId = ? AND evidenceId = ?',
      whereArgs: [accountId, evidenceId],
    );
  }
}