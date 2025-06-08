import 'dart:developer';

import 'package:sound_free/models/app_settings.dart';
import 'package:sound_free/tools/global_data.dart';
import 'package:hive_flutter/adapters.dart';

class AppSettingsController {
  static AppSettingsController? _instance;
  GlobalData? _globalData;
  Box<AppSettings>? _box;
  AppSettings? _appSettings;
  final String _keyName = 'k-1999-panrui';

  factory AppSettingsController() =>
      _instance ??= AppSettingsController._internal();

  AppSettingsController._internal() {
    _globalData = GlobalData();
    _box = Hive.box<AppSettings>(
      _globalData!.boxNameOfAppSettings,
    );
    if(!_box!.containsKey(_keyName)) {
      // default settings
      _appSettings = AppSettings();
      _box!.put(_keyName, _appSettings!);
    } else {
      _appSettings = _box!.get(_keyName);
    }
  }

  bool deleteScaningPath(String path) {
    if (path.isEmpty) {
      return false;
    }
    try {
      if(_appSettings!.scanningPaths.contains(path)) {
        _appSettings!.scanningPaths.remove(path);
      }
      _appSettings!.save();
      return true;
    } catch (e) {
      log('ERROR: AppSettingsController 在删除扫描路径($path)时发生错误\n\t$e');
      return false;
    }
  }

  bool addScaningPath(String path) {
    if (path.isEmpty) {
      return false;
    }
    try {
      if(!_appSettings!.scanningPaths.contains(path)) {
        _appSettings!.scanningPaths.add(path);
      }
      _appSettings!.save();
      return true;
    } catch (e) {
      log('ERROR: AppSettingsController 在添加一个扫描路径时发生错误\n\t$e');
      return false;
    }
  }

  List<String> allOfScaningPaths() {
    return List<String>.from(_appSettings!.scanningPaths);
  }
}
