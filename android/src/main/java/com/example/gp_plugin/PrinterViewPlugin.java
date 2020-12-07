package com.example.gp_plugin;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.PluginRegistry;

public class PrinterViewPlugin implements FlutterPlugin {
//    public static void registerWith(PluginRegistry.Registrar registrar) {
//        registrar
//                .platformViewRegistry()
//                .registerViewFactory(
//                        "com.gh.gpprinter/textview", new TextViewFactory(registrar.messenger()));
//    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        binding.getPlatformViewRegistry().registerViewFactory("com.gh.gpprinter/textview", new TextViewFactory(binding.getBinaryMessenger()));
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {

    }
}
