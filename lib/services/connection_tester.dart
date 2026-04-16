import 'connection_tester_stub.dart'
    if (dart.library.io) 'connection_tester_io.dart';

class ConnectionTestResult {
  const ConnectionTestResult({required this.connected, this.macAddress});

  final bool connected;
  final String? macAddress;
}

abstract class ConnectionTester {
  Future<ConnectionTestResult> testConnection(String ip, int port);
}

ConnectionTester createConnectionTester() => createPlatformConnectionTester();
