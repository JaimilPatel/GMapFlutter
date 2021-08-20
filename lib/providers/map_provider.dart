import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapProvider extends ChangeNotifier {
  LatLng? currentLatLng;

  void updateCurrentLocation(LatLng latLng) {
    currentLatLng = latLng;
    notifyListeners();
  }

  void resetMapProvider() {
    currentLatLng = null;
    notifyListeners();
  }
}
