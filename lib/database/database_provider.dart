import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/device_config.dart';
import '../model/home_state.dart';

class DatabaseProvider {
  static const _dbName = 'home_assist.db';
  static const _dbVersion = 5;

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
        ${DeviceConfig.fieldHostname} TEXT NOT NULL,
        ${DeviceConfig.fieldPort} INTEGER NOT NULL,
        ${DeviceConfig.fieldMacAddress} TEXT,
        ${DeviceConfig.fieldConnected} INTEGER NOT NULL DEFAULT 0,
        ${DeviceConfig.fieldLatitude} REAL,
        ${DeviceConfig.fieldLongitude} REAL,
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
      DeviceConfig(hostname: '', port: 0).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await db.insert(
      HomeState.tableName,
      HomeState().toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        ALTER TABLE ${DeviceConfig.tableName}
        ADD COLUMN ${DeviceConfig.fieldConnected} INTEGER NOT NULL DEFAULT 0;
      ''');
    }

    if (oldVersion < 3) {
      await db.execute('''
        ALTER TABLE ${DeviceConfig.tableName}
        ADD COLUMN ${DeviceConfig.fieldLatitude} REAL;
      ''');
      await db.execute('''
        ALTER TABLE ${DeviceConfig.tableName}
        ADD COLUMN ${DeviceConfig.fieldLongitude} REAL;
      ''');
    }

    if (oldVersion < 4) {
      await db.execute('''
        ALTER TABLE ${DeviceConfig.tableName}
        ADD COLUMN ${DeviceConfig.fieldHostname} TEXT NOT NULL DEFAULT '';
      ''');
    }

    if (oldVersion < 5) {
      await db.execute('ALTER TABLE ${DeviceConfig.tableName} RENAME TO device_config_old');
      
      await db.execute('''
        CREATE TABLE ${DeviceConfig.tableName} (
          ${DeviceConfig.fieldId} INTEGER PRIMARY KEY,
          ${DeviceConfig.fieldHostname} TEXT NOT NULL,
          ${DeviceConfig.fieldPort} INTEGER NOT NULL,
          ${DeviceConfig.fieldMacAddress} TEXT,
          ${DeviceConfig.fieldConnected} INTEGER NOT NULL DEFAULT 0,
          ${DeviceConfig.fieldLatitude} REAL,
          ${DeviceConfig.fieldLongitude} REAL,
          ${DeviceConfig.fieldUpdatedAt} TEXT NOT NULL
        );
      ''');

      await db.execute('''
        INSERT INTO ${DeviceConfig.tableName} (
          ${DeviceConfig.fieldId},
          ${DeviceConfig.fieldHostname},
          ${DeviceConfig.fieldPort},
          ${DeviceConfig.fieldMacAddress},
          ${DeviceConfig.fieldConnected},
          ${DeviceConfig.fieldLatitude},
          ${DeviceConfig.fieldLongitude},
          ${DeviceConfig.fieldUpdatedAt}
        )
        SELECT 
          ${DeviceConfig.fieldId},
          ${DeviceConfig.fieldHostname},
          ${DeviceConfig.fieldPort},
          ${DeviceConfig.fieldMacAddress},
          ${DeviceConfig.fieldConnected},
          ${DeviceConfig.fieldLatitude},
          ${DeviceConfig.fieldLongitude},
          ${DeviceConfig.fieldUpdatedAt}
        FROM device_config_old
      ''');

      await db.execute('DROP TABLE device_config_old');
    }
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
