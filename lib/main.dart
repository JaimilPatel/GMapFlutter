import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
    rootBundle.loadString("style/map_style.txt").then((string) {
      _mapStyle = string;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
