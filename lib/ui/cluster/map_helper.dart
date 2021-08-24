import 'dart:async';
import 'dart:ui';

import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:gmap_flutter/constants/fontsize_constants.dart';
import 'package:gmap_flutter/utils/reusable_methods.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'map_marker.dart';

class MapHelper {
  /// To get Cluster Markers With Count Of Markers In Specific Region.
  static Future<BitmapDescriptor> _getClusterMarker(
    int clusterSize,
    Color clusterColor,
    Color textColor,
    int width,
  ) async {
    PictureRecorder pictureRecorder = PictureRecorder();
    Canvas canvas = Canvas(pictureRecorder);
    Paint paint = Paint()..color = clusterColor;
    TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    double radius = width / 1.5;
    canvas.drawCircle(
      Offset(radius, radius),
      radius,
      paint,
    );
    textPainter.text = TextSpan(
      text: clusterSize.toString(),
      style: TextStyle(
        fontSize: radius - 3,
        fontWeight: FontSizeConstants.fontWeightBold,
        color: textColor,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(radius - textPainter.width / 2, radius - textPainter.height / 2),
    );
    final image = await pictureRecorder.endRecording().toImage(
          radius.toInt() * 2,
          radius.toInt() * 2,
        );
    final data = await image.toByteData(format: ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  //Initialize Cluster Manager
  static Future<Fluster<MapMarker>> initClusterManager(
    List<MapMarker> markers,
    int minZoom,
    int maxZoom,
  ) async {
    return Fluster<MapMarker>(
      minZoom: minZoom,
      maxZoom: maxZoom,
      radius: 150,
      extent: 2048,
      nodeSize: 64,
      points: markers,
      createCluster: (
        cluster,
        lng,
        lat,
      ) =>
          MapMarker(
        id: cluster.id.toString(),
        position: LatLng(lat, lng),
        isCluster: cluster.isCluster,
        clusterId: cluster.id,
        pointsSize: cluster.pointsSize,
        childMarkerId: cluster.childMarkerId,
      ),
    );
  }

  static Future<List<Marker>> getClusterMarkers(
      GoogleMapController controller,
      Fluster<MapMarker> clusterManager,
      double currentZoom,
      Color clusterColor,
      Color clusterTextColor,
      int clusterWidth,
      Function onClusterClick) {
    if (clusterManager == null) return Future.value([]);
    var latLngList = <LatLng>[];
    return Future.wait(clusterManager.clusters(
        [-180, -85, 180, 85], currentZoom.toInt()).map((mapMarker) async {
      if (mapMarker.isCluster!) {
        mapMarker.onMarkerTap = () {
          onClusterClick();
          clusterManager.points(mapMarker.clusterId!).forEach((e) {
            latLngList.add(LatLng(e.latitude!, e.longitude!));
          });
          controller.animateCamera(
              CameraUpdate.newLatLngBounds(getBounds(latLngList), 50));
        };
        mapMarker.icon = await _getClusterMarker(
          mapMarker.pointsSize!,
          clusterColor,
          clusterTextColor,
          clusterWidth,
        );
      }
      return mapMarker.toMarker();
    }).toList());
  }
}
