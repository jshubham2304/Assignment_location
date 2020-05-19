import 'dart:convert';
import 'dart:math';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:assignment_location/models/SpeedTimeCriteria.dart' as cer;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'models/pin_pill_info.dart';

const double CAMERA_ZOOM = 16;
const double CAMERA_TILT = 80;
const double CAMERA_BEARING = 30;
const LatLng SOURCE_LOCATION = LatLng(42.747932, -71.167889);
const LatLng DEST_LOCATION = LatLng(24.5854, 73.7125);
PointLatLng descLoc = PointLatLng(24.5854, 73.7125);
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: MapPage());
  }
}

class MapPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = Set<Marker>();
  List<LatLng> listPoly = List<LatLng>();
  Set<Polyline> setPolyLine = Set<Polyline>();
  List<LatLng> a = List<LatLng>();
  String googleAPIKey = 'AIzaSyBLFChElHtMsqMHz5bvutgPCNpOsb--dbw';
  BitmapDescriptor sourceIcon;
  LocationData currentLocation;
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints;
  LocationData initialLocation;
  Location location;
  double pinPillPosition = -100;
  PinInformation currentlySelectedPin = PinInformation(
      pinPath: '',
      location: LatLng(0, 0),
      locationName: '',
      labelColor: Colors.grey);
  PinInformation sourcePinInfo;
  PinInformation destinationPinInfo;

  @override
  void initState() {
    super.initState();
    location = new Location();
    polylinePoints = PolylinePoints();
    setSourceIcons();
    location.onLocationChanged.listen((LocationData cLoc) {
      Future.delayed(Duration(
          seconds: cer.SpeedTimeCriteria().getTime(cLoc.speed.toInt())));
      print("Speed : " +
          cLoc.speed.toInt().toString() +
          " :::: Time" +
          cer.SpeedTimeCriteria().getTime(cLoc.speed.toInt()).toString());
      currentLocation = cLoc;
      updatePinOnMap(cLoc.speed.toInt());
    });
    setInitialLocation();
  }

  void setSourceIcons() async {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: 2.0), 'assets/driving_pin.png')
        .then((onValue) {
      sourceIcon = onValue;
    });
  }

  void setInitialLocation() async {
    currentLocation = await location.getLocation();
    initialLocation = currentLocation;

    showPinsOnMap();
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialCameraPosition = CameraPosition(
        zoom: CAMERA_ZOOM,
        tilt: CAMERA_TILT,
        bearing: CAMERA_BEARING,
        target: SOURCE_LOCATION);
    if (currentLocation != null) {
      initialCameraPosition = CameraPosition(
          target: LatLng(currentLocation.latitude, currentLocation.longitude),
          zoom: CAMERA_ZOOM,
          tilt: CAMERA_TILT,
          bearing: CAMERA_BEARING);
    }
    return Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
              myLocationEnabled: true,
              compassEnabled: true,
              tiltGesturesEnabled: false,
              polylines: setPolyLine, // Commmeted the Polyline creation
              markers: _markers,
              mapType: MapType.normal,
              initialCameraPosition: initialCameraPosition,
              onTap: (LatLng loc) {
                pinPillPosition = -100;
              },
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                showPinsOnMap();
              }),
        ],
      ),
    );
  }

  void showPinsOnMap() {
    var pinPosition =
        LatLng(currentLocation.latitude, currentLocation.longitude);
    initialLocation = currentLocation;
    sourcePinInfo = PinInformation(
        locationName: "Start Location",
        location: SOURCE_LOCATION,
        pinPath: "assets/driving_pin.png",
        labelColor: Colors.red);
    _markers.add(Marker(
        markerId: MarkerId('sourcePin'),
        position: pinPosition,
        onTap: () {
          setState(() {
            currentlySelectedPin = sourcePinInfo;
            pinPillPosition = 0;
          });
        },
        icon: sourceIcon));
  }

  void updatePinOnMap(int i) async {
    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
    setState(() async {
      getPolyLine(LatLng(initialLocation.latitude, initialLocation.longitude),
          LatLng(currentLocation.latitude, currentLocation.longitude));
      var pinPosition =
          LatLng(currentLocation.latitude, currentLocation.longitude);
      sourcePinInfo.location = pinPosition;
      double distanceInMeters = await Geolocator().distanceBetween(
          initialLocation.latitude,
          initialLocation.longitude,
          currentLocation.latitude,
          currentLocation.longitude);
      // whenever the distance between two point are greater than 50
      if (distanceInMeters > 50) {
        _markers.add(Marker(
            markerId: MarkerId(
                'sourcePin' + Random.secure().nextInt(1000).toString()),
            onTap: () {
              setState(() {
                currentlySelectedPin = sourcePinInfo;
                pinPillPosition = 0;
              });
            },
            position: pinPosition, // updated position
            icon: BitmapDescriptor.defaultMarkerWithHue(cer.SpeedTimeCriteria()
                .getColor(Random.secure().nextInt(150)))));
      }
    });
  }

  Future<Set<Polyline>> getPolyLine(
      LatLng location, LatLng userlocation) async {
    try {
      var newRes = await http.get(
          "http://www.yournavigation.org/api/1.0/gosmore.php?format=geojson&flat=${location.latitude}&flon=${location.longitude}&tlat=${userlocation.latitude}&tlon=${userlocation.longitude}&v=motorcar&fast=1&layer=cn&geometry=1");

      var jsonBody = json.decode(newRes.body);
      var jsoncoordinates = jsonBody['coordinates'];
      a.clear();
      for (var latlong in jsoncoordinates) {
        a.add(LatLng(latlong[1], latlong[0]));
      }
      setState(() {
        setPolyLine.add(Polyline(polylineId: PolylineId("b"), points: a));
      });

      return setPolyLine;
    } catch (ex) {
      print(ex);
    }
    return Future.error(setPolyLine);
  }
}
