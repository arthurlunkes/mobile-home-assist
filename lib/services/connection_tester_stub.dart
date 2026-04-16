import 'connection_tester.dart';

class _UnsupportedConnectionTester implements ConnectionTester {
  @override
  Future<ConnectionTestResult> testConnection(String ip, int port) async {
    return const ConnectionTestResult(connected: false);
  }
}

ConnectionTester createPlatformConnectionTester() {
  return _UnsupportedConnectionTester();
}
