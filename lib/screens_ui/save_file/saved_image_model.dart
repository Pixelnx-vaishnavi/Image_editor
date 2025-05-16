import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('image_editor.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE images (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      file_path TEXT NOT NULL,
      created_at TEXT NOT NULL
    )
    ''');
  }

  Future<int> saveImage(String filePath) async {
    final db = await database;
    return await db.insert('images', {
      'file_path': filePath,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getImages() async {
    final db = await database;
    return await db.query('images', orderBy: 'created_at DESC');
  }

  Future<String?> getImagePathById(int id) async {
    final db = await database;
    final result = await db.query('images', where: 'id = ?', whereArgs: [id]);

    if (result.isNotEmpty) {
      return result.first['file_path'] as String?;
    }
    return null;
  }

  Future<void> deleteImage(int id) async {
    final db = await database;
    final filePath = await getImagePathById(id);
    if (filePath != null) {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    }
    await db.delete('images', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}