package com.example.sound_free

import android.content.Intent
import com.example.sound_free.flutterPlugins.SafFileScannerPlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private val mSafFileScannerPlugin: SafFileScannerPlugin = SafFileScannerPlugin(this)

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        mSafFileScannerPlugin.registerWith(flutterEngine)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        mSafFileScannerPlugin.handleActivityResult(requestCode, resultCode, data)
    }
}

