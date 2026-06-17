import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Esp32DiscoveryService {
  static const String _apIp = '192.168.1.33';

  Future<List<String>> getNetworks() async {
    try {
      final url = Uri.parse('http://$_apIp/scan');
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('networks') && data['networks'] is List) {
          final List<dynamic> networks = data['networks'];
          final Set<String> ssids = {};
          for (var net in networks) {
            if (net is Map && net.containsKey('ssid')) {
              final ssid = net['ssid'].toString().trim();
              if (ssid.isNotEmpty) {
                ssids.add(ssid);
              }
            } else if (net is String) {
              // Backward compatibility
              final ssid = net.trim();
              if (ssid.isNotEmpty) {
                ssids.add(ssid);
              }
            }
          }
          debugPrint('SSIDs processados: ${ssids.toList()}');
          return ssids.toList();
        } else {
          debugPrint('Formato JSON inesperado: $data');
        }
      }
      return [];
    } catch (e, stacktrace) {
      debugPrint('Erro ao buscar redes: $e');
      debugPrint('Stacktrace: $stacktrace');
      return [];
    }
  }

  Future<String?> getMacAddress() async {
    try {
      final url = Uri.parse('http://$_apIp/status');
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('mac')) {
          return data['mac'].toString();
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
