class DeviceConfig {
  static const tableName = 'device_config';
  static const fieldId = 'id';
  static const fieldIp = 'ip';
  static const fieldPort = 'port';
  static const fieldMacAddress = 'mac_address';
  static const fieldConnected = 'connected';
  static const fieldUpdatedAt = 'updated_at';

  int id;
  String ip;
  int port;
  String? macAddress;
  bool connected;
  DateTime updatedAt;

  DeviceConfig({
    this.id = 1,
    required this.ip,
    required this.port,
    this.macAddress,
    this.connected = false,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  bool get hasEndpoint => ip.trim().isNotEmpty && port > 0;
  bool get isConnected => connected;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      fieldId: id,
      fieldIp: ip,
      fieldPort: port,
      fieldMacAddress: macAddress,
      fieldConnected: connected ? 1 : 0,
      fieldUpdatedAt: updatedAt.toIso8601String(),
    };
  }

  factory DeviceConfig.fromMap(Map<String, dynamic> map) {
    return DeviceConfig(
      id: map[fieldId] is int ? map[fieldId] as int : 1,
      ip: map[fieldIp] is String ? map[fieldIp] as String : '',
      port: map[fieldPort] is int ? map[fieldPort] as int : 0,
      macAddress: map[fieldMacAddress] as String?,
      connected: map[fieldConnected] == 1,
      updatedAt: map[fieldUpdatedAt] is String
          ? DateTime.tryParse(map[fieldUpdatedAt] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
