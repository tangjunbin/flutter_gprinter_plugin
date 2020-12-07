package com.example.gp_plugin;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Handler;
import android.os.Message;
import android.util.Log;

import androidx.annotation.NonNull;

import com.example.gp_plugin.common.Constant;
import com.example.gp_plugin.common.PrinterCommand;
import com.example.gp_plugin.printsdk.BluetoothSdk;
import com.example.gp_plugin.printsdk.DeviceConnFactoryManager;
import com.example.gp_plugin.printsdk.WuqianPrint;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import static com.example.gp_plugin.printsdk.DeviceConnFactoryManager.ACTION_QUERY_PRINTER_STATE;
import static com.example.gp_plugin.printsdk.DeviceConnFactoryManager.CONN_STATE_CONNECTED;

/** GpPlugin */
public class GpPlugin implements FlutterPlugin, MethodCallHandler{

  private static final String TAG = DeviceConnFactoryManager.class.getSimpleName();
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  /**
   * 上下文
   */
  public static Context applicationContext;

  //事件派发对象
  private EventChannel.EventSink eventSink = null;

  //事件派发流
  private EventChannel.StreamHandler streamHandler = new EventChannel.StreamHandler() {
    private BroadcastReceiver chargingStateChangeReceiver;
    @Override
    public void onListen(Object o, EventChannel.EventSink sink) {

      System.out.println("-------------6----------------");
      System.out.println(sink);
      System.out.println("---------------6--------------");
      eventSink = sink;
      chargingStateChangeReceiver = createChargingStateChangeReceiver(sink);
      IntentFilter filter = new IntentFilter();
      filter.addAction(ACTION_QUERY_PRINTER_STATE);
      applicationContext.registerReceiver(
              chargingStateChangeReceiver, filter);
    }

    @Override
    public void onCancel(Object o) {

      eventSink = null;

      applicationContext.unregisterReceiver(chargingStateChangeReceiver);
      chargingStateChangeReceiver = null;
    }

  };


  private BroadcastReceiver createChargingStateChangeReceiver(final EventChannel.EventSink events) {
    return new BroadcastReceiver() {
      @Override
      public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();
        switch (action){
          case ACTION_QUERY_PRINTER_STATE:
            ConstraintsMap params = new ConstraintsMap();
            params.putString("msg",intent.getStringExtra("state"));
            params.putString("event",intent.getStringExtra("event"));
            params.putInt("code",intent.getIntExtra("code",0));
            params.putInt("close",intent.getIntExtra("close",0));
            events.success(params.toMap());
            break;
        }

//        String scanResult_1 = intent.getStringExtra("code1");
//        String scanResult_2 = intent.getStringExtra("code2");
//        int barcodeType = intent.getIntExtra("SCAN_BARCODE_TYPE", -1); // -1:unknown
//        String scanStatus = intent.getStringExtra("SCAN_STATE");
//        System.out.println(scanResult_1 + "  -  " + scanResult_2 + " - " + barcodeType + " --- " + scanStatus);
//        Map<String,Object> resultMap = new HashMap<>();
//        if ("ok".equals(scanStatus)) {
//          //成功
////          resultMap.put("code1",scanResult_1);
////          resultMap.put("code2",scanResult_2);
////          resultMap.put("SCAN_BARCODE_TYPE",barcodeType);
////          resultMap.put("SCAN_STATE",scanStatus);
////
////          // Map 转 json
////          String json = JSONObject.toJSONString(resultMap);
//          events.success("1324");
//        } else {
//          //失败如超时等
//          events.error("10000", "扫描超时", "请重新扫描");
//        }
      }
    };
  }
  private BluetoothSdk bluetoothSdk = null;
  private WuqianPrint wuqianPrint = null;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {

    channel = new MethodChannel(binding.getBinaryMessenger(), "com.gh.gpprinter");
    channel.setMethodCallHandler(this);

    System.out.println("-------------7----------------");
    System.out.println("---------------7--------------");
    EventChannel eventChannel = new EventChannel(binding.getBinaryMessenger(),"com.gh.gpprinter/event");
    eventChannel.setStreamHandler(streamHandler);

    binding.getPlatformViewRegistry().registerViewFactory("com.gh.gpprinter/textview", new TextViewFactory(binding.getBinaryMessenger()));

    bluetoothSdk = new BluetoothSdk();
    applicationContext = binding.getApplicationContext();
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);

    }  else if (call.method.equals("blueToothList")) {

        result.success(bluetoothSdk.getDeviceList());

    } else if (call.method.equals("sayHello")) {
      String message = call.argument("message");
      System.out.println("--------------------------4-----------------------------");
      System.out.println(eventSink);
      System.out.println("------------------------4-------------------------------");
      if(eventSink != null){
        ConstraintsMap params = new ConstraintsMap();
        params.putString("event","demoEvent");
        params.putString("value","value is 10");
        eventSink.success(params.toMap());
      }
    } else if (call.method.equals("myPrint")) {
      try {
      String data = call.argument("data");
      //检测是否打开
//      String ss = bluetoothSdk.checkBluetooth();
//      //获取已配对蓝牙列表
//      result.success(bluetoothSdk.getDeviceList());
        //连接蓝牙
        if(WuqianPrint.hasDeviceConnFactoryManager(0) && wuqianPrint != null){

          wuqianPrint.sendLabel(data);

          ConstraintsMap params = new ConstraintsMap();
          params.putString("code","0");
          params.putString("msg","打印完成");
          result.success(params.toMap());
        }else {
          ConstraintsMap params = new ConstraintsMap();
          params.putString("code","1");
          params.putString("msg","未连接蓝牙打印机");
          result.success(params.toMap());
        }
      }catch ( Exception e){
//        e.printStackTrace();
        ConstraintsMap params = new ConstraintsMap();
        params.putString("code","1");
        params.putString("msg","未知错误");
        result.success(params.toMap());
//        System.out.println("----------------------------------------------------------");
      }
      //打印
    } else if ("openPort".equals(call.method)){
      openPort(call);
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  /**
   * 连接蓝牙打印机
   * @param call
   */
  public void openPort(MethodCall call) {
      String address = call.argument("address");
      wuqianPrint = new WuqianPrint(address);
  }
}
