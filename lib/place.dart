import 'package:google_place/google_place.dart';

class Place {
  String? name;
  String? photo;
  Location? location;
  Uri? mapURL;

  Place({this.name, this.photo, this.location, this.mapURL});
}
