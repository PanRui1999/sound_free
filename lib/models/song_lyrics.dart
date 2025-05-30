import 'package:hive/hive.dart';

part 'song_lyrics.g.dart'; // 生成文件

@HiveType(typeId: 3)
class SongLyrics extends HiveObject {
  @HiveField(0)
  final String lyricsPath;

  @HiveField(1)
  final bool isLocal;

  SongLyrics({required this.lyricsPath, required this.isLocal});
}
