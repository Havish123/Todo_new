import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DataBaseHelper {
  DataBaseHelper._();
  static final DataBaseHelper instance = DataBaseHelper._();
  static Database _database;

  static final table_name = "todo_list";
  static final coloum = "list";
  static final id = "col_id";
  static final booldata = "isFinish";
  static final db_name = "todo.db";

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, db_name);
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
            CREATE TABLE $table_name(
            $id INTEGER PRIMARY KEY,$coloum TEXT NOT NULL,isFinish BOOLEAN default 1);
            
            ''');
    });
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table_name, row);
  }

  Future<List<Map<String, dynamic>>> viewquery() async {
    Database db = await instance.database;
    
    return await db.query(table_name);
  }

  Future<int> update(Map<String, dynamic> row, int index) async {
   
    Database db = await instance.database;
    return await db.update(table_name, row, where: '$id=?', whereArgs: [index]);
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table_name, where: '$id=?', whereArgs: [id]);
  }
}
