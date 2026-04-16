import 'dart:convert';
import 'dart:io';

import 'connection_tester.dart';

class _IoConnectionTester implements ConnectionTester {
  @override
  Future<ConnectionTestResult> testConnection(String ip, int port) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 3);

    try {
      final request = await client
          .get(ip, port, '/info')
          .timeout(const Duration(seconds: 3));
      final response = await request.close().timeout(
        const Duration(seconds: 3),
      );
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode != HttpStatus.ok) {
        return const ConnectionTestResult(connected: false);
      }

      final json = jsonDecode(body);
      if (json is! Map<String, dynamic>) {
        return const ConnectionTestResult(connected: false);
      }

      final macAddress = _normalizeMacAddress(json['mac']);
      return ConnectionTestResult(connected: true, macAddress: macAddress);
    } catch (_) {
      return const ConnectionTestResult(connected: false);
    } finally {
      client.close(force: true);
    }
  }

  String? _normalizeMacAddress(Object? value) {
    if (value is! String) {
      return null;
    }

    final macAddress = value.trim();
    return macAddress.isEmpty ? null : macAddress;
  }
}

ConnectionTester createPlatformConnectionTester() {
  return _IoConnectionTester();
}
