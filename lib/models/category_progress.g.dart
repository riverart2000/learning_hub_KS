// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_progress.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CategoryProgressAdapter extends TypeAdapter<CategoryProgress> {
  @override
  final int typeId = 20;

  @override
  CategoryProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CategoryProgress(
      categoryId: fields[0] as String,
      userId: fields[1] as String,
      totalQuestions: fields[2] as int,
      attemptedQuestions: fields[3] as int,
      correctAnswers: fields[4] as int,
      lastAccessedAt: fields[5] as DateTime?,
      completedAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, CategoryProgress obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.categoryId)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.totalQuestions)
      ..writeByte(3)
      ..write(obj.attemptedQuestions)
      ..writeByte(4)
      ..write(obj.correctAnswers)
      ..writeByte(5)
      ..write(obj.lastAccessedAt)
      ..writeByte(6)
      ..write(obj.completedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
