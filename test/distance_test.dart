import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:water_alert_app/utils/distance.dart';

void main() {
  test('distance to the same point is zero', () {
    const kl = LatLng(3.1390, 101.6869);
    expect(distanceInMetres(kl, kl), 0);
  });

  test('Kuala Lumpur to Penang is about 290 km', () {
    const kl = LatLng(3.1390, 101.6869);
    const penang = LatLng(5.4141, 100.3288);
    expect(distanceInMetres(kl, penang), closeTo(293000, 5000));
  });

  test('distance is symmetric', () {
    const a = LatLng(1.4927, 103.7414);
    const b = LatLng(6.1254, 102.2381);
    expect(distanceInMetres(a, b), distanceInMetres(b, a));
  });
}
