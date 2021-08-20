import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:gmap_flutter/providers/map_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();

  factory LocationService() {
    return _instance;
  }

  LocationService._internal();
  Location location = Location();

  Future<void> fetchCurrentLocation(BuildContext context, Function mapData,
      {Function? updatePosition}) async {
    LocationData? getLocation;
    await location.changeSettings(accuracy: LocationAccuracy.high);
    try {
      var _hasLocationPermission = await location.hasPermission();
      if (_hasLocationPermission == PermissionStatus.granted) {
        grantedPermissionMethod(context, getLocation, mapData,
            updatePosition: updatePosition);
      } else if (_hasLocationPermission == PermissionStatus.denied) {
        var _permissionGranted = await location.requestPermission();
        if (_permissionGranted == PermissionStatus.granted) {
          grantedPermissionMethod(context, getLocation, mapData,
              updatePosition: updatePosition);
        } else if (_permissionGranted == PermissionStatus.denied) {
          serviceDisabledMethod(context, mapData);
        }
      }
    } on PlatformException catch (e) {
      debugPrint("${e.code}");
    }
  }

  void grantedPermissionMethod(
      BuildContext context, LocationData? locData, Function? mapData,
      {Function? updatePosition}) async {
    var _hasLocationServiceEnabled = await location.serviceEnabled();
    if (_hasLocationServiceEnabled) {
      serviceEnabledMethod(locData, context, mapData!,
          updatePosition: updatePosition);
    } else {
      var _serviceEnabled = await location.requestService();
      if (_serviceEnabled) {
        serviceEnabledMethod(locData, context, mapData!,
            updatePosition: updatePosition);
      } else {
        serviceDisabledMethod(context, mapData!);
      }
    }
  }

  void serviceEnabledMethod(
      LocationData? getLoc, BuildContext context, Function getMapData,
      {Function? updatePosition}) async {
    getLoc = await location.getLocation();
    Provider.of<MapProvider>(context, listen: false).updateCurrentLocation(
        LatLng(getLoc.latitude!.toDouble(), getLoc.longitude!.toDouble()));
    updatePosition!(CameraPosition(
        zoom: 0,
        target:
            LatLng(getLoc.latitude!.toDouble(), getLoc.longitude!.toDouble())));
    if (Provider.of<MapProvider>(context, listen: false).currentLatLng != null)
      getMapData();
  }

  void serviceDisabledMethod(BuildContext context, Function getMapData) {
    debugPrint("Disable Permission");
  }
}
