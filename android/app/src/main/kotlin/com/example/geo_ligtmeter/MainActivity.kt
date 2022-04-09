package com.example.geo_ligtmeter

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    private val channel = "externalStorage";

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            when (call.method) {
                "getExternalStorageDirectory" ->
                    result.success(Environment.getExternalStorageDirectory().toString())
                "getExternalStoragePublicDirectory" -> {
                    val type = call.argument<String>("type")
                    result.success(Environment.getExternalStoragePublicDirectory(type).toString())
                }
                else -> result.notImplemented()
            }
        }

    }
}
