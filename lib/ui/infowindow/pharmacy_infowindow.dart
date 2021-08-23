import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gmap_flutter/constants/file_constants.dart';
import 'package:gmap_flutter/constants/space_constants.dart';
import 'package:gmap_flutter/ui/infowindow/square_image.dart';
import 'package:gmap_flutter/ui/widgets/triangle_shape.dart';

import 'model/pharmacy_details_model.dart';

class PharmacyInfoWindow extends StatefulWidget {
  final PharmacyDetailsModel model;
  PharmacyInfoWindow({required this.model});
  @override
  _PharmacyInfoWindowState createState() => _PharmacyInfoWindowState();
}

class _PharmacyInfoWindowState extends State<PharmacyInfoWindow> {
  @override
  Widget build(BuildContext context) {
    SpaceConstants.getScreenSize(context);
    return Container(
      width: SpaceConstants.screenSize.width,
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {},
        child: Column(
          children: <Widget>[
            Card(
              margin: EdgeInsets.symmetric(horizontal: 30),
              elevation: 30.0,
              child: Column(
                children: <Widget>[
                  Container(
                    color: HexColor(widget.model.iconBackgroundColor),
                    height: 30,
                    child: Row(children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 8),
                        child: Text(
                          "Pharmacy",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 30),
                      SvgPicture.asset(
                        FileConstants.icPharmacyMarker,
                        width: 15,
                        height: 15,
                        color: Colors.white,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(widget.model.distance.toStringAsFixed(2),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.normal)),
                      )
                    ]),
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          children: <Widget>[
                            SquareImage(image: widget.model.icon)
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, right: 10),
                                child: Text(
                                  widget.model.name,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.blue),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, right: 10),
                                child: Text(
                                  widget.model.rating.toStringAsFixed(2),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.blue),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 10, bottom: 10, right: 10),
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        SvgPicture.asset(
                                            FileConstants.icFarPharmacyMarker,
                                            color: widget
                                                    .model.openingHours.openNow
                                                ? Colors.green
                                                : Colors.red,
                                            width: 10,
                                            height: 12),
                                        Expanded(
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            child: Text(
                                              widget.model.vicinity,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            CustomPaint(
                painter: DrawTriangleShape(),
                child: Container(
                  width: 25,
                  height: 30,
                )),
          ],
        ),
      ),
    );
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
