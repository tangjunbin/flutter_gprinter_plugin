package com.example.gp_plugin.printsdk;

import android.app.Dialog;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Log;



import com.example.gp_plugin.common.ThreadPool;
import com.example.gp_plugin.common.Utils;
import com.gprinter.command.EscCommand;
import com.gprinter.command.LabelCommand;


import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;


import java.io.InputStream;
import java.util.Vector;

public class WuqianPrint {
    private final String	TAG	= "WuqianPrint";
    private int		id = 0;
    //蓝牙地址
    private String macaddress_default = "";
    private ThreadPool threadPool;
    private Context context;
    public static Dialog mDialog;
    /**
     * 打印类型
     */
    public enum PrintType {
        /**
         * 标签
         */
        LABEL,
        /**
         * 默认(修改主题）
         */
        DEFAULT_Custom,
        /**
         * 远程
         */
        REMOTE,
        /**
         * 自定义
         */
        CUSTOM,
    }

    private void initReceiver(){
//        IntentFilter filter = new IntentFilter( Constant.ACTION_USB_PERMISSION );
//        filter.addAction( ACTION_USB_DEVICE_DETACHED );
//        filter.addAction( DeviceConnFactoryManager.ACTION_QUERY_PRINTER_STATE );
//        filter.addAction( DeviceConnFactoryManager.ACTION_CONN_STATE );
//        filter.addAction( ACTION_USB_DEVICE_ATTACHED );
//        MyApp.getContext().registerReceiver( receiver, filter );
    }
    public WuqianPrint(){
        initReceiver();
        connBlueTooth();
    }
    public WuqianPrint(String macaddress){
        initReceiver();
        connBlueTooth(macaddress);
    }
    public WuqianPrint(String macaddress,Context contextcc){
        initReceiver();
        context = contextcc;
        connBlueTooth(macaddress);
    }
    /**
     * 打印标签
     */
    public void sendLabel(String params, PrintInterfaceCallback callbackJsWeb) throws JSONException {

        LabelCommand tsc = new LabelCommand();
        try {
            JSONObject paramsJson = new JSONObject(params);
            JSONObject size = paramsJson.getJSONObject("size");
            Integer width = size.getInt("width");
            Integer height = size.getInt("height");
            Integer gap = paramsJson.getInt("gap");

            JSONArray items = paramsJson.getJSONArray("items");

            for(int i=0;i<items.length();i++){
                JSONArray itemList = (JSONArray)items.get(i);

                if (width>0 && height>0) {
                    tsc.addSize( width, height );
                }
                //response.send(size);
                //response.send("size:"+width+"xxxxx"+height);

                tsc.addGap( gap );
                tsc.addDirection( LabelCommand.DIRECTION.FORWARD, LabelCommand.MIRROR.NORMAL );
                tsc.addQueryPrinterStatus( LabelCommand.RESPONSE_MODE.ON );
                tsc.addReference( 0, 0 );
                tsc.addTear( EscCommand.ENABLE.ON );
                tsc.addCls();

                for(int k=0;k<itemList.length();k++){
                    JSONObject itemLabel = (JSONObject)itemList.get(k);
                    Integer x = itemLabel.getInt("x");
                    Integer y = itemLabel.getInt("y");
                    String type = itemLabel.getString("type");
                    //
                    if(type.equalsIgnoreCase("text")){
                        String textC = itemLabel.getString("value");

                        tsc.addText( x, y, LabelCommand.FONTTYPE.SIMPLIFIED_CHINESE,
                                LabelCommand.ROTATION.ROTATION_0,
                                LabelCommand.FONTMUL.MUL_1,
                                LabelCommand.FONTMUL.MUL_1,
                                textC
                        );
                    }
                    if(type.equalsIgnoreCase("image")){

                        Bitmap b = BitmapFactory.decodeStream(getClass().getResourceAsStream("/res/drawable/printlog.bmp"));
                        tsc.addBitmap( x, y, LabelCommand.BITMAP_MODE.OVERWRITE, 80, b );
                    }
                    if(type.equalsIgnoreCase("QRCode")){

                        Integer celW = itemLabel.getInt("cellwidth");
                        String data = itemLabel.getString("data");
                        tsc.addQRCode( x, y, LabelCommand.EEC.LEVEL_L, celW, LabelCommand.ROTATION.ROTATION_0, data );
                    }
                    if(type.equalsIgnoreCase("Barcode")){
                        Integer heigth = itemLabel.getInt("heigth");
                        String content = itemLabel.getString("content");
                        tsc.add1DBarcode( x, y, LabelCommand.BARCODETYPE.CODE128, heigth, LabelCommand.READABEL.EANBEL, LabelCommand.ROTATION.ROTATION_0, content );
                    }
                }

            }

        }catch (Exception e){
            callbackJsWeb.webprintDoc(44,"Json 解析异常");
//            XToastUtils.toast("Json 解析异常", Toast.LENGTH_LONG);
            Log.e("error","Json 解析异常");
        }


        tsc.addPrint( 1, 1 );

        tsc.addSound( 2, 100 );
        tsc.addCashdrwer( LabelCommand.FOOT.F5, 255, 255 );
        Vector<Byte> datas = tsc.getCommand();

        if ( DeviceConnFactoryManager.getDeviceConnFactoryManagers()[id] == null )
        {
            callbackJsWeb.webprintDoc(45,"sendLabel: 打印机未连接");
//            XToastUtils.toast("sendLabel: 打印机未连接", Toast.LENGTH_LONG);
            Log.d(TAG, "sendLabel: 打印机未连接");
            return;
        }
        DeviceConnFactoryManager.getDeviceConnFactoryManagers()[id].sendDataImmediately( datas );
    }

