import 'package:flutter/cupertino.dart';
import 'package:attractions_app/model/attraction_model.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  static const _dbName = 'db_attractions_test.db';
  static const _dbVersion = 2;

  DatabaseProvider._init();
  static final DatabaseProvider instance = DatabaseProvider._init();

  Database? _database;

  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final dbPath = '$databasesPath/$_dbName';
    return await openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    //CRIA A COLUMN DATE COMO INT SALVANDO O MillisecondsSinceEpoch DA DATA SALVA
    //PARA TRANSFORMAR NOVAMENTE EM DATETIME UTILIZA-SE DateTime.fromMillisecondsSinceEpoch
    await db.execute(''' 
      CREATE TABLE ${AttractionModel.TABLE_NAME} (
        ${AttractionModel.FIELD_ID} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${AttractionModel.FIELD_TITLE} TEXT NOT NULL,
        ${AttractionModel.FIELD_DESCRIPTION} TEXT NOT NULL,
        ${AttractionModel.FIELD_DIFFERENTIAL} TEXT,
        ${AttractionModel.FIELD_DATE} TEXT NOT NULL);
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    switch (oldVersion) {
      // case 1:
      //   await db.execute('''
      //   ALTER TABLE ${AttractionModel.TABLE_NAME}
      //   ADD ${AttractionModel.NEW_FIELD} INTEGER NOT NULL DEFAULT 0;
      //   ''');
    }
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
    }
  }
}
