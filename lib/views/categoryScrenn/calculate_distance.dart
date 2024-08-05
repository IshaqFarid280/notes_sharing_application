import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

// Calculate the distance between two LatLng points using the Haversine formula
double calculateDistance(LatLng point1, LatLng point2) {
  const earthRadiusKm = 6371.0;

  double dLat = _degreesToRadians(point2.latitude - point1.latitude);
  double dLon = _degreesToRadians(point2.longitude - point1.longitude);

  double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_degreesToRadians(point1.latitude)) * math.cos(_degreesToRadians(point2.latitude)) *
          math.sin(dLon / 2) * math.sin(dLon / 2);

  double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

  return earthRadiusKm * c;
}

double _degreesToRadians(double degrees) {
  return degrees * math.pi / 180;
}
