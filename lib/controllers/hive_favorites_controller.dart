import 'package:sound_free/models/favorites_collection.dart';
import 'package:sound_free/tools/global_data.dart';
import 'package:hive_flutter/adapters.dart';

class HiveFavoritesController {
  static final HiveFavoritesController _instance =
      HiveFavoritesController._internal();

  factory HiveFavoritesController() => _instance;

  HiveFavoritesController._internal();

  final GlobalData _globalData = GlobalData();

  Box<FavoritesCollection> obtainBox() {
    return Hive.box<FavoritesCollection>(
      _globalData.boxNameOfFavoritesCollection,
    );
  }
}
