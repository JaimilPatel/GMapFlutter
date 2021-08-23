import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gmap_flutter/constants/size_constants.dart';
import 'package:gmap_flutter/constants/space_constants.dart';

class SquareImage extends StatelessWidget {
  final String image;
  SquareImage({this.image = ""});

  @override
  Widget build(BuildContext context) {
    SpaceConstants.getScreenSize(context);
    return Container(
        child: Padding(
            padding: const EdgeInsets.all(SpaceConstants.spacing10),
            child: Stack(children: <Widget>[
              CachedNetworkImage(
                  fit: BoxFit.cover,
                  width: SpaceConstants.screenSize.width * 0.27,
                  height: SpaceConstants.screenSize.width * 0.27,
                  placeholder: (context, url) => Center(
                      child: SizedBox(
                          height: SizeConstants.size35,
                          width: SizeConstants.size35,
                          child: CircularProgressIndicator(
                              backgroundColor: Colors.blue))),
                  imageUrl: image)
            ])));
  }
}
