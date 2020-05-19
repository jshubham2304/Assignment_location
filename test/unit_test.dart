import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:test/test.dart';
import 'package:assignment_location/models/SpeedTimeCriteria.dart' as stc;
void main() {
  test('Test for Speed Time Critreia', () {

    BitmapDescriptor bitmapDescriptor;
    int  time;
    time = stc.SpeedTimeCriteria().getTime(10);

    double d = stc.SpeedTimeCriteria().getColor(10);
    expect(d, BitmapDescriptor.hueAzure);
    expect(time, 60);
  });
}