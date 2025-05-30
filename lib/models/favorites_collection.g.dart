// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorites_collection.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavoritesCollectionAdapter extends TypeAdapter<FavoritesCollection> {
  @override
  final int typeId = 4;

  @override
  FavoritesCollection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoritesCollection(
      name: fields[0] as String,
    )..sounds = (fields[1] as List).cast<Sound>();
  }

  @override
  void write(BinaryWriter writer, FavoritesCollection obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.sounds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoritesCollectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
