import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:imakoko/my_shared_preferences.dart';
import 'package:location/location.dart';

class OrganizerPage extends StatefulWidget {
  @override
  _OrganizerPageState createState() => _OrganizerPageState();

  final String accessKey;
  OrganizerPage(this.accessKey);
}

class _OrganizerPageState extends State<OrganizerPage> {
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
      _updateLastLocationTimer,
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
  void _updateLastLocationTimer(Timer timer) {
    if (_autoReload) {
      _updateLastLocation(_accessKey);
    }
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
            _goToNowLocation();
            _updateLastLocation(_accessKey);
          },
          label: Text('現在地:' + _autoReload.toString()),
        ));
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

  // 最終地点を更新
  void _updateLastLocation(String accessKey) async {
    var url = Uri.parse(
        'https://imakoko-map.herokuapp.com/api/v1/users/regist_location?code=${accessKey}' +
            '&latitude=${_nowLocation.latitude.toString()}&longitude=${_nowLocation.longitude.toString()}');
    print("URL:" + url.toString());
    var response = await http.get(url);
    if (response.statusCode == 200) {
      print('Request successed with status: ${response.statusCode}.');
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  // 現在地取得
  void _getNowLocation() async {
    _nowLocation = await _locationService.getLocation();
  }
}
