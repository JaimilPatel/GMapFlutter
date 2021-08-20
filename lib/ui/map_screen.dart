import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gmap_flutter/apis/api_manager.dart';
import 'package:gmap_flutter/constants/api_constants.dart';
import 'package:gmap_flutter/constants/file_constants.dart';
import 'package:gmap_flutter/constants/key_constants.dart';
import 'package:gmap_flutter/location/location_manager.dart';
import 'package:gmap_flutter/model/error_model.dart';
import 'package:gmap_flutter/providers/map_provider.dart';
import 'package:gmap_flutter/utils/permission_utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
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
                Provider.of<MapProvider>(context, listen: false).currentLatLng!,
                "Your API Key"),
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
    _mapController.animateCamera(
        CameraUpdate.newLatLngBounds(_getBounds(_nearestPharmacies), 50));
  }

  LatLngBounds _getBounds(List<LatLng> markerLocations) {
    var lngs = markerLocations.map<double>((m) => m.longitude).toList();
    var lats = markerLocations.map<double>((m) => m.latitude).toList();

    var topMost = lngs.reduce(max);
    var leftMost = lats.reduce(min);
    var rightMost = lats.reduce(max);
    var bottomMost = lngs.reduce(min);

    var bounds = LatLngBounds(
      northeast: LatLng(rightMost, topMost),
      southwest: LatLng(leftMost, bottomMost),
    );

    return bounds;
  }

  CameraPosition _getLocationTarget() {
    var initialCameraPosition;
    if (Provider.of<MapProvider>(context, listen: false).currentLatLng !=
        null) {
      initialCameraPosition = CameraPosition(
        target: LatLng(
            Provider.of<MapProvider>(context, listen: false)
                .currentLatLng!
                .latitude,
            Provider.of<MapProvider>(context, listen: false)
                .currentLatLng!
                .longitude),
        zoom: 0,
      );
    } else {
      initialCameraPosition = CameraPosition(zoom: 0, target: LatLng(0, 0));
    }
    return initialCameraPosition;
  }

  @override
  Widget build(BuildContext context) {
    _getLocationTarget();
    return Scaffold(
      body: GoogleMap(
        myLocationEnabled: true,
        mapToolbarEnabled: true,
        markers: _showMarkers,
        initialCameraPosition: _getLocationTarget(),
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
          _mapController.setMapStyle(_mapStyle);
        },
        onCameraMove: (CameraPosition position) {
          Provider.of<MapProvider>(context, listen: false)
              .updateCurrentLocation(
                  LatLng(position.target.latitude, position.target.longitude));
        },
        onCameraIdle: () {},
      ),
    );
  }
}
