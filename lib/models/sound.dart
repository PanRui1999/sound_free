import 'package:hive/hive.dart';

part 'sound.g.dart'; // 生成文件

@HiveType(typeId: 0)
class Sound extends HiveObject {
  @HiveField(0)
  final String sourcePath; // 音源路径

  @HiveField(1)
  final bool isLocal; // 是否本地文件

  @HiveField(2)
  SoundFormat format; // 音源格式

  Sound({
    required this.sourcePath,
    required this.isLocal,
    required this.format,
  });
}

@HiveType(typeId: 1)
enum SoundFormat {
  @HiveField(0)
  mp3,

  @HiveField(1)
  wav,

  @HiveField(2)
  aac,

  @HiveField(3)
  flac,

  @HiveField(4)
  unknown,
}
