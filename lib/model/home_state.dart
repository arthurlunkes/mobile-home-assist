class HomeState {
  static const tableName = 'home_state';
  static const fieldId = 'id';
  static const fieldLightOn = 'light_on';
  static const fieldGateOpen = 'gate_open';
  static const fieldTemperature = 'temperature';
  static const fieldHumidity = 'humidity';
  static const fieldLuminosity = 'luminosity';
  static const fieldUpdatedAt = 'updated_at';

  int id;
  bool lightOn;
  bool gateOpen;
  double? temperature;
  double? humidity;
  double? luminosity;
  DateTime updatedAt;

  HomeState({
    this.id = 1,
    this.lightOn = false,
    this.gateOpen = false,
    this.temperature,
    this.humidity,
    this.luminosity,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      fieldId: id,
      fieldLightOn: lightOn ? 1 : 0,
      fieldGateOpen: gateOpen ? 1 : 0,
      fieldTemperature: temperature,
      fieldHumidity: humidity,
      fieldLuminosity: luminosity,
      fieldUpdatedAt: updatedAt.toIso8601String(),
    };
  }

  factory HomeState.fromMap(Map<String, dynamic> map) {
    return HomeState(
      id: map[fieldId] is int ? map[fieldId] as int : 1,
      lightOn: map[fieldLightOn] == 1,
      gateOpen: map[fieldGateOpen] == 1,
      temperature: (map[fieldTemperature] as num?)?.toDouble(),
      humidity: (map[fieldHumidity] as num?)?.toDouble(),
      luminosity: (map[fieldLuminosity] as num?)?.toDouble(),
      updatedAt: map[fieldUpdatedAt] is String
          ? DateTime.tryParse(map[fieldUpdatedAt] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
