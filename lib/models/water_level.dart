// lib/models/water_level.dart

class WaterLevel {
  final String stationId;
  final String stationName;
  final String district;
  final String mainBasin;
  final String subBasin;
  final String lastUpdate;
  final String waterLevel;
  final String normal;
  final String alert;
  final String warning;
  final String danger;

  WaterLevel({
    required this.stationId,
    required this.stationName,
    required this.district,
    required this.mainBasin,
    required this.subBasin,
    required this.lastUpdate,
    required this.waterLevel,
    required this.normal,
    required this.alert,
    required this.warning,
    required this.danger,
  });

  factory WaterLevel.fromJson(Map<String, dynamic> json) {
    return WaterLevel(
      stationId: json['station_id'],
      stationName: json['station_name'],
      district: json['district'],
      mainBasin: json['main_basin'],
      subBasin: json['sub_basin'],
      lastUpdate: json['last_update'],
      waterLevel: json['water_level'],
      normal: json['normal'],
      alert: json['alert'],
      warning: json['warning'],
      danger: json['danger'],
    );
  }
}
