// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SongAdapter extends TypeAdapter<Song> {
  @override
  final int typeId = 2;

  @override
  Song read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Song(
      name: fields[10] as String,
      singer: fields[12] as String,
      sourcePath: fields[0] as String,
      isLocal: fields[1] as bool,
      format: fields[2] as SoundFormat,
      imagePath: fields[13] as String?,
    )..lyrics = fields[11] as SongLyrics?;
  }

  @override
  void write(BinaryWriter writer, Song obj) {
    writer
      ..writeByte(7)
      ..writeByte(10)
      ..write(obj.name)
      ..writeByte(11)
      ..write(obj.lyrics)
      ..writeByte(12)
      ..write(obj.singer)
      ..writeByte(13)
      ..write(obj.imagePath)
      ..writeByte(0)
      ..write(obj.sourcePath)
      ..writeByte(1)
      ..write(obj.isLocal)
      ..writeByte(2)
      ..write(obj.format);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
