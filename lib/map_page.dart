import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();

  MapPage(this.accessKey);
  String accessKey;
}

class _MapPageState extends State<MapPage> {
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kNSK = CameraPosition(
    target: LatLng(35.17176088096857, 136.88817886263607),
    zoom: 14.4746,
  );

  static final CameraPosition _kNagoyajo = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(35.184910766826086, 136.8996468623372),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("イマココ"),
        ),
        body: GoogleMap(
          mapType: MapType.hybrid,
          initialCameraPosition: _kNSK,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _goToNagoyajo,
          label: Text('To the 名古屋城!'),
          icon: Icon(Icons.directions_bike),
        ));
  }

  Future<void> _goToNagoyajo() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kNagoyajo));
  }
}
