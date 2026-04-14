import 'package:flutter/foundation.dart';

import '../dao/home_state_dao.dart';
import '../model/home_state.dart';

class ControlController extends ChangeNotifier {
  ControlController({HomeStateDao? dao}) : _dao = dao ?? HomeStateDao();

  final HomeStateDao _dao;

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
