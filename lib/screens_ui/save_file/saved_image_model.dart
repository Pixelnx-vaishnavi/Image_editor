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
      version: 4, // Updated version for schema change
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
            filePath TEXT,
            previewFilePath TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE templates ADD COLUMN filePath TEXT');
        }
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE templates ADD COLUMN filteredFilePath TEXT');
        }
        if (oldVersion < 4) {
          // Rename filteredFilePath to previewFilePath or add new column
          await db.execute('ALTER TABLE templates ADD COLUMN previewFilePath TEXT');
          // Optional: Migrate data from filteredFilePath to previewFilePath
          await db.execute('UPDATE templates SET previewFilePath = filteredFilePath');
        }
      },
    );
  }

  Future<void> saveImage(String filePath) async {
    final db = await database;
    await db.insert('images', {'filePath': filePath});
    print('Saved image to database: $filePath');
  }

  Future<void> saveTemplate(String name, Map<String, dynamic> state, String filePath, String previewFilePath) async {
    final db = await database;
    if (!state.containsKey('imagePath') || !state.containsKey('previewFilePath')) {
      print('Error: state missing imagePath or previewFilePath: $state');
      throw Exception('Invalid state: missing imagePath or previewFilePath');
    }
    final stateJson = jsonEncode(state);
    await db.insert('templates', {
      'name': name,
      'state': stateJson,
      'filePath': filePath,
      'previewFilePath': previewFilePath,
    });
    print('Saved template to database: name=$name, filePath=$filePath, previewFilePath=$previewFilePath, state=$stateJson');
  }

  Future<List<Map<String, dynamic>>> getImages() async {
    final db = await database;
    final images = await db.query('images');
    return images;
  }

  Future<List<Map<String, dynamic>>> getTemplates() async {
    final db = await database;
    final templates = await db.query('templates');
    return templates;
  }

  Future<String?> getImagePathById(int id) async {
    final db = await database;
    final result = await db.query('images', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      final filePath = result.first['filePath'] as String?;
      return filePath;
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
        print('Deleted image file: $filePath');
      }
    }
    await db.delete('images', where: 'id = ?', whereArgs: [id]);
    print('Deleted image from database: id=$id');
  }

  Future<void> deleteTemplate(int id) async {
    final db = await database;
    final result = await db.query('templates', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      final template = result.first;
      final filePath = template['filePath'] as String?;
      final previewFile  = template['previewFilePath'] as String?;

      final filteredFilePath = template['filteredFilePath'] as String?;
      if (filePath != null) {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
          print('Deleted original image file: $filePath');
        }
      }
      if (previewFile != null) {
        final preview = File(previewFile);
        if (await preview.exists()) {
          await preview.delete();
          print('Deleted preview image file: $previewFile');
        }
      }
    }
    await db.delete('templates', where: 'id = ?', whereArgs: [id]);
    print('Deleted template from database: id=$id');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    print('Database closed');
    _database = null;
  }
}


