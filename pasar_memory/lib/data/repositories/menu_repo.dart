import 'package:sqflite/sqflite.dart';
import '../../models/menu_item.dart';
import '../local/database.dart';

class MenuRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> upsertMenuItem(MenuItem item, {required String accountId}) async {
    final db = await _dbHelper.database;
    await db.insert(
      'menu_items',
      {
        'id': item.id,
        'accountId': accountId,
        'name': item.name,
        'price': item.price,
        'isActive': item.isActive ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MenuItem>> getAllMenuItems({required String accountId}) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'menu_items',
      where: 'accountId = ?',
      whereArgs: [accountId],
    );

    return List.generate(maps.length, (i) {
      final rawPrice = maps[i]['price'];
      return MenuItem(
        id: maps[i]['id'] as String,
        name: maps[i]['name'] as String,
        price: rawPrice is num ? rawPrice.toDouble() : double.parse(rawPrice.toString()),
        isActive: maps[i]['isActive'] == 1,
      );
    });
  }

  Future<void> toggleMenuItemStatus(String id, bool isActive, {required String accountId}) async {
    final db = await _dbHelper.database;
    await db.update(
      'menu_items',
      {'isActive': isActive ? 1 : 0},
      where: 'id = ? AND accountId = ?',
      whereArgs: [id, accountId],
    );
  }

  Future<void> deleteMenuItem(String id, {required String accountId}) async {
    final db = await _dbHelper.database;
    await db.delete(
      'menu_items',
      where: 'id = ? AND accountId = ?',
      whereArgs: [id, accountId],
    );
  }
}