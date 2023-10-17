//geting user locaiton
import 'dart:convert';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

Future<Position> getLocation() async {
  //service enabled
  bool serviceEnabled;
  LocationPermission locationPermission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();

  if (!serviceEnabled) {
    return Future.error('Service not enabled');
  }

  locationPermission = await Geolocator.checkPermission();

  if (locationPermission == LocationPermission.denied) {
    locationPermission = await Geolocator.requestPermission();

    //if user does not allow permission
    if (locationPermission == LocationPermission.denied) {
      return Future.error('Location permission denied');
    }
  }
  //if permission is denied permanenetly
  if (locationPermission == LocationPermission.deniedForever) {
    return Future.error('Location permission denied permanently');
  }

  Position position = await Geolocator.getCurrentPosition();

  return position;
}

//function for destination onchange
Future<Map<String, dynamic>> getDirection(
    String location, String destination) async {
  //declaration of api key
  String API_KEY = 'AIzaSyB6MiAOm0-aUMg8D0YaQwDAyFHYlstl7cE';
  final response = await http.post(
    Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json?origin=$location&destination=$destination&key=$API_KEY',
    ),
  );
  var jsonResponse = json.decode(response.body);
  print('location $location');
  print('destination $destination');

  var result = {
    'bound_nw': jsonResponse['routes'][0]['bounds']['northeast'],
    'bound_ns': jsonResponse['routes'][0]['bounds']['southwest'],
    'start_location': jsonResponse['routes'][0]['legs'][0]['start_location'],
    'end_location': jsonResponse['routes'][0]['legs'][0]['end_location'],
    'polyline': jsonResponse['routes'][0]['overview_polyline']['points'],
    'polyline_decoded': PolylinePoints().decodePolyline(
        jsonResponse['routes'][0]['overview_polyline']['points']),
  };
  print(result);
  return result;
}
