import 'package:flutter/foundation.dart';

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

  bool get carregando => _carregando;
  bool get buscandoLocalizacao => _buscandoLocalizacao;
  HomeState get state => _state;
  DeviceConfig get deviceConfig => _deviceConfig;

  Future<void> carregar() async {
    _carregando = true;
    notifyListeners();

    _state = await _dao.getState();
    _deviceConfig = await _deviceConfigDao.getConfig();

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
