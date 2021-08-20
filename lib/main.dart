import 'package:flutter/material.dart';
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
    return MultiProvider(
      providers: [
        ListenableProvider(create: (_) => MapProvider()),
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
