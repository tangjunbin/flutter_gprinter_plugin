package com.example.gp_plugin.printsdk;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.Intent;

import com.example.gp_plugin.ConstraintsMap;

import java.util.Map;
import java.util.Set;

public class BluetoothSdk {

    private BluetoothAdapter mBluetoothAdapter;

    public BluetoothSdk(){
        mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();

    }

    /**
     * 检查蓝牙是否可用
     */
    public String checkBluetooth(){

        if (mBluetoothAdapter == null) {
            //当前设备不支持蓝牙
            return "当前设备不支持蓝牙";
        } else {
            // 检查蓝牙是否打开
            if (!mBluetoothAdapter.isEnabled()) {
                //未打开蓝牙
                Intent enableIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
                return "未打开蓝牙";
            } else {
                return "已打开蓝牙";
            }
        }
    }
    /**
     * 蓝牙设备列表
     */
    public Map<String, Object> getDeviceList() {
        // 已匹对数据
        ConstraintsMap params = new ConstraintsMap();
        Set<BluetoothDevice> pairedDevices = mBluetoothAdapter.getBondedDevices();
        if (pairedDevices.size() > 0) {
            //遍历填充数据
            for (BluetoothDevice device : pairedDevices) {
//                mDevicesArrayAdapter.add(device.getName() + "\n" + device.getAddress());
                params.putString(device.getAddress(),device.getName());
            }
        } else {
//            mDevicesArrayAdapter.add("没有已配对设备");
        }
        return params.toMap();
    }

    /**
     * 销毁蓝牙适配器对象
     */
    protected void destroy() {
        // Make sure we're not doing discovery anymore
        if (mBluetoothAdapter != null) {
            mBluetoothAdapter.cancelDiscovery();
        }
    }

}
