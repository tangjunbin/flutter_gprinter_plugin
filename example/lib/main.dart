import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:gp_plugin/gp_plugin.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _status_demo = 'Unknown';

  String jsonString = "{" +
      "\"name\": \"模板2\"," +
      "\"size\": {" +
      "\"width\": 50," +
      "\"height\": 30" +
      "}," +
      "\"gap\": 2," +
      "\"count\": 1," +
      "\"items\": [" +
      "{" +
      "\"type\": \"text\"," +
      "\"x\": 40," +
      "\"y\": 20," +
      "\"value\": \"资产编号:\"" +
      "}, {" +
      "\"type\": \"text\"," +
      "\"x\": 40," +
      "\"y\": 55," +
      "\"value\": \"ZC0000001850\"" +
      "}, {" +
      "\"type\": \"text\"," +
      "\"x\": 40," +
      "\"y\": 90," +
      "\"value\": \"资产名称:\"" +
      "}, {" +
      "\"type\": \"text\"," +
      "\"x\": 40," +
      "\"y\": 125," +
      "\"value\": \"不不不\"" +
      "}, {" +
      "\"type\": \"text\"," +
      "\"x\": 40," +
      "\"y\": 160," +
      "\"value\": \"资产分类:\"" +
      "}, {" +
      "\"type\": \"text\"," +
      "\"x\": 40," +
      "\"y\": 195," +
      "\"value\": \"运输设备\"" +
      "}," +
      "{" +
      "\"type\": \"image\"," +
      "\"x\": 0," +
      "\"y\": 0" +
      "}, {" +
      "\"type\": \"QRCode\"," +
      "\"x\": 289," +
      "\"y\": 120," +
      "\"cellwidth\": 3," +
      "\"data\": \"https://wx.eastabc.com/assets/public/index.php/addons/fixedassets#/?no=ZC0000001850\"" +
      "}" +
      "]" +
      "}";

  @override
  void initState() {
    super.initState();
    GpPlugin plugin = GpPlugin();
    initPlatformState();

    GpPlugin.bus.on("connectStatus", (arg) {
      print("========>");
      print(arg['value']);
      setState(() {
        _status_demo = arg['value'];
      });
    });
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await GpPlugin.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    if (!mounted) return;
    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              Text("dexxxxx status: $_status_demo"),
              Text('Running on: $_platformVersion\n'),
              // RaisedButton(
              //   child: Text("打印"),
              //     onPressed: () {
              //
              //       // GpPlugin.sayHello("hello").then((value) => print(value));
              //     }
              // ),

              ShowPrintDialog(
                jsonString: jsonString,
                onPressed: () {
                  print(1111);
                },
                child: Text("打印"),
              ),

              Container(
                height: 300,
                color: Colors.pinkAccent,
                child: GpPrinter(
                  onTextViewCreated: _onTextViewCreated,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _onTextViewCreated(TextViewController controller) {
    controller.setText('蓝牙列表');
  }
}
