library gp_plugin;

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'event_bus.dart';

part 'gp_printer.dart';
part 'show_print_dialog.dart';
part 'my_dialog_content.dart';
part 'blue_tooth.dart';
///主main
class GpPlugin {

  static const MethodChannel _channel =
      const MethodChannel('com.gh.gpprinter');

  StreamSubscription<dynamic> _eventSubscription;

  static EventBus bus = new EventBus();

  GpPlugin(){
    //初始化事件
    initEvent();
  }

  initEvent(){
    _eventSubscription = _eventChannelFor()
        .receiveBroadcastStream()
        .listen(eventListener,onError: errorListener);
  }

  EventChannel _eventChannelFor(){
    return EventChannel('com.gh.gpprinter/event');
  }

  static String msg = "";
  ///原生传给dart数据
  void eventListener(dynamic event){
    final Map<dynamic,dynamic> map = event;
    print("原生事件返回--》");
    print(map.toString());
    switch(map['event']){
      case 'demoEvent':
        String value = map['value'];
        print('demo event data :$value');
        break;
      case 'myPrintStatus':
        String value = map['status'];
        print('Status=$value');
        break;
      case 'printStatus':
        bus.emit("printStatus", map);
        break;
      case 'connectStatus':
        bus.emit("connectStatus", map);
        break;
      default:
        String value = map['status'];
        print('Status=$value');
    }
  }

  void errorListener(Object obj) {
    final PlatformException e = obj;
    throw e;
  }

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String> sayHello(String message) async {
    final String res = await _channel.invokeMethod('sayHello',<String,dynamic>{'message':message});
    return res;
  }

  static Future<Map<String,dynamic>> OpenPort(String address) async {
    final Map<String,dynamic> res = await _channel.invokeMethod('openPort',<String,dynamic>{'address':address});
    return res;
  }

  //弹出对话框（检测蓝牙列表）
  static Future<List<BlueTooth>> blueToothList() async {
    List<BlueTooth> list = new List<BlueTooth>();
    final Map<String,dynamic> res = new Map<String, dynamic>.from(await _channel.invokeMethod('blueToothList'));
    res.forEach((key, value) {
      list.add(new BlueTooth(key, value));
    });
    return list;
  }
  static Future<Map<String,dynamic>> myPrint(String data) async {
    Map<String,dynamic> res = new Map<String, dynamic>.from(await _channel.invokeMethod('myPrint',<String,dynamic>{'data':data}));
    return res;
  }


}
