import 'dart:io';

import 'device_command_service.dart';

class _IoDeviceCommandService implements DeviceCommandService {
  @override
  Future<bool> setLight({
    required String ip,
    required int port,
    required bool isOn,
  }) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 3);

    try {
      final path = isOn ? '/H' : '/L';
      final request = await client
          .get(ip, port, path)
          .timeout(const Duration(seconds: 3));
      final response = await request.close().timeout(
        const Duration(seconds: 3),
      );
      await response.drain<void>();
      return response.statusCode == HttpStatus.ok;
    } catch (_) {
      return false;
    } finally {
      client.close(force: true);
    }
  }
}

DeviceCommandService createPlatformDeviceCommandService() {
  return _IoDeviceCommandService();
}
