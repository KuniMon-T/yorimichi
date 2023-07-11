import 'package:google_place/google_place.dart';

class Place {
  String? name;
  String? photo;
  Location? location;
  Uri? mapURL;
  int? distance;
  bool? openNow;
  double? rating;
  int? userRatingTotal;

  Place(
      {this.name,
      this.photo,
      this.location,
      this.mapURL,
      this.distance,
      this.openNow,
      this.rating,
      this.userRatingTotal});
}
