import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class PreferencesDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'preferences.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE user_preferences(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL UNIQUE,
            currency TEXT DEFAULT 'IDR',
            timezone TEXT DEFAULT 'Asia/Jakarta',
            updated_at TEXT
          )
        ''');
      },
    );
  }

  static Future<void> setCurrency(int userId, String currency) async {
    final db = await database;

    await db.insert(
      'user_preferences',
      {
        'user_id': userId,
        'currency': currency,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<String> getCurrency(int userId) async {
    final db = await database;
    final result = await db.query(
      'user_preferences',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (result.isNotEmpty) {
      return result.first['currency'] as String;
    }
    return 'IDR';
  }

  static Future<void> setTimezone(int userId, String timezone) async {
    final db = await database;

    await db.insert(
      'user_preferences',
      {
        'user_id': userId,
        'timezone': timezone,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<String> getTimezone(int userId) async {
    final db = await database;
    final result = await db.query(
      'user_preferences',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (result.isNotEmpty) {
      return result.first['timezone'] as String;
    }
    return 'Asia/Jakarta';
  }
}
