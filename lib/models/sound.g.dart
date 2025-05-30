// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sound.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SoundAdapter extends TypeAdapter<Sound> {
  @override
  final int typeId = 0;

  @override
  Sound read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Sound(
      sourcePath: fields[0] as String,
      isLocal: fields[1] as bool,
      format: fields[2] as SoundFormat,
    );
  }

  @override
  void write(BinaryWriter writer, Sound obj) {
    writer
      ..writeByte(3)
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
      other is SoundAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SoundFormatAdapter extends TypeAdapter<SoundFormat> {
  @override
  final int typeId = 1;

  @override
  SoundFormat read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SoundFormat.mp3;
      case 1:
        return SoundFormat.wav;
      case 2:
        return SoundFormat.aac;
      case 3:
        return SoundFormat.flac;
      case 4:
        return SoundFormat.unknown;
      default:
        return SoundFormat.mp3;
    }
  }

  @override
  void write(BinaryWriter writer, SoundFormat obj) {
    switch (obj) {
      case SoundFormat.mp3:
        writer.writeByte(0);
        break;
      case SoundFormat.wav:
        writer.writeByte(1);
        break;
      case SoundFormat.aac:
        writer.writeByte(2);
        break;
      case SoundFormat.flac:
        writer.writeByte(3);
        break;
      case SoundFormat.unknown:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SoundFormatAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
