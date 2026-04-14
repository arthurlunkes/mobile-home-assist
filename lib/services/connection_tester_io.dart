import 'dart:io';

import 'connection_tester.dart';

class _IoConnectionTester implements ConnectionTester {
  @override
  Future<bool> testConnection(String ip, int port) async {
    try {
      final socket = await Socket.connect(
        ip,
        port,
        timeout: const Duration(seconds: 3),
      );
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }
}

ConnectionTester createPlatformConnectionTester() {
  return _IoConnectionTester();
}
