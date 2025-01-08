// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'promotion.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PromotionAdapter extends TypeAdapter<Promotion> {
  @override
  final int typeId = 4;

  @override
  Promotion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Promotion(
      id: fields[0] as String,
      name: fields[1] as String,
      year: fields[2] as int,
      lessons: (fields[3] as List).cast<Lesson>(),
      students: (fields[4] as List).cast<Student>(),
    );
  }

  @override
  void write(BinaryWriter writer, Promotion obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.year)
      ..writeByte(3)
      ..write(obj.lessons)
      ..writeByte(4)
      ..write(obj.students);
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
