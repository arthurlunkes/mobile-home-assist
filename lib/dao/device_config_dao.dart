import '../database/database_provider.dart';
import '../model/device_config.dart';
import 'package:sqflite/sqflite.dart';

class DeviceConfigDao {
  final _dbProvider = DatabaseProvider.instance;

  Future<DeviceConfig> getConfig() async {
    final db = await _dbProvider.database;
    final result = await db.query(
      DeviceConfig.tableName,
      columns: [
        DeviceConfig.fieldId,
        DeviceConfig.fieldIp,
        DeviceConfig.fieldPort,
        DeviceConfig.fieldMacAddress,
        DeviceConfig.fieldConnected,
        DeviceConfig.fieldUpdatedAt,
      ],
      where: '${DeviceConfig.fieldId} = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (result.isEmpty) {
      final config = DeviceConfig(ip: '', port: 0);
      await salvar(config);
      return config;
    }

    return DeviceConfig.fromMap(result.first);
  }

  Future<bool> salvar(DeviceConfig config) async {
    final db = await _dbProvider.database;
    config.id = 1;
    config.updatedAt = DateTime.now();
    final count = await db.insert(
      DeviceConfig.tableName,
      config.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return count > 0;
  }
}
