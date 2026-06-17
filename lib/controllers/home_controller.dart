import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../dao/home_state_dao.dart';
import '../dao/device_config_dao.dart';
import '../model/home_state.dart';
import '../model/device_config.dart';
import 'package:geolocator/geolocator.dart';

class HomeController extends ChangeNotifier {
  HomeController({
    HomeStateDao? dao,
    DeviceConfigDao? deviceConfigDao,
  })  : _dao = dao ?? HomeStateDao(),
        _deviceConfigDao = deviceConfigDao ?? DeviceConfigDao();

  final HomeStateDao _dao;
  final DeviceConfigDao _deviceConfigDao;

  bool _carregando = false;
  bool _buscandoLocalizacao = false;
  HomeState _state = HomeState();
  DeviceConfig _deviceConfig = DeviceConfig(hostname: '', port: 0);
  Timer? _pollingTimer;

  bool get carregando => _carregando;
  bool get buscandoLocalizacao => _buscandoLocalizacao;
  HomeState get state => _state;
  DeviceConfig get deviceConfig => _deviceConfig;

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> carregar() async {
    _carregando = true;
    notifyListeners();

    _state = await _dao.getState();
    _deviceConfig = await _deviceConfigDao.getConfig();

    _carregando = false;
    notifyListeners();

    _iniciarPolling();
  }

  void _iniciarPolling() {
    _pollingTimer?.cancel();
    _buscarSensores();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _buscarSensores();
    });
  }

  Future<void> _buscarSensores() async {
    if (!_deviceConfig.hasEndpoint) return;

    final baseUrl = 'http://${_deviceConfig.hostname}:${_deviceConfig.port}';
    bool mudou = false;
    bool respondendo = false;

    // Busca Temperatura
    try {
      final response = await http.get(Uri.parse('$baseUrl/temperature')).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        respondendo = true;
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('temperature')) {
          final temp = (data['temperature'] as num).toDouble();
          if (temp != -999) { // Ignora leitura com erro do ADC
            _state.temperature = temp;
            mudou = true;
          }
        }
      }
    } catch (_) {}

    // Busca Umidade (preparado para quando o endpoint for implementado)
    try {
      final response = await http.get(Uri.parse('$baseUrl/humidity')).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        respondendo = true;
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('humidity')) {
          _state.humidity = (data['humidity'] as num).toDouble();
          mudou = true;
        }
      }
    } catch (_) {}

    // Busca Luminosidade (preparado para quando o endpoint for implementado)
    try {
      final response = await http.get(Uri.parse('$baseUrl/luminosity')).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        respondendo = true;
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('luminosity')) {
          _state.luminosity = (data['luminosity'] as num).toDouble();
          mudou = true;
        }
      }
    } catch (_) {}

    if (_deviceConfig.connected != respondendo) {
      _deviceConfig.connected = respondendo;
      await _deviceConfigDao.salvar(_deviceConfig);
      mudou = true;
    }

    if (mudou) {
      // Salva estado para persistência local
      await _dao.salvar(_state);
      notifyListeners();
    }
  }

  Future<void> forceRefresh() async {
    _carregando = true;
    notifyListeners();
    
    await _buscarSensores();
    
    _carregando = false;
    notifyListeners();
  }

  String formatarValor(double? value, String unidade) {
    if (value == null) {
      return '-- $unidade';
    }
    return '${value.toStringAsFixed(1)} $unidade';
  }

  Future<bool> atualizarLocalizacaoAtual() async {
    _buscandoLocalizacao = true;
    notifyListeners();

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return false;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final novoConfig = DeviceConfig(
        id: _deviceConfig.id,
        hostname: _deviceConfig.hostname,
        port: _deviceConfig.port,
        macAddress: _deviceConfig.macAddress,
        connected: _deviceConfig.connected,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      final sucesso = await _deviceConfigDao.salvar(novoConfig);
      if (sucesso) {
        _deviceConfig = novoConfig;
      }
      return sucesso;
    } catch (e) {
      return false;
    } finally {
      _buscandoLocalizacao = false;
      notifyListeners();
    }
  }
}
