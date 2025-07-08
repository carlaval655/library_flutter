import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDB {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;

    _db = await _initDB('movies.db');
    return _db!;
  }

  static Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  static Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE movies (
        localId INTEGER PRIMARY KEY AUTOINCREMENT,
        remoteId TEXT,
        userId TEXT,
        title TEXT,
        year INTEGER,
        rating REAL,
        review TEXT,
        status TEXT,
        posterPath TEXT
      )
    ''');
  }

  static Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
    }
  }
}