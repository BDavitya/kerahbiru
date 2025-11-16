import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class FavoriteDatabase {
  static Database? _database;

  // Singleton pattern
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Inisialisasi database
  static Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'favorites.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
  CREATE TABLE favorites(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    worker_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    job_title TEXT NOT NULL,
    rating REAL,
    distance REAL,
    price REAL,
    gender TEXT,
    photo TEXT,
    total_orders INTEGER,
    created_at TEXT,
    UNIQUE(worker_id, user_id)
  )
''');
      },
    );
  }

  static Future<int> addFavorite(
      Map<String, dynamic> worker, int userId) async {
    final db = await database;

    final existing = await db.query(
      'favorites',
      where: 'worker_id = ? AND user_id = ?',
      whereArgs: [worker['id'], userId],
    );

    if (existing.isNotEmpty) {
      return 0;
    }

    return await db.insert('favorites', {
      'worker_id': worker['id'],
      'user_id': userId,
      'name': worker['name'],
      'job_title': worker['job_title'],
      'rating': worker['rating'],
      'distance': worker['distance'],
      'price': worker['price_per_hour'],
      'gender': worker['gender'],
      'photo': worker['photo'],
      'total_orders': worker['total_orders'],
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<int> removeFavorite(int workerId, int userId) async {
    final db = await database;
    return await db.delete(
      'favorites',
      where: 'worker_id = ? AND user_id = ?',
      whereArgs: [workerId, userId],
    );
  }

  static Future<bool> isFavorite(int workerId, int userId) async {
    final db = await database;
    final result = await db.query(
      'favorites',
      where: 'worker_id = ? AND user_id = ?',
      whereArgs: [workerId, userId],
    );
    return result.isNotEmpty;
  }

  static Future<List<Map<String, dynamic>>> getAllFavorites(int userId) async {
    final db = await database;
    return await db.query(
      'favorites',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  // Hapus semua favorit (clear)
  static Future<void> clearAllFavorites() async {
    final db = await database;
    await db.delete('favorites');
  }
}
