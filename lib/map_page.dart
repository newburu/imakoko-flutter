import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:imakoko/my_shared_preferences.dart';
import 'package:location/location.dart';

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
  Location _locationService = Location();
  // 現在位置
  LocationData _nowLocation;
  // 現在位置の監視状況
  StreamSubscription _locationChangedListen;

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

    // 現在位置の取得
    _getNowLocation();

    // 現在位置の変化を監視
    _locationChangedListen =
        _locationService.onLocationChanged.listen((LocationData result) async {
      setState(() {
        _nowLocation = result;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();

    // 監視を終了
    _locationChangedListen?.cancel();
  }

  // タイマー：Location更新
  void _updateLocationTimer(Timer timer) {
    if (_autoReload) {
      _updateLocation();
    }
  }

  // Location更新
  Future<void> _updateLocation() async {
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
            _goToNowLocation();
          },
          label: Text('更新:' + _autoReload.toString()),
        ));
  }

  // マーカーピン作成
  Future<Marker> _markerLastLocation(String accessKey) async {
    LatLng lastLocation = await _getLastLocation(accessKey);
    Marker marker = Marker(
      markerId: MarkerId(accessKey),
      position: lastLocation,
    );

    return marker;
  }

  // 現在地点へカメラ移動
  Future<void> _goToNowLocation() async {
    final GoogleMapController controller = await _controller.future;
    LatLng nowLocation = LatLng(_nowLocation.latitude, _nowLocation.longitude);
    CameraPosition position = CameraPosition(
        bearing: 192.8334901395799,
        target: nowLocation,
        tilt: 59.440717697143555,
        zoom: 19.151926040649414);
    controller.animateCamera(CameraUpdate.newCameraPosition(position));
  }

  // 最終地点へカメラ移動
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

  // 最終地点を取得
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

  // 現在地取得
  void _getNowLocation() async {
    _nowLocation = await _locationService.getLocation();
  }
}
