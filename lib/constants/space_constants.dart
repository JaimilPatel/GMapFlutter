import 'package:flutter/material.dart';

class SpaceConstants {
  static const double spacing3 = 3.0;
  static const double spacing10 = 10.0;
  static const double spacing15 = 15.0;
  static const double spacing20 = 20.0;
  static const double spacing30 = 30.0;
  static const double spacing40 = 40.0;
  static const double spacing50 = 50.0;
  static const double spacing60 = 60.0;
  static Size screenSize = Size(0, 0);
  static getScreenSize(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
  }

  static const double elevation30 = 30.0;
}
