import 'package:hive/hive.dart';
import 'sound.dart';
import 'song_lyrics.dart';

part 'song.g.dart'; // 生成文件

@HiveType(typeId: 2)
class Song extends Sound {
  @HiveField(10)
  final String name;

  @HiveField(11)
  SongLyrics? lyrics;

  @HiveField(12)
  final String singer;

  @HiveField(13)
  String? imagePath;

  Song({
    required this.name,
    required this.singer,
    required super.sourcePath,
    required super.isLocal,
    required super.format,
    this.imagePath = '',
  }) {
    lyrics = SongLyrics(lyricsPath: '', isLocal: false);
  }
}
