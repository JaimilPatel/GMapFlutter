import 'dart:io';
import 'dart:ui' as ui;

import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gmap_flutter/apis/api_manager.dart';
import 'package:gmap_flutter/constants/api_constants.dart';
import 'package:gmap_flutter/constants/file_constants.dart';
import 'package:gmap_flutter/constants/key_constants.dart';
import 'package:gmap_flutter/constants/space_constants.dart';
import 'package:gmap_flutter/location/location_manager.dart';
import 'package:gmap_flutter/model/error_model.dart';
import 'package:gmap_flutter/providers/info_window_provider.dart';
import 'package:gmap_flutter/providers/map_provider.dart';
import 'package:gmap_flutter/utils/permission_utils.dart';
import 'package:gmap_flutter/utils/reusable_methods.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'cluster/map_helper.dart';
import 'cluster/map_marker.dart';
import 'infowindow/model/pharmacy_details_model.dart';
import 'infowindow/pharmacy_infowindow.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  String _mapStyle = "";
  late BitmapDescriptor _pharmacyMarker;
  late BitmapDescriptor _farPharmacyMarker;
  Set<Marker> _showMarkers = {};
  List<LatLng> _nearestPharmacies = [];
  int markerSizeMedium = Platform.isIOS ? 65 : 45;
  PharmacyDetailsModel? _pharmacyDetailsModel;
  List<PharmacyDetailsModel> _pharmacies = [];
  GlobalKey? _keyGoogleMap = GlobalKey();
  bool _isCameraReCenter = false;
  int _minClusterZoom = 0;
  int _maxClusterZoom = 19;
  late Fluster<MapMarker> _clusterManager;
  double _currentZoom = 0;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      _initialiseMarkerBitmap(context);
      Provider.of<InfoWindowProvider>(context, listen: false)
          .updateWidth(MediaQuery.of(context).size.width);
      Provider.of<InfoWindowProvider>(context, listen: false)
          .updateHeight(_getMapHeight());
      rootBundle.loadString(FileConstants.mapStyle).then((string) {
        _mapStyle = string;
      });
      _getUserLocation(context);
    });
  }

  _getMapHeight() {
    RenderBox? renderBoxRed =
        _keyGoogleMap?.currentContext?.findRenderObject() as RenderBox?;
    final size = renderBoxRed?.size;
    return size?.height;
  }

  Future<void> _getUserLocation(BuildContext context) async {
    PermissionUtils?.requestPermission(Permission.location, context,
        isOpenSettings: true, permissionGrant: () async {
      await LocationService().fetchCurrentLocation(context, _getPharmacyList,
          updatePosition: updateCameraPosition);
    }, permissionDenied: () {
      Fluttertoast.showToast(
          backgroundColor: Colors.blue,
          msg:
              "Please grant the required permission from settings to access this feature.");
    });
  }

  void updateCameraPosition(CameraPosition cameraPosition) {
    _mapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  _initialiseMarkerBitmap(BuildContext context) async {
    await _bitmapDescriptorFromSvgAsset(
            context, FileConstants.icPharmacyMarker, markerSizeMedium)
        .then((value) => _pharmacyMarker = value);
    await _bitmapDescriptorFromSvgAsset(
            context, FileConstants.icFarPharmacyMarker, markerSizeMedium)
        .then((value) => _farPharmacyMarker = value);
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
        _pharmacies.clear();
        value.data[KeyConstants.resultsKey].forEach((element) {
          _nearestPharmacies.add(LatLng(
              element[KeyConstants.geometryKey][KeyConstants.locationKey]
                      [KeyConstants.latKey]
                  .toDouble(),
              element[KeyConstants.geometryKey][KeyConstants.locationKey]
                      [KeyConstants.lngKey]
                  .toDouble()));
          _pharmacies.add(PharmacyDetailsModel(
              icon: element[KeyConstants.iconKey].toString(),
              iconBackgroundColor:
                  element[KeyConstants.iconBackgroundColorKey].toString(),
              placeId: element[KeyConstants.placeIdKey].toString(),
              name: element[KeyConstants.nameKey].toString(),
              vicinity: element[KeyConstants.vicinityKey].toString(),
              geometry: Geometry(
                  location: Location(
                      lat: element[KeyConstants.geometryKey]
                          [KeyConstants.locationKey][KeyConstants.latKey],
                      lng: element[KeyConstants.geometryKey]
                          [KeyConstants.locationKey][KeyConstants.lngKey]),
                  viewport: ViewPort(
                      northeast: Location(lat: 0.0, lng: 0.0),
                      southwest: Location(lat: 0.0, lng: 0.0))),
              distance: 0.00,
              rating: element[KeyConstants.ratingKey] != null
                  ? element[KeyConstants.ratingKey].toDouble()
                  : 0.00,
              openingHours: element[KeyConstants.openingHoursKey] != null
                  ? OpeningHours(openNow: element[KeyConstants.openingHoursKey][KeyConstants.openNowKey])
                  : OpeningHours(openNow: false)));
        });
      });
      _setMarkerUi(_pharmacies);
    }).catchError((e) {
      if (e is ErrorModel) {
        debugPrint("${e.response}");
      }
    });
  }

  void _setMarkerUi(List<PharmacyDetailsModel> listOfPharmacy) async {
    List<MapMarker> _generatedMapMarkers = [];
    listOfPharmacy.forEach((element) {
      double dis = calculateDistance(
          Provider.of<MapProvider>(context, listen: false)
              .currentLatLng
              ?.latitude,
          Provider.of<MapProvider>(context, listen: false)
              .currentLatLng
              ?.longitude,
          element.geometry.location.lat,
          element.geometry.location.lng);
      element.distance = dis;
      _generatedMapMarkers.add(MapMarker(
          id: element.placeId,
          icon: dis < 0.6 ? _pharmacyMarker : _farPharmacyMarker,
          position: LatLng(
              element.geometry.location.lat, element.geometry.location.lng),
          onMarkerTap: () {
            LatLng latLng;
            setState(() {
              _pharmacyDetailsModel = element;
              latLng = LatLng(
                  element.geometry.location.lat, element.geometry.location.lng);
              Provider.of<InfoWindowProvider>(context, listen: false)
                  .updateVisibility(true);
              _isCameraReCenter = true;
              Provider.of<InfoWindowProvider>(context, listen: false)
                  .updateInfoWindow(context, _mapController, latLng: latLng);
              Provider.of<InfoWindowProvider>(context, listen: false)
                  .rebuildInfoWindow();
            });
          }));
    });
    _clusterManager = await MapHelper.initClusterManager(
      _generatedMapMarkers,
      _minClusterZoom,
      _maxClusterZoom,
    );
    await _updateInfoWindowsWithMarkers(InfoWindowProvider());
  }

  Future<void> _updateInfoWindowsWithMarkers(
      InfoWindowProvider infoWindowProvider,
      [CameraPosition? updatedPosition]) async {
    if (infoWindowProvider.showInfoWindowData) {
      infoWindowProvider.updateInfoWindow(
        context,
        _mapController,
      );
      infoWindowProvider.rebuildInfoWindow();
    }
    if (updatedPosition != null) {
      if (updatedPosition.zoom == _currentZoom) {
        return;
      }
      _currentZoom = updatedPosition.zoom;
    }
    final updatedMarkers = await MapHelper.getClusterMarkers(
        _mapController,
        _clusterManager,
        _currentZoom,
        Color(0xff34B559),
        Colors.white,
        Platform.isAndroid
            ? (SpaceConstants.screenSize.width * 0.15).toInt()
            : (SpaceConstants.screenSize.width * 0.22).toInt(), () {
      _isCameraReCenter = true;
    });
    setState(() {
      _showMarkers
        ..clear()
        ..addAll(updatedMarkers);
    });
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
    SpaceConstants.getScreenSize(context);
    return Scaffold(body: Consumer<InfoWindowProvider>(
        builder: (context, infoWindowProvider, __) {
      return Stack(
        children: [
          GoogleMap(
            myLocationEnabled: true,
            mapToolbarEnabled: false,
            key: _keyGoogleMap,
            markers: _showMarkers,
            initialCameraPosition: _getLocationTarget(),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              _mapController.setMapStyle(_mapStyle);
            },
            onCameraMove: (CameraPosition position) {
              _updateInfoWindowsWithMarkers(infoWindowProvider, position);
              Provider.of<MapProvider>(context, listen: false)
                  .updateCurrentLocation(LatLng(
                      position.target.latitude, position.target.longitude));
            },
            onCameraIdle: () {
              setState(() {
                _isCameraReCenter = false;
              });
            },
            onTap: (LatLng latLng) {
              if (infoWindowProvider.showInfoWindowData) {
                infoWindowProvider.updateVisibility(false);
                infoWindowProvider.rebuildInfoWindow();
              }
            },
          ),
          if (infoWindowProvider.showInfoWindowData)
            Positioned(
                left: infoWindowProvider.leftMarginData,
                bottom: infoWindowProvider.bottomMarginData,
                child: PharmacyInfoWindow(model: _pharmacyDetailsModel!))
        ],
      );
    }));
  }
}
