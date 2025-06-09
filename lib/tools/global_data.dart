import 'package:just_audio/just_audio.dart';

class GlobalData {
  static final GlobalData _instance = GlobalData._internal();

  factory GlobalData() => _instance;

  GlobalData._internal();

  // Hive Configuration box name
  final String _boxNameOfFavoritesCollection = 'favorites';
  // App Settings box name
  final String _boxNameOfAppSettings = 'app_settings';
  // App Default Audio Player
  final AudioPlayer _defualtAudioPlayer = AudioPlayer();

  String get boxNameOfFavoritesCollection => _boxNameOfFavoritesCollection;

  String get boxNameOfAppSettings => _boxNameOfAppSettings;

  AudioPlayer get defualtAudioPlayer => _defualtAudioPlayer;
}
