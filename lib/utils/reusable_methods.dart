import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';

double calculateDistance(lat1, lon1, lat2, lon2) {
  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 -
      c((lat2 - lat1) * p) / 2 +
      c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a));
}

LatLngBounds getBounds(List<LatLng> markerLocations) {
  List<double> lngs = markerLocations.map<double>((m) => m.longitude).toList();
  List<double> lats = markerLocations.map<double>((m) => m.latitude).toList();

  double topMost = lngs.reduce(max);
  double leftMost = lats.reduce(min);
  double rightMost = lats.reduce(max);
  double bottomMost = lngs.reduce(min);

  LatLngBounds bounds = LatLngBounds(
    northeast: LatLng(rightMost, topMost),
    southwest: LatLng(leftMost, bottomMost),
  );

  return bounds;
}
