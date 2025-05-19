import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
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
    final dbPath = await getDatabasesPath();
    final paths = path.join(dbPath, fileName);

    return await openDatabase(
      paths,
      version: 2, // Incremented version for migration
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE images (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            filePath TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE templates (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            state TEXT,
            filePath TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Add filePath column to existing templates table
          await db.execute('ALTER TABLE templates ADD COLUMN filePath TEXT');
        }
      },
    );
  }

  Future<void> saveImage(String filePath) async {
    final db = await database;
    await db.insert('images', {'filePath': filePath});
  }

  Future<void> saveTemplate(String name, Map<String, dynamic> state, String filePath) async {
    final db = await database;
    await db.insert('templates', {
      'name': name,
      'state': jsonEncode(state),
      'filePath': filePath,
    });
    print('=========after save template=========$state');
  }

  Future<List<Map<String, dynamic>>> getImages() async {
    final db = await database;
    return await db.query('images');
  }

  Future<List<Map<String, dynamic>>> getTemplates() async {
    final db = await database;
    return await db.query('templates');
  }

  Future<String?> getImagePathById(int id) async {
    final db = await database;
    final result = await db.query('images', where: 'id = ?', whereArgs: [id]);

    if (result.isNotEmpty) {
      return result.first['filePath'] as String?;
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