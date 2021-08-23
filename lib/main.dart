import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lamba',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Lamba'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _width;
  double _height;
  String _lampState = "Lamba durumu";
  bool _lampIcon = false;

  @override
  void initState() {
    _changeLampState("");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      _width = MediaQuery.of(context).size.width;
      _height = MediaQuery.of(context).size.height;
      // _lampIcon = false;
      // _lampState = "Lamba durumu";
    });
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            buttonTemplate("Lambayı Aç", () => _changeLampState("/ledOn")),
            buttonTemplate("Lambayı Kapat", () => _changeLampState("/ledOff"),
                icon: false),
            buttonTemplate(
                "Tersine döndür", () => _changeLampState("/ledToggle"),
                icon: !_lampIcon),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _lampIcon
                    ? Icon(
                        Icons.lightbulb,
                        color: Colors.yellow,
                      )
                    : Icon(
                        Icons.lightbulb_outline,
                      ),
                Text(
                  _lampState,
                  style: TextStyle(fontSize: 25.0),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void _changeLampState(request) async {
    try {
      var url = Uri.parse('http://192.168.1.50' + request);
      String username = 'emre';
      String password = 'Bywzen0lNlH7FiuMTJsE';
      String basicAuth =
          'Basic ' + base64Encode(utf8.encode('$username:$password'));

      var response = await http.get(url, headers: <String, String>{
        'authorization': basicAuth
      }).timeout(Duration(seconds: 2), onTimeout: () {
        setState(() {
          _lampState = "İnternet ya da çipte sorun var";
        });
        return;
      });

      // var doc = parse(response.body);
      RegExp regExp = new RegExp(r"Lamp is (ON|OFF)");
      setState(() {
        var status = regExp.stringMatch(response.body).toString().substring(8);
        if (status == "ON") {
          _lampState = "Lamba açık";
          _lampIcon = true;
        } else if (status == "OFF") {
          _lampState = "Lamba kapalı";
          _lampIcon = false;
        }
      });
    } catch (e) {
      setState(() {
        _lampState = "İnternet ya da çipte sorun var";
      });
    }
  }

  Widget buttonTemplate(text, function,
      {color = Colors.blueAccent, icon = true}) {
    return Container(
      width: _width * 0.65,
      height: _height * 0.07,
      margin: EdgeInsets.all(25),
      child: RaisedButton(
        elevation: 8,
        child: Row(
            // Replace with a Row for horizontal icon + text
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              icon
                  ? Icon(
                      Icons.lightbulb,
                      color: Colors.yellow,
                    )
                  : Icon(
                      Icons.lightbulb_outline,
                    ),
              Text(
                text,
                style: TextStyle(fontSize: 25.0),
              ),
            ]),
        color: color,
        textColor: Colors.white,
        onPressed: function,
      ),
    );
  }
}
