class DeviceConfig {
  static const tableName = 'device_config';
  static const fieldId = 'id';
  static const fieldHostname = 'hostname';
  static const fieldPort = 'port';
  static const fieldName = 'name';
  static const fieldMacAddress = 'mac_address';
  static const fieldConnected = 'connected';
  static const fieldLatitude = 'latitude';
  static const fieldLongitude = 'longitude';
  static const fieldUpdatedAt = 'updated_at';

  int id;
  String hostname;
  int port;
  String name;
  String? macAddress;
  bool connected;
  double? latitude;
  double? longitude;
  DateTime updatedAt;

  DeviceConfig({
    this.id = 1,
    required this.hostname,
    required this.port,
    this.name = 'Meu Dispositivo',
    this.macAddress,
    this.connected = false,
    this.latitude,
    this.longitude,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  bool get hasEndpoint => hostname.trim().isNotEmpty && port > 0;
  bool get isConnected => connected;
  bool get hasLocation => latitude != null && longitude != null;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      fieldId: id,
      fieldHostname: hostname,
      fieldPort: port,
      fieldName: name,
      fieldMacAddress: macAddress,
      fieldConnected: connected ? 1 : 0,
      fieldLatitude: latitude,
      fieldLongitude: longitude,
      fieldUpdatedAt: updatedAt.toIso8601String(),
    };
  }

  factory DeviceConfig.fromMap(Map<String, dynamic> map) {
    return DeviceConfig(
      id: map[fieldId] is int ? map[fieldId] as int : 1,
      hostname: map[fieldHostname] is String ? map[fieldHostname] as String : '',
      port: map[fieldPort] is int ? map[fieldPort] as int : 0,
      name: map[fieldName] is String ? map[fieldName] as String : 'Meu Dispositivo',
      macAddress: map[fieldMacAddress] as String?,
      connected: map[fieldConnected] == 1,
      latitude: _toDouble(map[fieldLatitude]),
      longitude: _toDouble(map[fieldLongitude]),
      updatedAt: map[fieldUpdatedAt] is String
          ? DateTime.tryParse(map[fieldUpdatedAt] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }
}
