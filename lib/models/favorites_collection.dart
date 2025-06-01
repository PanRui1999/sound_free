import 'package:hive/hive.dart';
import 'package:sound_free/models/sound.dart';

part 'favorites_collection.g.dart'; // 生成文件

@HiveType(typeId: 4)
class FavoritesCollection extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  List<Sound> sounds = [];

  FavoritesCollection({required this.name});
  FavoritesCollection.withSounds({required this.name, required this.sounds});
}
