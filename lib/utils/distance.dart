import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';

const double _earthRadiusMetres = 6371e3;

double _toRadians(double degrees) => degrees * pi / 180;

/// Great-circle distance between [a] and [b] in metres (haversine formula).
double distanceInMetres(LatLng a, LatLng b) {
  final lat1 = _toRadians(a.latitude);
  final lat2 = _toRadians(b.latitude);
  final dLat = _toRadians(b.latitude - a.latitude);
  final dLng = _toRadians(b.longitude - a.longitude);

  final h = sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2);
  return 2 * _earthRadiusMetres * atan2(sqrt(h), sqrt(1 - h));
}
