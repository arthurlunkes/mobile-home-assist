import 'device_command_service.dart';

class _UnsupportedDeviceCommandService implements DeviceCommandService {
  @override
  Future<bool> setLight({
    required String ip,
    required int port,
    required bool isOn,
  }) async {
    return false;
  }
}

DeviceCommandService createPlatformDeviceCommandService() {
  return _UnsupportedDeviceCommandService();
}
