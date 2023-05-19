 import 'package:on_audio_query/on_audio_query.dart';
import 'package:sqflite/sqflite.dart';

import 'package:path/path.dart';
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, 'music.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        songId TEXT
      )
    ''');
  }

  Future<List<String>> getFavoriteSongs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('favorites');
    return List.generate(maps.length, (index) => maps[index]['songId'] as String);
  }

  Future<void> addFavoriteSong(String songId) async {
    final db = await database;
    await db.insert('favorites', {'songId': songId});
  }

  Future<void> removeFavoriteSong(String songId) async {
    final db = await database;
    await db.delete('favorites', where: 'songId = ?', whereArgs: [songId]);
  }
}