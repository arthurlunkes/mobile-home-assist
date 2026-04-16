import 'package:flutter/foundation.dart';

import '../dao/device_config_dao.dart';
import '../dao/home_state_dao.dart';
import '../model/home_state.dart';
import '../services/device_command_service.dart';

class ControlController extends ChangeNotifier {
  ControlController({
    HomeStateDao? dao,
    DeviceConfigDao? deviceConfigDao,
    DeviceCommandService? deviceCommandService,
  }) : _dao = dao ?? HomeStateDao(),
       _deviceConfigDao = deviceConfigDao ?? DeviceConfigDao(),
       _deviceCommandService =
           deviceCommandService ?? createDeviceCommandService();

  final HomeStateDao _dao;
  final DeviceConfigDao _deviceConfigDao;
  final DeviceCommandService _deviceCommandService;

  bool _carregando = false;
  HomeState _state = HomeState();

  bool get carregando => _carregando;
  HomeState get state => _state;

  Future<void> carregar() async {
    _carregando = true;
    notifyListeners();

    _state = await _dao.getState();

    _carregando = false;
    notifyListeners();
  }

  Future<bool> setLuz(bool ligada) async {
    final config = await _deviceConfigDao.getConfig();
    if (!config.hasEndpoint) {
      return false;
    }

    final sucesso = await _deviceCommandService.setLight(
      ip: config.ip,
      port: config.port,
      isOn: ligada,
    );
    if (!sucesso) {
      return false;
    }

    _state.lightOn = ligada;
    notifyListeners();
    return _dao.salvar(_state);
  }

  Future<bool> setPortao(bool aberto) async {
    _state.gateOpen = aberto;
    notifyListeners();
    return _dao.salvar(_state);
  }

  Future<bool> atualizarMetricas({
    double? temperatura,
    double? umidade,
    double? luminosidade,
  }) async {
    _state.temperature = temperatura;
    _state.humidity = umidade;
    _state.luminosity = luminosidade;
    notifyListeners();
    return _dao.salvar(_state);
  }
}
