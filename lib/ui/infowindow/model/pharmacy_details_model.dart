class PharmacyDetailsModel {
  Geometry geometry;
  String icon;
  String iconBackgroundColor;
  String name;
  String placeId;
  String vicinity;
  double distance;
  double rating;
  OpeningHours openingHours;

  PharmacyDetailsModel(
      {required this.geometry,
      required this.icon,
      required this.iconBackgroundColor,
      required this.name,
      required this.placeId,
      required this.vicinity,
      required this.distance,
      required this.rating,
      required this.openingHours});
}

class Geometry {
  Location location;
  ViewPort viewport;

  Geometry({required this.location, required this.viewport});
}

class Location {
  double lat;
  double lng;

  Location({required this.lat, required this.lng});
}

class ViewPort {
  Location northeast;
  Location southwest;

  ViewPort({required this.northeast, required this.southwest});
}

class OpeningHours {
  bool openNow;

  OpeningHours({required this.openNow});
}

class Photos {
  int height;
  List<String> htmlAttributions;
  String photoReference;
  int width;

  Photos(
      {required this.height,
      required this.htmlAttributions,
      required this.photoReference,
      required this.width});
}

class PlusCode {
  String compoundCode;
  String globalCode;

  PlusCode({required this.compoundCode, required this.globalCode});
}
