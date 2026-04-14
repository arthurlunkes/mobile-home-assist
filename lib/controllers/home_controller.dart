import 'package:flutter/foundation.dart';

import '../dao/home_state_dao.dart';
import '../model/home_state.dart';

class HomeController extends ChangeNotifier {
  HomeController({HomeStateDao? dao}) : _dao = dao ?? HomeStateDao();

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

  String formatarValor(double? value, String unidade) {
    if (value == null) {
      return '-- $unidade';
    }
    return '${value.toStringAsFixed(1)} $unidade';
  }
}
