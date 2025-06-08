class GlobalData {
  static final GlobalData _instance = GlobalData._internal();

  factory GlobalData() => _instance;

  GlobalData._internal();

  // Hive Configuration box name
  final String _boxNameOfFavoritesCollection = 'favorites';
  // App Settings box name
  final String _boxNameOfAppSettings = 'app_settings';

  String get boxNameOfFavoritesCollection => _boxNameOfFavoritesCollection;

  String get boxNameOfAppSettings => _boxNameOfAppSettings;
}
