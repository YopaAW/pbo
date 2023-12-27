import 'dart:typed_data';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SQLHelper {
  static Database? _db;
  static const String _dbName = 'mahasiswa.db';

  static Future<Database> get _database async {
    if (_db != null) {
      return _db!;
    }

    _db = await _initDatabase();
    return _db!;
  }

  static Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _dbName);

    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
          CREATE TABLE mahasiswa(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama TEXT,
            nim TEXT,
            alamat TEXT,
            photo BLOB,
            jurusan TEXT
          )
        ''');
    });
  }

  static Future<List<Map<String, dynamic>>> gettbmhs() async {
    final Database db = await _database;
    return await db.query('mahasiswa');
  }
  static Future<void> insertMhs(
      String nama, String nim, String alamat, Uint8List? photo, String jurusan) async {
    final Database db = await _database;
    await db.insert(
      'mahasiswa',
      {
        'nama': nama,
        'nim': nim,
        'alamat': alamat,
        'photo': photo,
        'jurusan': jurusan,
      },
    );
  }

  static Future<void> updateMhs(
      int id, String nama, String nim, String alamat, Uint8List? photo, String jurusan) async {
    final Database db = await _database;
    await db.update(
      'mahasiswa',
      {
        'nama': nama,
        'nim': nim,
        'alamat': alamat,
        'photo': photo,
        'jurusan': jurusan,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> deleteMhs(int id) async {
    final Database db = await _database;
    await db.delete(
      'mahasiswa',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}