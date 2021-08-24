import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gmap_flutter/providers/info_window_provider.dart';
import 'package:gmap_flutter/providers/map_provider.dart';
import 'package:gmap_flutter/ui/map_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    return MultiProvider(
      providers: [
        ListenableProvider(create: (_) => MapProvider()),
        ListenableProvider(create: (_) => InfoWindowProvider()),
      ],
      child: MaterialApp(
        title: 'GMap Flutter',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MapScreen(),
      ),
    );
  }
}
