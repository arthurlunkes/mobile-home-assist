import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

import '../model/provision_result.dart';

class DeviceProvisionService {
  static const String _apIp = '192.168.4.1';

  Future<ProvisionResult> provisionDevice({
    required String ssid,
    required String password,
  }) async {
    try {
      String? macAddress;
      try {
        final statusUrl = Uri.parse('http://$_apIp/status');
        final statusResponse = await http.get(statusUrl).timeout(const Duration(seconds: 5));
        
        if (statusResponse.statusCode == 200) {
          final statusData = jsonDecode(statusResponse.body);
          macAddress = statusData['mac'];
        }
      } catch (e) {
        // Ignorar falha na leitura do MAC
      }

      final url = Uri.parse('http://$_apIp/wifi');
      final body = jsonEncode({
        'ssid': ssid,
        'password': password,
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return ProvisionResult(
          success: true,
          message: 'Configuração enviada com sucesso. O dispositivo irá reiniciar e conectar à rede.',
          macAddress: macAddress,
        );
      } else {
        return ProvisionResult(
          success: false,
          message: 'Erro ao configurar dispositivo: Código ${response.statusCode}',
        );
      }
    } on TimeoutException {
      return ProvisionResult(
        success: false,
        message: 'Tempo esgotado ao tentar comunicar com o dispositivo. Verifique se está conectado na rede ESP32-SETUP.',
      );
    } catch (e) {
      return ProvisionResult(
        success: false,
        message: 'Erro na comunicação com o dispositivo: $e',
      );
    }
  }
}
