import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

import '../dao/device_config_dao.dart';
import '../model/device_config.dart';
import '../model/provision_result.dart';
import '../services/connection_tester.dart';
import '../services/esp32_discovery_service.dart';
import '../services/wifi_provision_service.dart';

class ConfigController extends ChangeNotifier {
  ConfigController({
    DeviceConfigDao? dao,
    ConnectionTester? connectionTester,
    WifiProvisionService? wifiProvisionService,
    Esp32DiscoveryService? discoveryService,
  }) : _dao = dao ?? DeviceConfigDao(),
       _connectionTester = connectionTester ?? createConnectionTester(),
       _wifiProvisionService = wifiProvisionService ?? WifiProvisionService(),
       _discoveryService = discoveryService ?? Esp32DiscoveryService();

  final DeviceConfigDao _dao;
  final ConnectionTester _connectionTester;
  final WifiProvisionService _wifiProvisionService;
  final Esp32DiscoveryService _discoveryService;

  bool _carregando = false;
  bool _buscandoLocalizacao = false;
  String? _erroLocalizacao;
  DeviceConfig _config = DeviceConfig(hostname: '', port: 0);

  bool get carregando => _carregando;
  bool get buscandoLocalizacao => _buscandoLocalizacao;
  String? get erroLocalizacao => _erroLocalizacao;
  DeviceConfig get config => _config;

  Future<void> carregar() async {
    _carregando = true;
    notifyListeners();

    _config = await _dao.getConfig();

    _carregando = false;
    notifyListeners();
  }

  Future<bool> salvar({required String hostname, required int port, String? macAddress}) async {
    _carregando = true;
    _erroLocalizacao = null;
    notifyListeners();

    final novoConfig = DeviceConfig(
      hostname: hostname.trim(),
      port: port,
      macAddress: macAddress ?? _config.macAddress,
      connected: false,
      latitude: _config.latitude,
      longitude: _config.longitude,
    );

    final sucesso = await _dao.salvar(novoConfig);
    if (sucesso) {
      _config = novoConfig;
    }

    _carregando = false;
    notifyListeners();
    return sucesso;
  }

  Future<ProvisionResult> provisionDevice({
    required String ssid,
    required String password,
  }) async {
    _carregando = true;
    notifyListeners();

    final macAddress = await _discoveryService.getMacAddress();

    final result = await _wifiProvisionService.provisionDevice(
      ssid: ssid,
      password: password,
    );

    if (result.success) {
      await salvar(
        hostname: 'alarme.local',
        port: 80,
        macAddress: macAddress,
      );
    }

    _carregando = false;
    notifyListeners();
    return ProvisionResult(
      success: result.success,
      message: result.message,
      macAddress: macAddress,
    );
  }

  Future<List<String>> getNetworks() async {
    return _discoveryService.getNetworks();
  }

  Future<bool> atualizarLocalizacaoAtual() async {
    _buscandoLocalizacao = true;
    _erroLocalizacao = null;
    notifyListeners();

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _erroLocalizacao =
            'Serviço de localização desativado. Ative o GPS para continuar.';
        return false;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _erroLocalizacao =
            'Permissão de localização negada. Libere nas configurações do aparelho.';
        return false;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final novoConfig = DeviceConfig(
        id: _config.id,
        hostname: _config.hostname,
        port: _config.port,
        macAddress: _config.macAddress,
        connected: _config.connected,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      final sucesso = await _dao.salvar(novoConfig);
      if (sucesso) {
        _config = novoConfig;
      }

      if (!sucesso) {
        _erroLocalizacao = 'Não foi possível salvar a localização atual.';
      }
      return sucesso;
    } catch (e) {
      if (e is MissingPluginException) {
        _erroLocalizacao =
            'O plugin de localização ainda não foi carregado. Faça um restart completo do app e tente novamente.';
        if (kDebugMode) {
          print('MissingPluginException ao obter localização: $e');
        }
        return false;
      }
      if (kDebugMode) {
        print('Erro ao obter localização: $e');
      }
      _erroLocalizacao = 'Erro ao obter localização atual.';
      return false;
    } finally {
      _buscandoLocalizacao = false;
      notifyListeners();
    }
  }

  Future<bool> testarConexao() async {
    if (!_config.hasEndpoint) {
      return false;
    }

    _carregando = true;
    notifyListeners();

    final resultado = await _connectionTester.testConnection(
      _config.hostname,
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
