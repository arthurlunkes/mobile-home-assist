import 'connection_tester_stub.dart'
    if (dart.library.io) 'connection_tester_io.dart';

abstract class ConnectionTester {
  Future<bool> testConnection(String ip, int port);
}

ConnectionTester createConnectionTester() => createPlatformConnectionTester();
