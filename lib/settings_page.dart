import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:imakoko/my_shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  static const switch_default_value = false;
  static const reload_key = "reload_key";

  SharedPreferences _prefs;
  bool _reloadValue = switch_default_value;

  @override
  void initState() {
    _initPreferences();
    super.initState();
  }

  void _initPreferences() {
    SharedPreferences.getInstance().then((value) {
      _prefs = value;

      setState(() {
        _reloadValue = _prefs.getBool(reload_key) ?? switch_default_value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("イマココ"),
      ),
      body: Column(
        children: <Widget>[
          SwitchListTile(
            value: _reloadValue,
            title: Text(
              '自動更新',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Cursive',
              ),
            ),
            onChanged: (bool value) {
              switchChanged(value);
            },
          ),
        ],
      ),
    );
  }

  void switchChanged(bool value) {
    setState(() {
      _reloadValue = value;
    });
    _prefs.setBool(reload_key, value);
    MySharedPreferences.instance.setStringValue(reload_key, value.toString());
  }
}
