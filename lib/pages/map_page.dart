import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:onroadapp/models/service_model.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  //declaration of api key
  String API_KEY = '';
  //scaffold key
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  //google map controlle
  late GoogleMapController mapController;
  Completer<GoogleMapController> _controller = Completer();
  //text form field controllers
  final locationController = TextEditingController();
  final destinationController = TextEditingController();
  //
  Set<Marker> markers = {};
  Set<Polyline> polyline = {};

  //
  int polylineCounter = 1;

  //method to set polyline
  void setPolyline(List<PointLatLng> points) {
    final String polylineIdValue = 'polyline_$polylineCounter';
    polylineCounter++;
    polyline.add(
      Polyline(
        polylineId: PolylineId(polylineIdValue),
        width: 5,
        color: Colors.orange,
        points: points
            .map(
              (point) => LatLng(point.latitude, point.longitude),
            )
            .toList(),
      ),
    );
  }

  //dispose off controllers
  @override
  void dispose() {
    mapController.dispose();
    locationController.dispose();
    destinationController.dispose();
    super.dispose();
  }

  //function for destination onchange
  Future<Map<String, dynamic>> getDirection(
      String location, String destination) async {
    final response = await http.post(
      Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=$location&destination=$destination&key=$API_KEY',
      ),
    );
    var jsonResponse = json.decode(response.body);

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

  List<ServiceModel> model = [];
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  // making search request.
  // Future<void> searchReq(String searchValue) async {
  //   FirebaseFirestore.instance
  //       .collection('collectionPath')
  //       .where('service', arrayContainsAny: [searchValue]).g
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        child: Stack(
          children: [
            //building the map interface
            GoogleMap(
              mapToolbarEnabled: false,
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: LatLng(5.614818, -0.205874),
                zoom: 14,
              ),
              polylines: polyline,
              // markers: markers.toSet(),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller); // = controller;
              },
              markers: markers.toSet(),
              onTap: (argument) {
                setMarker(argument);
              },
              zoomControlsEnabled: false,
            ),
            Container(
              decoration: BoxDecoration(color: Colors.orange),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50)),
                          child: Icon(
                            Icons.close,
                          ))),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 4,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: locationController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            fillColor: Colors.white,
                            filled: true,
                            hintText: 'Enter current location',
                          ),
                        ),
                        SizedBox(height: 5),
                        TextFormField(
                          controller: destinationController,
                          // onChanged: (value) {
                          //   searchReq(value);
                          // },
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              fillColor: Colors.white,
                              filled: true,
                              hintText: 'Enter destination'),
                        ),
                        OutlinedButton(
                            onPressed: () async {
                              if (locationController.text == "" &&
                                  destinationController.text == "") {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text('All Fields Are Required'),
                                  ),
                                );
                              } else {
                                var direction = await getDirection(
                                    locationController.text,
                                    destinationController.text);

                                gotoPlace(
                                  direction['start_location']['lat'],
                                  direction['start_location']['lng'],
                                  direction['end_location']['lat'],
                                  direction['end_location']['lng'],
                                );

                                setPolyline(direction['polyline_decoded']);
                              }
                            },
                            child: const Text(
                              'Find',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ))
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> gotoPlace(double start_lat, double start_lng, double end_lat,
      double end_lng) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: LatLng(start_lat, start_lng), zoom: 15),
    ));
    setMarker(LatLng(start_lat, start_lng));
    setMarker(LatLng(end_lat, end_lat));
  }

  void setMarker(LatLng point) {
    setState(() {
      markers.add(
        Marker(
            markerId: MarkerId('marker'),
            position: point,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            )),
      );
    });
  }
}
