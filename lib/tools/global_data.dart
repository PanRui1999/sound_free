class GlobalData {
  static final GlobalData _instance = GlobalData._internal();

  factory GlobalData() => _instance;

  GlobalData._internal();

  // Hive Configuration
  final String _boxNameOfFavoritesCollection = 'favorites';

  String get boxNameOfFavoritesCollection => _boxNameOfFavoritesCollection;
}
