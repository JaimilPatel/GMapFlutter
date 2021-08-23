import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gmap_flutter/constants/file_constants.dart';
import 'package:gmap_flutter/constants/space_constants.dart';

class CommonRatingWidget extends StatefulWidget {
  final double initRating;
  final Function onRatingTap;
  CommonRatingWidget({this.initRating = 0.0, required this.onRatingTap});

  @override
  _CommonRatingWidgetState createState() => _CommonRatingWidgetState();
}

class _CommonRatingWidgetState extends State<CommonRatingWidget> {
  @override
  Widget build(BuildContext context) {
    return RatingBar(
      initialRating: widget.initRating,
      minRating: 0,
      ignoreGestures: true,
      updateOnDrag: true,
      itemCount: 5,
      itemSize: 12,
      allowHalfRating: true,
      itemPadding: EdgeInsets.symmetric(horizontal: SpaceConstants.spacing3),
      ratingWidget: RatingWidget(
        full: SvgPicture.asset(FileConstants.icFilledStar),
        half: SvgPicture.asset(FileConstants.icEmptyStar),
        empty: SvgPicture.asset(FileConstants.icEmptyStar),
      ),
      onRatingUpdate: (rating) => widget.onRatingTap(rating),
    );
  }
}
