package com.example.gp_plugin.common;


import android.content.Intent;

import com.example.gp_plugin.GpPlugin;

public class Utils {

    public static final String ACTION_QUERY_PRINTER_STATE = "action_query_printer_state";
    public static final String STATE = "state";
    /**
     * 发送广播
     * @param state
     */
    public static void sendErrorState(String state) {
        Intent intent = new Intent(ACTION_QUERY_PRINTER_STATE);
        intent.putExtra(STATE, state);
        intent.putExtra("event", "printStatus");
        intent.putExtra("code", 1);
        GpPlugin.applicationContext.sendBroadcast(intent);
    }
    public static void sendErrorState(String state,int close) {
        Intent intent = new Intent(ACTION_QUERY_PRINTER_STATE);
        intent.putExtra(STATE, state);
        intent.putExtra("event", "printStatus");
        intent.putExtra("code", 1);
        intent.putExtra("close", close);
        GpPlugin.applicationContext.sendBroadcast(intent);
    }
    public static void sendSuccessState(String state) {
        Intent intent = new Intent(ACTION_QUERY_PRINTER_STATE);
        intent.putExtra(STATE, state);
        intent.putExtra("event", "printStatus");
        intent.putExtra("code", 88);
        GpPlugin.applicationContext.sendBroadcast(intent);
    }
    public static void sendSuccessState(String state,int close) {
        Intent intent = new Intent(ACTION_QUERY_PRINTER_STATE);
        intent.putExtra(STATE, state);
        intent.putExtra("event", "printStatus");
        intent.putExtra("code", 88);
        intent.putExtra("close", close);
        GpPlugin.applicationContext.sendBroadcast(intent);
    }
}
