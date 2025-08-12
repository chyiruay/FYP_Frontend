import 'package:google_maps_flutter/google_maps_flutter.dart';

class Shelter {
  final String name;
  final double latitude;
  final double longitude;
  final bool available;
  final String address;
  final int capacity;
  final bool hasWater;
  final bool hasFood;
  final bool isAccessible;
  final String? notes;

  Shelter({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.available,
    required this.address,
    required this.capacity,
    required this.hasWater,
    required this.hasFood,
    required this.isAccessible,
    this.notes,
  });

  factory Shelter.fromJson(Map<String, dynamic> json) {
    return Shelter(
      name: json['name'] ?? '',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      available: json['available'] ?? true,
      address: json['address'] ?? '',
      capacity: json['capacity'] ?? 0,
      hasWater: json['has_water'] ?? false,
      hasFood: json['has_food'] ?? false,
      isAccessible: json['is_accessible'] ?? false,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'available': available,
      'address': address,
      'capacity': capacity,
      'has_water': hasWater,
      'has_food': hasFood,
      'is_accessible': isAccessible,
      'notes': notes,
    };
  }

  LatLng get location => LatLng(latitude, longitude);
}
