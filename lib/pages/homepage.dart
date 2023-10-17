import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_map_polyline_new/google_map_polyline_new.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:onroadapp/components/drawer_widget.dart';
import 'package:onroadapp/models/service_model.dart';
import 'package:onroadapp/pages/detailscreen.dart';
import 'package:onroadapp/services/geolocation.dart';
import 'package:url_launcher/url_launcher.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key, required service});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  //initialization of the google maps controller
  late GoogleMapController mapController;

  //creating an instance of the firebase auth user
  final user = FirebaseAuth.instance.currentUser;

  String? name;
  String? email;

  //marker instantiations
  Set<Marker> markers = {};

  //creating a latlng to display when the map runs
  final LatLng center = const LatLng(5.614818, -0.205874);
  //instance of the firebase
  final Stream<QuerySnapshot> stream =
      FirebaseFirestore.instance.collection('collectionPath').snapshots();
  //instance of the firebasefirestore
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  //googlemaps controller callback function
  void onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    CollectionReference dbReference =
        firebaseFirestore.collection('collectionPath');
    QuerySnapshot querySnapshot = await dbReference.get();
    print(querySnapshot.docs);
    for (var documentSnapshot in querySnapshot.docs) {
      ServiceModel serviceModel = ServiceModel.fromJson(documentSnapshot);
      //putting the markers on the platform
      setState(() {
        markers.add(Marker(
          markerId: MarkerId(serviceModel.name),
          position: LatLng(
            double.parse(serviceModel.lat),
            double.parse(serviceModel.lng),
          ),
          icon: BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(
              title: serviceModel.name,
              snippet: serviceModel.address,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return DetailScreen(serviceModel: serviceModel);
                }));
              }),
        ));
      });
    }
  }

  //
  var start_lat;
  var start_lng;

  //geolocate
  void userLocation() async {
    Position position = await getLocation();
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(position.latitude, position.longitude), zoom: 14)),
    );
    start_lat = position.latitude;
    start_lng = position.longitude;

    setState(() {
      markers.add(
        Marker(
            markerId: const MarkerId('CurrentLocation'),
            position: LatLng(position.latitude, position.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen)),
      );
    });
  }

  Set<Polyline> polyline = {};
  int polylineCounter = 1;

  int _polylineCount = 1;
  final Map<PolylineId, Polyline> _polylines = <PolylineId, Polyline>{};

  final GoogleMapPolyline _googleMapPolyline =
      GoogleMapPolyline(apiKey: "AIzaSyB6MiAOm0-aUMg8D0YaQwDAyFHYlstl7cE");

  _getPolylinesWithLocation(
      double s_lat, double s_lng, double e_lat, double e_lng) async {
    Position position = await getLocation();
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(position.latitude, position.longitude), zoom: 14)),
    );
    markers.add(Marker(
      markerId: const MarkerId('CurrentLocation'),
      position: LatLng(position.latitude, position.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueAzure,
      ),
    ));
    List<LatLng>? _coordinates =
        await _googleMapPolyline.getCoordinatesWithLocation(
      origin: LatLng(s_lat, s_lng),
      destination: LatLng(e_lat, e_lng),
      mode: RouteMode.driving,
    );

    setState(() {
      _polylines.clear();
    });
    _addPolyline(_coordinates);
  }

  //another method to set polyline
  _addPolyline(List<LatLng>? _coordinates) {
    PolylineId id = PolylineId("poly$_polylineCount");
    Polyline polyline = Polyline(
        polylineId: id,
        patterns: <PatternItem>[],
        color: Colors.blue,
        points: _coordinates!,
        width: 5,
        onTap: () {});

    setState(() {
      _polylines[id] = polyline;
      _polylineCount++;
    });
  }

  //instantiating the scaffold key
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final destinationController = TextEditingController();
  final Stream<QuerySnapshot> collectionStream =
      FirebaseFirestore.instance.collection('collectionPath').snapshots();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getCurrentUserData(user!.uid);
    //getuser location
    userLocation();
    //showing bottom sheet
    showBottomSheetOnLoad();
  }

  void showBottomSheetOnLoad() {
    return WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      scaffoldKey.currentState!.showBottomSheet(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20.0),
            ),
          ), (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.35,
          maxChildSize: 0.5,
          minChildSize: 0.25,
          builder: (BuildContext context, ScrollController scrollController) {
            return SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(20),
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Column(
                        children: [
                          Container(
                            height: 60,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.orange),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextFormField(
                              controller: searchController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                hintText: 'Enter location',
                                prefixIcon: Icon(Icons.place),
                                prefixIconColor: Colors.orange,
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    getLocation().then((value) {
                                      setState(() {
                                        searchController.text =
                                            '${value.latitude} ${value.longitude}';
                                      });
                                    });
                                  },
                                  child: Icon(Icons.my_location),
                                ),
                                suffixIconColor: Colors.orange,
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          Text('Select Service Below'),
                          //view of already systems
                          Container(
                            height: 300,
                            child: StreamBuilder<QuerySnapshot>(
                                stream: collectionStream,
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return Center(
                                      child:
                                          Text('Error connecting to database'),
                                    );
                                  }

                                  if (snapshot.hasData) {
                                    return ListView.builder(
                                        itemCount: snapshot.data!.docs.length,
                                        itemBuilder: (context, index) {
                                          var result =
                                              snapshot.data!.docs[index];
                                          return SingleChildScrollView(
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 5),
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 5),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.orange),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: ListTile(
                                                onTap: () async {
                                                  if (searchController.text ==
                                                      "") {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                            'Location is Required'),
                                                      ),
                                                    );
                                                  } else {
                                                    loadingScreen(context);
                                                    var direction =
                                                        await getDirection(
                                                      searchController.text,
                                                      result['location'],
                                                    );
                                                    print(
                                                        'Start_lat $start_lat');
                                                    print(
                                                        'Start_lng $start_lng');
                                                    print(
                                                        'result lat ${result['lat']}');
                                                    print(
                                                        'result lng ${result['lng']}');
                                                    gotoPlace(
                                                      direction[
                                                              'start_location']
                                                          ['lat'],
                                                      direction[
                                                              'start_location']
                                                          ['lng'],
                                                      double.parse(
                                                          result['lat']),
                                                      double.parse(
                                                          result['lng']),
                                                    );

                                                    // setPolyline(direction[
                                                    //     'polyline_decoded']);

                                                    _getPolylinesWithLocation(
                                                        direction[
                                                                'start_location']
                                                            ['lat'],
                                                        direction[
                                                                'start_location']
                                                            ['lng'],
                                                        double.parse(
                                                            result['lat']),
                                                        double.parse(
                                                            result['lng']));
                                                    Navigator.pop(context);
                                                    // _addPolyline(direction[
                                                    //     'polyline_decoded']);
                                                    Navigator.pop(context);
                                                    scaffoldKey.currentState!
                                                        .showBottomSheet(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        20),
                                                                topRight: Radius
                                                                    .circular(
                                                                        20.0),
                                                              ),
                                                            ), (context) {
                                                      return Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 4,
                                                                horizontal: 12),
                                                        height: 100,
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              child:
                                                                  OutlinedButton(
                                                                style:
                                                                    ButtonStyle(
                                                                  backgroundColor:
                                                                      MaterialStateProperty.all(
                                                                          Colors
                                                                              .orange),
                                                                ),
                                                                onPressed: () {
                                                                  launchUrl(
                                                                    Uri.parse(
                                                                        'tel://${result['contact']}'),
                                                                  );
                                                                },
                                                                child: Text(
                                                                  'Call',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(width: 5),
                                                            Expanded(
                                                              child:
                                                                  OutlinedButton(
                                                                style:
                                                                    ButtonStyle(
                                                                  backgroundColor:
                                                                      MaterialStateProperty.all(
                                                                          Colors
                                                                              .orange),
                                                                ),
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                  showBottomSheetOnLoad();
                                                                },
                                                                child: Text(
                                                                  'Cancel',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      );
                                                    });
                                                  }
                                                },
                                                title: Text(result['name']),
                                              ),
                                            ),
                                          );
                                        });
                                  }
                                  return Container();
                                }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      });
    });
  }

  Future<dynamic> loadingScreen(BuildContext context) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            title: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 1,
                vertical: 4,
              ),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(12.0)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Please wait...'),
                  SizedBox(height: 10),
                  CircularProgressIndicator(),
                ],
              ),
            ),
          );
        });
  }

  List<ServiceModel> model = [];

  // print(RegExp(r"^" "$searchValue").hasMatch(serviceModel.service));
  // Textform field controller.
  TextEditingController searchController = TextEditingController();

  // making search request.
  Future<void> searchReq(String searchValue) async {
    List<ServiceModel> tmp = [];
    // service personnels query.
    CollectionReference servicePersonnels =
        firebaseFirestore.collection('collectionPath');
    QuerySnapshot querySnapshot = await servicePersonnels.get();
    setState(() {
      for (var element in querySnapshot.docs) {
        ServiceModel serviceModel = ServiceModel.fromJson(element);
        if ((serviceModel.service)
            .toLowerCase()
            .contains(searchValue.toLowerCase())) {
          tmp.add(serviceModel);
          model = tmp;

          print(serviceModel);
        }
      }
    });
  }

  //
  Completer<GoogleMapController> _controller = Completer();
//
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

//   @override
  dispose() {
    mapController.dispose(); // you need this
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Location',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapToolbarEnabled: false,
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(target: center, zoom: 14),
            polylines: Set<Polyline>.of(_polylines.values),
            markers: markers.toSet(),
            onMapCreated: onMapCreated,
            zoomControlsEnabled: false,
          ),
          Positioned(
              right: 10,
              bottom: (MediaQuery.of(context).size.height / 2) - 50,
              child: FloatingActionButton(
                onPressed: () {
                  showBottomSheetOnLoad();
                  userLocation();
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.my_location,
                  color: Colors.white,
                ),
              )),
        ],
      ),
      //the drawer
      drawer: DrawerWidget(name: name, email: email),
    );
  }

  // function to make a request to firebase to get user data
  Future getCurrentUserData(final id) async {
    final data = FirebaseFirestore.instance
        .collection('usersCollection')
        .doc(id)
        .get()
        .then(
      (value) {
        name = value['name'];
        email = value['email'];
        return value;
      },
    );
    setState(() {});
    return data;
  }
}

//direction api
//AIzaSyB6MiAOm0-aUMg8D0YaQwDAyFHYlstl7cE
