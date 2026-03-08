import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static const _databaseVersion = 3;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pasar_memory_v2.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
      onOpen: _ensureSchema,
    );
  }

  Future _createDB(Database db, int version) async {
    await _createTables(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    await _createTables(db);
  }

  Future<void> _ensureSchema(Database db) async {
    await _createTables(db);
  }

  Future<void> _createTables(Database db) async {
    const textType = 'TEXT NOT NULL';
    const boolType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';
    const idType = 'TEXT PRIMARY KEY';
    const accountType = "TEXT NOT NULL DEFAULT ''";

    // 1.1.2 Merchant Profile
    await db.execute('''
      CREATE TABLE IF NOT EXISTS merchants (
        id $idType,
        name $textType,
        businessType $textType,
        createdAt $textType
      )
    ''');

    // 1.1.3 Menu Items & Aliases
    await db.execute('''
      CREATE TABLE IF NOT EXISTS menu_items (
        id $idType,
        accountId $accountType,
        name $textType,
        price $realType,
        isActive $boolType
      )
    ''');

    // 1.1.4 Daily Evidence (Screenshots, Audio, Exports)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS daily_evidence (
        id $idType,
        accountId $accountType,
        type $textType, 
        filePath $textType,
        timestamp $textType
      )
    ''');

    // 1.1.5 Extraction Results (OCR & Export Parsing)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS extraction_records (
        id $idType,
        accountId $accountType,
        evidenceId $textType,
        rawText $textType,
        amount $realType,
        referenceNumber $textType,
        confidence $realType,
        status $textType
      )
    ''');

    // 1.1.6 Transcript Records & Parsed Recaps
    await db.execute('''
      CREATE TABLE IF NOT EXISTS transcript_records (
        id $idType,
        accountId $accountType,
        evidenceId $textType,
        rawText $textType,
        parsedJson $textType,
        confidence $realType
      )
    ''');

    // 1.1.7 Daily Ledger
    await db.execute('''
      CREATE TABLE IF NOT EXISTS daily_ledgers (
        id $idType,
        accountId $accountType,
        date $textType,
        totalSales $realType,
        digitalTotal $realType,
        cashEstimate $realType,
        unresolvedCount INTEGER NOT NULL,
        isConfirmed $boolType
      )
    ''');

    // 1.1.8 Correction Records
    await db.execute('''
      CREATE TABLE IF NOT EXISTS correction_records (
        id $idType,
        accountId $accountType,
        dayId $textType,
        fieldName $textType,
        oldValue $textType,
        newValue $textType,
        reason $textType,
        timestamp $textType
      )
    ''');

    // Tap Entries (Quick input during selling)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tap_entries (
        id $idType,
        accountId $accountType,
        menuItemId $textType,
        timestamp $textType,
        amount $realType
      )
    ''');

    await _ensureColumn(db, 'menu_items', 'accountId', accountType);
    await _ensureColumn(db, 'daily_evidence', 'accountId', accountType);
    await _ensureColumn(db, 'extraction_records', 'accountId', accountType);
    await _ensureColumn(db, 'transcript_records', 'accountId', accountType);
    await _ensureColumn(db, 'daily_ledgers', 'accountId', accountType);
    await _ensureColumn(db, 'correction_records', 'accountId', accountType);
    await _ensureColumn(db, 'tap_entries', 'accountId', accountType);
  }

  Future<void> _ensureColumn(Database db, String tableName, String columnName, String declaration) async {
    final tableInfo = await db.rawQuery('PRAGMA table_info($tableName)');
    final hasColumn = tableInfo.any((row) => row['name'] == columnName);
    if (hasColumn) {
      return;
    }

    await db.execute('ALTER TABLE $tableName ADD COLUMN $columnName $declaration');
  }

  Future close() async {
    final db = await instance.database;
    await db.close();
  }
}