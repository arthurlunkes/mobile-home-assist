import 'device_command_service_stub.dart'
    if (dart.library.io) 'device_command_service_io.dart';

abstract class DeviceCommandService {
  Future<bool> setLight({
    required String ip,
    required int port,
    required bool isOn,
  });
}

DeviceCommandService createDeviceCommandService() {
  return createPlatformDeviceCommandService();
}
