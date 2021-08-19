import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gmap_flutter/constants/api_constants.dart';
import 'package:gmap_flutter/constants/file_constants.dart';
import 'package:gmap_flutter/constants/key_constants.dart';
import 'package:gmap_flutter/model/error_model.dart';
import 'package:gmap_flutter/utils/permission_utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import 'apis/api_manager.dart';
import 'location/location_manager.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late GoogleMapController _mapController;
  String _mapStyle = "";
  late BitmapDescriptor _pharmacyMarker;
  Set<Marker> _showMarkers = {};
  List<LatLng> _nearestPharmacies = [];
  int markerSizeMedium = Platform.isIOS ? 65 : 45;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      _initialiseMarkerBitmap(context);
      rootBundle.loadString(FileConstants.mapStyle).then((string) {
        _mapStyle = string;
      });
      _getUserLocation(context);
    });
  }

  Future<void> _getUserLocation(BuildContext context) async {
    PermissionUtils?.requestPermission(Permission.location, context,
        isOpenSettings: true, permissionGrant: () async {
      await LocationService().fetchCurrentLocation(context, _getPharmacyList,
          updatePosition: updateCameraPosition);
    }, permissionDenied: () async {});
  }

  void updateCameraPosition(CameraPosition cameraPosition) {
    _mapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  _initialiseMarkerBitmap(BuildContext context) async {
    await _bitmapDescriptorFromSvgAsset(
            context, FileConstants.icPharmacyMarker, markerSizeMedium)
        .then((value) => _pharmacyMarker = value);
  }

  Future<BitmapDescriptor> _bitmapDescriptorFromSvgAsset(
      BuildContext context, String assetName, int width) async {
    var svgString = await DefaultAssetBundle.of(context).loadString(assetName);
    var svgDrawableRoot = await svg.fromSvgString(svgString, "");
    var picture = svgDrawableRoot.toPicture(
        size: Size(width.toDouble(), width.toDouble()));
    var image = await picture.toImage(width, width);
    var bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  void _getPharmacyList() async {
    ApiManager()
        .getPlaces(
            ApiConstants.getPlaces(
                LatLng(22.5489479, 72.9096285), "Your API Key"),
            context)
        .then((value) {
      setState(() {
        _nearestPharmacies.clear();
        value.data[KeyConstants.resultsKey].forEach((element) {
          _nearestPharmacies.add(LatLng(
              element[KeyConstants.geometryKey][KeyConstants.locationKey]
                      [KeyConstants.latKey]
                  .toDouble(),
              element[KeyConstants.geometryKey][KeyConstants.locationKey]
                      [KeyConstants.lngKey]
                  .toDouble()));
        });
      });
      _setMarkerUi();
    }).catchError((e) {
      if (e is ErrorModel) {
        debugPrint("${e.response}");
      }
    });
  }

  void _setMarkerUi() {
    List<Marker> _generatedMapMarkers = [];
    _nearestPharmacies.forEach((element) {
      _generatedMapMarkers.add(Marker(
          markerId: MarkerId(element.hashCode.toString()),
          icon: _pharmacyMarker,
          position: LatLng(element.latitude, element.longitude)));
    });
    setState(() {
      _showMarkers.clear();
      _showMarkers.addAll(_generatedMapMarkers);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GMap Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: GoogleMap(
          myLocationEnabled: true,
          mapToolbarEnabled: true,
          markers: _showMarkers,
          initialCameraPosition: CameraPosition(
            target: LatLng(22.5489479, 72.9096285),
          ),
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
            _mapController.setMapStyle(_mapStyle);
          },
        ),
      ),
    );
  }
}
