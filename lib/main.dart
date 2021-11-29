import 'package:flutter/material.dart';
import 'package:imakoko/map_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'イマココ',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: TopPage(title: 'イマココ'),
    );
  }
}

class TopPage extends StatefulWidget {
  TopPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _TopPageState createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  @override
  Widget build(BuildContext context) {
    String accessKey;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Container(
              width: 200.0,
              child: new TextField(
                enabled: true,
                // 入力数
                maxLength: 10,
                style: TextStyle(color: Colors.black),
                obscureText: false,
                maxLines: 1,
                decoration: const InputDecoration(
                  hintText: '',
                  labelText: 'アクセスキーを入力してください *',
                ),
                onChanged: (value) {
                  accessKey = value;
                },
              ),
            ),
            new ElevatedButton(
              child: Text("現在地参照"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapPage(accessKey),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
