import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();

  MapPage(this.accessKey);
  String accessKey;
}

class _MapPageState extends State<MapPage> {
  String accessKey;
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};

  static final CameraPosition _kNSK = CameraPosition(
    target: LatLng(34.84073380456741, 134.69371382221306),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    accessKey = widget.accessKey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("イマココ"),
        ),
        body: GoogleMap(
          mapType: MapType.hybrid,
          markers: _markers,
          initialCameraPosition: _kNSK,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            await _goToLastLocation(accessKey);
            Marker marker = await _markerLastLocation(widget.accessKey);
            setState(() {
              _markers.add(marker);
            });
          },
          label: Text('更新'),
        ));
  }

  Future<Marker> _markerLastLocation(String accessKey) async {
    LatLng lastLocation = await _getLastLocation(accessKey);
    Marker marker = Marker(
      markerId: MarkerId(accessKey),
      position: lastLocation,
    );

    return marker;
  }

  Future<void> _goToLastLocation(String accessKey) async {
    final GoogleMapController controller = await _controller.future;
    LatLng lastLocation = await _getLastLocation(accessKey);
    CameraPosition position = CameraPosition(
        bearing: 192.8334901395799,
        target: lastLocation,
        tilt: 59.440717697143555,
        zoom: 19.151926040649414);
    controller.animateCamera(CameraUpdate.newCameraPosition(position));
  }

  Future<LatLng> _getLastLocation(String accessKey) async {
    LatLng lastLocation;
    var url = Uri.parse(
        'http://10.0.2.2:3000/api/v1/users/last_location?code=' + accessKey);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      lastLocation = LatLng(jsonResponse['location']['latitude'],
          jsonResponse['location']['longitude']);
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
    return lastLocation;
  }
}
