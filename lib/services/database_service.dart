import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/movie.dart';

class DatabaseService {
  static const _dbName = 'movie_box.db';
  static const _dbVersion = 1;
  static const _table = 'movie_lists';
  static bool _platformConfigured = false;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _configureDatabaseFactory();
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _dbName);

    _database = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_table (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL,
            movie_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            overview TEXT,
            poster_path TEXT,
            backdrop_path TEXT,
            release_date TEXT,
            rating REAL,
            runtime INTEGER,
            genres TEXT,
            list_type TEXT NOT NULL,
            UNIQUE(user_id, movie_id, list_type)
          )
        ''');
      },
    );

    return _database!;
  }

  void _configureDatabaseFactory() {
    if (_platformConfigured) return;

    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    _platformConfigured = true;
  }

  Future<void> addMovie({
    required Movie movie,
    required String userId,
    required String listType,
  }) async {
    final db = await database;
    await db.insert(
      _table,
      movie.toDbMap(userId: userId, listType: listType),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeMovie({
    required int movieId,
    required String userId,
    required String listType,
  }) async {
    final db = await database;
    await db.delete(
      _table,
      where: 'user_id = ? AND movie_id = ? AND list_type = ?',
      whereArgs: [userId, movieId, listType],
    );
  }

  Future<List<Movie>> getMovies({
    required String userId,
    required String listType,
  }) async {
    final db = await database;
    final rows = await db.query(
      _table,
      where: 'user_id = ? AND list_type = ?',
      whereArgs: [userId, listType],
      orderBy: 'id DESC',
    );
    return rows.map(Movie.fromDb).toList();
  }

  Future<bool> containsMovie({
    required int movieId,
    required String userId,
    required String listType,
  }) async {
    final db = await database;
    final rows = await db.query(
      _table,
      columns: ['id'],
      where: 'user_id = ? AND movie_id = ? AND list_type = ?',
      whereArgs: [userId, movieId, listType],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<void> clearUserData(String userId) async {
    final db = await database;
    await db.delete(_table, where: 'user_id = ?', whereArgs: [userId]);
  }
}
