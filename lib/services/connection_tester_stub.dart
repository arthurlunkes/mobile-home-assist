import 'connection_tester.dart';

class _UnsupportedConnectionTester implements ConnectionTester {
  @override
  Future<bool> testConnection(String ip, int port) async {
    return false;
  }
}

ConnectionTester createPlatformConnectionTester() {
  return _UnsupportedConnectionTester();
}
