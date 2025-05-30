import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' show Platform;
import 'package:sound_free/ui/android/android_app.dart';

void main() {
  

  if (Platform.isAndroid) {
    runApp(const AndroidApp());
  } else if (Platform.isWindows) {
    //runApp();
  }
}

void initHive() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化 Hive
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
}