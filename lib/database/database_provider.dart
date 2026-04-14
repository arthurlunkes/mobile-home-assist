import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/device_config.dart';
import '../model/home_state.dart';

class DatabaseProvider {
  static const _dbName = 'home_assist.db';
  static const _dbVersion = 2;

  DatabaseProvider._init();

  static final DatabaseProvider instance = DatabaseProvider._init();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final dbPath = join(databasesPath, _dbName);

    return openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${DeviceConfig.tableName} (
        ${DeviceConfig.fieldId} INTEGER PRIMARY KEY,
        ${DeviceConfig.fieldIp} TEXT NOT NULL,
        ${DeviceConfig.fieldPort} INTEGER NOT NULL,
        ${DeviceConfig.fieldMacAddress} TEXT,
        ${DeviceConfig.fieldConnected} INTEGER NOT NULL DEFAULT 0,
        ${DeviceConfig.fieldUpdatedAt} TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE ${HomeState.tableName} (
        ${HomeState.fieldId} INTEGER PRIMARY KEY,
        ${HomeState.fieldLightOn} INTEGER NOT NULL DEFAULT 0,
        ${HomeState.fieldGateOpen} INTEGER NOT NULL DEFAULT 0,
        ${HomeState.fieldTemperature} REAL,
        ${HomeState.fieldHumidity} REAL,
        ${HomeState.fieldLuminosity} REAL,
        ${HomeState.fieldUpdatedAt} TEXT NOT NULL
      );
    ''');

    await db.insert(
      DeviceConfig.tableName,
      DeviceConfig(ip: '', port: 0).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await db.insert(
      HomeState.tableName,
      HomeState().toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    switch (oldVersion) {
      case 1:
        await db.execute('''
          ALTER TABLE ${DeviceConfig.tableName}
          ADD COLUMN ${DeviceConfig.fieldConnected} INTEGER NOT NULL DEFAULT 0;
        ''');
        break;
    }
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
