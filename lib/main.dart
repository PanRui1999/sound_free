import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:sound_free/ui/android/android_app.dart';

void main() {
  if (Platform.isAndroid) {
    runApp(const AndroidApp());
  } else if (Platform.isWindows) {
    //runApp();
  }
}
