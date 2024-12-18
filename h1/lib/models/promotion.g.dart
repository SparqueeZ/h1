// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'promotion.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PromotionAdapter extends TypeAdapter<Promotion> {
  @override
  final int typeId = 1;

  @override
  Promotion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Promotion(
      name: fields[0] as String,
      year: fields[1] as int,
      lessons: (fields[2] as List).cast<Lesson>(),
    );
  }

  @override
  void write(BinaryWriter writer, Promotion obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.year)
      ..writeByte(2)
      ..write(obj.lessons);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PromotionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
