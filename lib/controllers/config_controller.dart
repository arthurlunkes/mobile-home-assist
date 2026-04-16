import 'package:flutter/foundation.dart';

import '../dao/device_config_dao.dart';
import '../model/device_config.dart';
import '../services/connection_tester.dart';

class ConfigController extends ChangeNotifier {
  ConfigController({DeviceConfigDao? dao, ConnectionTester? connectionTester})
    : _dao = dao ?? DeviceConfigDao(),
      _connectionTester = connectionTester ?? createConnectionTester();

  final DeviceConfigDao _dao;
  final ConnectionTester _connectionTester;

  bool _carregando = false;
  DeviceConfig _config = DeviceConfig(ip: '', port: 0);

  bool get carregando => _carregando;
  DeviceConfig get config => _config;

  Future<void> carregar() async {
    _carregando = true;
    notifyListeners();

    _config = await _dao.getConfig();

    _carregando = false;
    notifyListeners();
  }

  Future<bool> salvar({required String ip, required int port}) async {
    _carregando = true;
    notifyListeners();

    final novoConfig = DeviceConfig(
      ip: ip.trim(),
      port: port,
      macAddress: _config.macAddress,
      connected: false,
    );

    final sucesso = await _dao.salvar(novoConfig);
    if (sucesso) {
      _config = novoConfig;
    }

    _carregando = false;
    notifyListeners();
    return sucesso;
  }

  Future<bool> testarConexao() async {
    if (!_config.hasEndpoint) {
      return false;
    }

    _carregando = true;
    notifyListeners();

    final resultado = await _connectionTester.testConnection(
      _config.ip,
      _config.port,
    );

    _config.connected = resultado.connected;
    _config.macAddress = resultado.macAddress;
    if (!resultado.connected) {
      _config.macAddress = null;
    }
    await _dao.salvar(_config);

    _carregando = false;
    notifyListeners();
    return resultado.connected;
  }
}
