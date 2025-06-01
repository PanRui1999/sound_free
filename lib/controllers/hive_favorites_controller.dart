import 'dart:developer';

import 'package:sound_free/models/favorites_collection.dart';
import 'package:sound_free/tools/global_data.dart';
import 'package:hive_flutter/adapters.dart';

class HiveFavoritesController {
  static HiveFavoritesController? _instance;
  GlobalData? _globalData;
  Box<FavoritesCollection>? _box;

  factory HiveFavoritesController() =>
      _instance ??= HiveFavoritesController._internal();

  HiveFavoritesController._internal() {
    _globalData = GlobalData();
    _box = Hive.box<FavoritesCollection>(
      _globalData!.boxNameOfFavoritesCollection,
    );
  }

  bool rename(FavoritesCollection f, String name) {
    if (name.isEmpty) {
      return false;
    }
    try {
      for (var key in _box!.keys) {
        if (key == f.name) {
          _box!.delete(f.name).then((value) {
            f.name = name;;
            _box!.put(name, f);
          });
          return true;
        }
      }
      return false;
    } catch (e) {
      log('ERROR: HiveFavoritesController 在更新收藏($name)时发生错误\n\t$e');
      return false;
    }
  }

  bool delete(String name) {
    if (name.isEmpty) {
      return false;
    }
    try {
      _box!.delete(name);
      return true;
    } catch (e) {
      log('ERROR: HiveFavoritesController 在删除收藏($name)时发生错误\n\t$e');
      return false;
    }
  }

  bool add(String name) {
    if (name.isEmpty) {
      return false;
    }
    try {
      if (_box!.containsKey(name)) {
        return false;
      }
      _box!.put(name, FavoritesCollection(name: name));
      return true;
    } catch (e) {
      log('ERROR: HiveFavoritesController 在添加一个收藏时发生错误\n\t$e');
      return false;
    }
  }

  List<FavoritesCollection> all() {
    List<FavoritesCollection> list = [];
    for (var key in _box!.keys) {
      var t = _box!.get(key);
      if (t == null) continue;
      list.add(t);
    }
    return list;
  }
}
