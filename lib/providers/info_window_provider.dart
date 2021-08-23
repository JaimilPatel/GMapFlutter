import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class InfoWindowProvider extends ChangeNotifier {
  bool showInfoWindow = false;
  bool _tempHidden = false;
  double? leftMargin;
  double? topMargin;
  double? bottomMargin;
  double _infoWindowWidth = 400;
  double _markerOffset = 0;
  LatLng? location;
  double totalHeight = 0;

  void rebuildInfoWindow() {
    notifyListeners();
  }

  void updateWidth(double width) {
    _infoWindowWidth = width;
  }

  void updateHeight(double updateHeight) {
    if (totalHeight == 0) {
      totalHeight = updateHeight;
    }
  }

  void updateOffset(double offset) {
    _markerOffset = offset;
  }

  void updateVisibility(bool visibility) {
    showInfoWindow = visibility;
  }

  void updateInfoWindow(BuildContext context, GoogleMapController controller,
      {LatLng? latLng}) async {
    if (latLng != null) {
      location = latLng;
    }
    if (location != null) {
      ScreenCoordinate screenCoordinate =
          await controller.getScreenCoordinate(location!);
      double devicePixelRatio =
          Platform.isAndroid ? MediaQuery.of(context).devicePixelRatio : 1.0;
      double left = (screenCoordinate.x.toDouble() / devicePixelRatio) -
          (_infoWindowWidth / 2);
      double top =
          (screenCoordinate.y.toDouble() / devicePixelRatio) - _markerOffset;

      bottomMargin = (totalHeight + 10) -
          (screenCoordinate.y.toDouble() / devicePixelRatio);

      debugPrint("===> margin $bottomMargin total height $totalHeight");
      _tempHidden = false;
      leftMargin = left;
      topMargin = top;
    }
  }

  bool get showInfoWindowData =>
      (showInfoWindow == true && _tempHidden == false) ? true : false;

  double? get leftMarginData => leftMargin;

  double? get bottomMarginData => bottomMargin;

  double? get topMarginData => topMargin;

  void resetInfoWindowProvider() {
    showInfoWindow = false;
    _tempHidden = false;
    leftMargin = 0.0;
    topMargin = 0.0;
    bottomMargin = 0.0;
    _infoWindowWidth = 400;
    _markerOffset = 0;
    location = null;
    totalHeight = 0;
  }
}
