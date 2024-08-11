import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'passwor.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE passwords(id INTEGER PRIMARY KEY, name TEXT, password TEXT)',
    );
  }

  Future<void> insertPassword(String name, String password) async {
    final db = await database;
    await db.insert(
      'passwords',
      {'name': name, 'password': password},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getPasswords() async {
    final db = await database;
    return await db.query('passwords');
  }

    Future<void> deletePassword(int id) async {
    final db = await database;
    await db.delete(
      'passwords',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updatePassword(int id, String newPassword) async {
    final db = await database;
    await db.update(
      'passwords',
      {'password': newPassword},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
