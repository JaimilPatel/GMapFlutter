import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:gmap_flutter/constants/api_constants.dart';
import 'package:gmap_flutter/constants/file_constants.dart';
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

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance?.addPostFrameCallback((_) {
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

  void _getPharmacyList() async {
    ApiManager()
        .getPlaces(
            ApiConstants.getPlaces(
                LatLng(22.5489479, 72.9096285), "YOUR API KEY"),
            context)
        .then((value) {
      debugPrint("${value.data['results'][0]}");
    }).catchError((e) {
      if (e is ErrorModel) {
        debugPrint("${e.response}");
      }
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

class Place {
  String address;
  String placeId;

  Place(this.address, this.placeId);
}
