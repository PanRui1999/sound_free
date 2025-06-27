import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:sound_free/models/app_settings.dart';
import 'package:sound_free/models/favorites_collection.dart';
import 'package:sound_free/models/plugin.dart';
import 'package:sound_free/models/song.dart';
import 'package:sound_free/models/song_lyrics.dart';
import 'package:sound_free/tools/lua_engine.dart';
import 'dart:io' show Platform;
import 'package:sound_free/ui/android/android_app.dart';
import 'package:sound_free/models/sound.dart';
import 'tools/global_data.dart';

void main() async {
  await initHive();
  await LuaEngineN.init();
  if (Platform.isAndroid) {
    runApp(const AndroidApp());
  } else if (Platform.isWindows) {
    //runApp();
  }
}

Future<void> initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(SoundAdapter());
  Hive.registerAdapter(SongAdapter());
  Hive.registerAdapter(SoundFormatAdapter());
  Hive.registerAdapter(SongLyricsAdapter());
  Hive.registerAdapter(FavoritesCollectionAdapter());
  Hive.registerAdapter(AppSettingsAdapter());

  // preopen box
  var box = await Hive.openBox<FavoritesCollection>(
    GlobalData().boxNameOfFavoritesCollection,
  );
  await Hive.openBox<AppSettings>(GlobalData().boxNameOfAppSettings);
  //await box.clear();
}

