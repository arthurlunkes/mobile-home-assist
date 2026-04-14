import 'package:sqflite/sqflite.dart';

import '../database/database_provider.dart';
import '../model/home_state.dart';

class HomeStateDao {
  final _dbProvider = DatabaseProvider.instance;

  Future<HomeState> getState() async {
    final db = await _dbProvider.database;
    final result = await db.query(
      HomeState.tableName,
      columns: [
        HomeState.fieldId,
        HomeState.fieldLightOn,
        HomeState.fieldGateOpen,
        HomeState.fieldTemperature,
        HomeState.fieldHumidity,
        HomeState.fieldLuminosity,
        HomeState.fieldUpdatedAt,
      ],
      where: '${HomeState.fieldId} = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (result.isEmpty) {
      final state = HomeState();
      await salvar(state);
      return state;
    }

    return HomeState.fromMap(result.first);
  }

  Future<bool> salvar(HomeState state) async {
    final db = await _dbProvider.database;
    state.id = 1;
    state.updatedAt = DateTime.now();
    final count = await db.insert(
      HomeState.tableName,
      state.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return count > 0;
  }
}
