import '../local/database.dart';
import 'package:sqflite/sqflite.dart';

class LedgerRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> upsertLedger(Map<String, dynamic> ledger, {required String accountId}) async {
    final db = await _dbHelper.database;
    await db.insert(
      'daily_ledgers',
      {
        ...ledger,
        'accountId': accountId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getLedgerByDate(DateTime date, {required String accountId}) async {
    final db = await _dbHelper.database;
    final dateStr = date.toIso8601String().split('T')[0];
    
    final maps = await db.query(
      'daily_ledgers',
      where: 'accountId = ? AND date = ?',
      whereArgs: [accountId, dateStr],
    );

    if (maps.isNotEmpty) return maps.first;
    return null;
  }

  Future<List<Map<String, dynamic>>> getRecentLedgers({required String accountId, int limit = 14}) async {
    final db = await _dbHelper.database;
    return db.query(
      'daily_ledgers',
      where: 'accountId = ?',
      whereArgs: [accountId],
      orderBy: 'date DESC',
      limit: limit,
    );
  }
}