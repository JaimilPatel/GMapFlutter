import 'dart:ui';

import 'package:fluster/fluster.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';

class MapMarker extends Clusterable {
  String? id;
  LatLng? position;
  BitmapDescriptor? icon;
  VoidCallback? onMarkerTap;

  MapMarker(
      {isCluster = false,
      clusterId,
      pointsSize,
      markerId,
      childMarkerId,
      @required this.id,
      @required this.position,
      this.icon,
      this.onMarkerTap})
      : super(
          isCluster: isCluster,
          clusterId: clusterId,
          pointsSize: pointsSize,
          markerId: markerId,
          childMarkerId: childMarkerId,
          latitude: position?.latitude,
          longitude: position?.longitude,
        );

  /// you can use the [toMarker] method to convert
  /// this to a proper [Marker] that the [GoogleMap] can read.
  Marker toMarker() => Marker(
      markerId: MarkerId(isCluster! ? 'cl_${id!}' : id!),
      position: LatLng(
        position!.latitude,
        position!.longitude,
      ),
      onTap: onMarkerTap,
      icon: icon!);
}
