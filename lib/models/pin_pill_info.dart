import 'dart:ui';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PinInformation {
  String pinPath;
  LatLng location;
  String locationName;
  Color labelColor;

  PinInformation({this.pinPath, this.location, this.locationName, this.labelColor});
}