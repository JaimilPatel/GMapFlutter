import 'package:google_maps_flutter/google_maps_flutter.dart';

class ApiConstants {
  static String getPlaces(LatLng input, String googleApiKey) {
    return "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${input.latitude},${input.longitude}&rankby=distance&type=pharmacy&key=$googleApiKey";
  }
}
