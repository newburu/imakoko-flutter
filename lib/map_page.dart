import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:imakoko/my_shared_preferences.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();

  final String accessKey;
  MapPage(this.accessKey);
}

class _MapPageState extends State<MapPage> {
  String _accessKey;
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};

  bool _autoReload;

  static final CameraPosition _kNSK = CameraPosition(
    target: LatLng(34.84073380456741, 134.69371382221306),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    _accessKey = widget.accessKey;

    MySharedPreferences.instance
        .getStringValue("reload_key")
        .then((value) => setState(() {
              _autoReload = (value == "true");
            }));

    Timer.periodic(
      Duration(seconds: 10),
      _updateLocationTimer,
    );
  }

  void _updateLocationTimer(Timer timer) {
    print(_autoReload);
    if (_autoReload) {
      _updateLocation();
    }
  }

  Future<void> _updateLocation() async {
    await _goToLastLocation(_accessKey);
    Marker marker = await _markerLastLocation(widget.accessKey);
    setState(() {
      _markers.add(marker);
    });
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
          onPressed: () {
            _updateLocation();
          },
          label: Text('更新:' + _autoReload.toString()),
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
        'https://imakoko-map.herokuapp.com/api/v1/users/last_location?code=' +
            accessKey);
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