    /**
     * 简化打印标签
     */
    public void sendLabel(String params) throws JSONException {

        LabelCommand tsc = new LabelCommand();
        try {
            JSONObject paramsJson = new JSONObject(params);
            JSONObject size = paramsJson.getJSONObject("size");
            Integer width = size.getInt("width");
            Integer height = size.getInt("height");
            Integer gap = paramsJson.getInt("gap");

            JSONArray items = paramsJson.getJSONArray("items");

//            for(int i=0;i<items.length();i++){
//                JSONArray itemList = (JSONArray)items.get(i);
            JSONArray itemList = items;
                if (width>0 && height>0) {
                    tsc.addSize( width, height );
                }
                //response.send(size);
                //response.send("size:"+width+"xxxxx"+height);

                tsc.addGap( gap );
                tsc.addDirection( LabelCommand.DIRECTION.FORWARD, LabelCommand.MIRROR.NORMAL );
                tsc.addQueryPrinterStatus( LabelCommand.RESPONSE_MODE.ON );
                tsc.addReference( 0, 0 );
                tsc.addTear( EscCommand.ENABLE.ON );
                tsc.addCls();

                for(int k=0;k<itemList.length();k++){
                    JSONObject itemLabel = (JSONObject)itemList.get(k);
                    Integer x = itemLabel.getInt("x");
                    Integer y = itemLabel.getInt("y");
                    String type = itemLabel.getString("type");
                    //
                    if(type.equalsIgnoreCase("text")){
                        String textC = itemLabel.getString("value");

                        tsc.addText( x, y, LabelCommand.FONTTYPE.SIMPLIFIED_CHINESE,
                                LabelCommand.ROTATION.ROTATION_0,
                                LabelCommand.FONTMUL.MUL_1,
                                LabelCommand.FONTMUL.MUL_1,
                                textC
                        );
                    }
                    if(type.equalsIgnoreCase("image")){
                        Bitmap b = BitmapFactory.decodeStream(getClass().getResourceAsStream("/res/drawable/printlog.bmp"));
                        tsc.addBitmap( x, y, LabelCommand.BITMAP_MODE.OVERWRITE, 80, b );
                    }
                    if(type.equalsIgnoreCase("QRCode")){

                        Integer celW = itemLabel.getInt("cellwidth");
                        String data = itemLabel.getString("data");
                        tsc.addQRCode( x, y, LabelCommand.EEC.LEVEL_L, celW, LabelCommand.ROTATION.ROTATION_0, data );
                    }
                    if(type.equalsIgnoreCase("Barcode")){
                        Integer heigth = itemLabel.getInt("heigth");
                        String content = itemLabel.getString("content");
                        tsc.add1DBarcode( x, y, LabelCommand.BARCODETYPE.CODE128, heigth, LabelCommand.READABEL.EANBEL, LabelCommand.ROTATION.ROTATION_0, content );
                    }
                }

//            }

        }catch (Exception e){
//            XToastUtils.toast("Json 解析异常", Toast.LENGTH_LONG);
            Log.e("error","Json 解析异常");
            Utils.sendErrorState("打印错误,请检查");
            e.printStackTrace();
        }


        tsc.addPrint( 1, 1 );

        tsc.addSound( 2, 100 );
        tsc.addCashdrwer( LabelCommand.FOOT.F5, 255, 255 );
        Vector<Byte> datas = tsc.getCommand();

        if ( DeviceConnFactoryManager.getDeviceConnFactoryManagers()[id] == null )
        {
//            callbackJsWeb.webprintDoc(45,"sendLabel: 打印机未连接");
//            XToastUtils.toast("sendLabel: 打印机未连接", Toast.LENGTH_LONG);
            Log.d(TAG, "sendLabel: 打印机未连接");
            return;
        }
        try{
            DeviceConnFactoryManager.getDeviceConnFactoryManagers()[id].sendDataImmediately( datas );
        }catch (Exception e) {//异常中断发送
           Utils.sendErrorState("打印失败");
        }

    }
    /**
     * 连接蓝牙
     */
    public void connBlueTooth(){
        connBlueTooth(macaddress_default);
    }
    public void connBlueTooth(String macaddress){
        if(DeviceConnFactoryManager.getDeviceConnFactoryManagers()[id] != null &&DeviceConnFactoryManager.getDeviceConnFactoryManagers()[id].mPort != null ){
            return ;
        }
        //连接端口
        new DeviceConnFactoryManager.Build()
                .setId( id )
                .setConnMethod( DeviceConnFactoryManager.CONN_METHOD.BLUETOOTH )
                .setMacAddress( macaddress )
                .build();
        Log.d(TAG, "onActivityResult: "+id);
        Log.d(TAG, "onActivityResult: mac"+macaddress);
        Log.d(TAG, "连接蓝牙中......");
        threadPool = ThreadPool.getInstantiation();
        threadPool.addSerialTask( new Runnable()
        {
            @Override
            public void run()
            {
                DeviceConnFactoryManager.getDeviceConnFactoryManagers()[id].openPort();
            }
        } );
    }

    /**
     * 是否连接蓝牙
     * @param myid
     * @return
     */
    public static boolean hasDeviceConnFactoryManager(int myid){
        if(DeviceConnFactoryManager.getDeviceConnFactoryManagers()[myid] != null&&DeviceConnFactoryManager.getDeviceConnFactoryManagers()[myid].mPort != null )
        {
            return true;
        } else {
            return false;
        }
    }
    public void getStatus(){
        DeviceConnFactoryManager.getDeviceConnFactoryManagers()[id].getStatus();
    }
    public interface PrintInterfaceCallback{
        void webprintDoc(int resultCode,String message) throws JSONException;
    }
}
