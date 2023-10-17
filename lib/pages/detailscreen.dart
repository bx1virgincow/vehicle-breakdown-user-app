import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_map_polyline_new/google_map_polyline_new.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:onroadapp/models/service_model.dart';
import 'package:onroadapp/services/geolocation.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.serviceModel});

  final ServiceModel serviceModel;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  //creating a latlng to display when the map runs
  LatLng? center; //= const LatLng(5.614818, -0.205874);
  // initialization of the mapController.
  late GoogleMapController mapController;
  //polyline
  final Map<PolylineId, Polyline> _polylines = <PolylineId, Polyline>{};

  final GoogleMapPolyline _googleMapPolyline =
      GoogleMapPolyline(apiKey: "AIzaSyB6MiAOm0-aUMg8D0YaQwDAyFHYlstl7cE");

  //Get polyline with Location (latitude and longitude)
  _getPolylinesWithLocation() async {
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
            origin: LatLng(position.latitude, position.longitude),
            destination: LatLng(double.parse(widget.serviceModel.lat),
                double.parse(widget.serviceModel.lng)),
            mode: RouteMode.driving);

    setState(() {
      _polylines.clear();
    });
    _addPolyline(_coordinates);
  }

  int _polylineCount = 1;

  _addPolyline(List<LatLng>? _coordinates) {
    PolylineId id = PolylineId("poly$_polylineCount");
    Polyline polyline = Polyline(
        polylineId: id,
        patterns: <PatternItem>[],
        color: Colors.yellow,
        points: _coordinates!,
        width: 5,
        onTap: () {});

    setState(() {
      _polylines[id] = polyline;
      _polylineCount++;
    });
  }

  //set of markers
  Set<Marker> markers = {};
  //on map created call back
  void onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    await getLocation();

    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(
              double.parse(widget.serviceModel.lat),
              double.parse(widget.serviceModel.lng),
            ),
            zoom: 14),
      ),
    );
    setState(() {
      markers.add(
        Marker(
          markerId: MarkerId(widget.serviceModel.name),
          position: LatLng(
            double.parse(widget.serviceModel.lat),
            double.parse(widget.serviceModel.lng),
          ),
          infoWindow: InfoWindow(
            title: widget.serviceModel.name,
          ),
        ),
      );
    });
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  GoogleMap(
                    zoomControlsEnabled: false,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(double.parse(widget.serviceModel.lat),
                          double.parse(widget.serviceModel.lng)),
                      zoom: 14,
                    ),
                    onMapCreated: onMapCreated,
                    markers: markers.toSet(),
                    polylines: Set<Polyline>.of(_polylines.values),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 15,
                      top: 15,
                    ),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Icon(Icons.chevron_left),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                              child: OutlinedButton(
                                  onPressed: () {
                                    _getPolylinesWithLocation();
                                  },
                                  child: const Text('Get Direction'))),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                launchUrl(
                                  Uri.parse(
                                      'tel://${widget.serviceModel.contact}'),
                                );
                              },
                              child: const Text('Call'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      title:
                          Text('Business Name - ${widget.serviceModel.name}'),
                    ),
                    ListTile(
                      title: Text(
                          'Business Address - ${widget.serviceModel.address}'),
                    ),
                    ListTile(
                      title: Text(
                          'Business Location - ${widget.serviceModel.location}'),
                    ),
                    ListTile(
                      title: Text(
                          'Business Service - ${widget.serviceModel.service}'),
                    ),
                    ListTile(
                      title: Text(
                          'Business Description - ${widget.serviceModel.description}'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
