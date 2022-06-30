import 'dart:io';

import 'package:catholic_prayers/model/prayer.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = "PrayersDatabase.db";
  static const _databaseVersion = 1;

  static const table = 'prayers';

  static const columnPid = 'id';
  static const columnOrder = 'p_order';
  static const columnTen = 'title';
  static const columnCen = 'content';
  static const columnTla = 'title_la';
  static const columnCla = 'content_la';
  static const columnTmy = 'title_my';
  static const columnCmy = 'content_my';
  static const columnFavorite = 'favorite';

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database?> get database async {
    if (kIsWeb) return null;
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnPid INTEGER PRIMARY KEY,
            $columnTen TEXT NOT NULL,
            $columnCen TEXT NOT NULL,
            $columnTla TEXT NULL,
            $columnCla TEXT NULL,
            $columnTmy TEXT NULL,
            $columnCmy TEXT NULL,
            $columnOrder INTEGER NULL,
            $columnFavorite INTEGER NOT NULL DEFAULT 0,
            CONSTRAINT $columnPid UNIQUE ($columnPid)
          )
          ''');
  }

  Future<int?> insert(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    if (db != null) {
      return await db.insert(table, row);
    } else {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> queryAllRows() async {
    Database? db = await instance.database;
    if (db != null) {
      return await db.query(
        table,
        orderBy: columnOrder,
      );
    }
    return null;
  }

  Future<List<Map<String, dynamic>>?> queryAllFavoriteRows() async {
    Database? db = await instance.database;
    if (db != null) {
      return await db.query(
        table,
        where: '"$columnFavorite" = ?',
        whereArgs: [1],
        orderBy: columnOrder,
      );
    }
    return null;
  }

  Future<List<Map<String, dynamic>>?> queryRowsByPid(List<int> pIds) async {
    Database? db = await instance.database;
    if (db != null) {
      return await db.query(
        table,
        where: '$columnPid IN (${List.filled(pIds.length, '?').join(',')})',
        whereArgs: pIds,
        orderBy: columnOrder,
      );
    }
    return null;
  }

  Future<int?> queryRowCount() async {
    Database? db = await instance.database;
    if (db != null) {
      return Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM $table'));
    } else {
      return null;
    }
  }

  Future<PrayerModel?> getPrayer(int id) async {
    Database? db = await instance.database;

    if (db != null) {
      List<Map> maps =
          await db.query(table, where: '$columnPid = ?', whereArgs: [id]);
      if (maps.isNotEmpty) {
        return PrayerModel.fromMap(maps.first as Map<String, Object>);
      }
    }
    return null;
  }

  Future<int?> update(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    int id = row[columnPid];
    if (db != null) {
      return await db
          .update(table, row, where: '$columnPid = ?', whereArgs: [id]);
    }
    return null;
  }

  Future<int?> delete(int pId) async {
    Database? db = await instance.database;
    if (db != null) {
      return await db.delete(table, where: '$columnPid = ?', whereArgs: [pId]);
    }
    return null;
  }
}
