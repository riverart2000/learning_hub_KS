// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning_unit.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LearningUnitAdapter extends TypeAdapter<LearningUnit> {
  @override
  final int typeId = 2;

  @override
  LearningUnit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LearningUnit(
      id: fields[0] as String,
      subCategoryId: fields[1] as String,
      type: fields[2] as LearningUnitType,
      title: fields[3] as String,
      content: (fields[4] as Map).cast<String, dynamic>(),
      difficulty: fields[5] as Difficulty,
      tags: (fields[6] as List).cast<String>(),
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, LearningUnit obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.subCategoryId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.content)
      ..writeByte(5)
      ..write(obj.difficulty)
      ..writeByte(6)
      ..write(obj.tags)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LearningUnitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LearningUnitTypeAdapter extends TypeAdapter<LearningUnitType> {
  @override
  final int typeId = 14;

  @override
  LearningUnitType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LearningUnitType.flashcard;
      case 1:
        return LearningUnitType.quiz;
      case 2:
        return LearningUnitType.lesson;
      case 3:
        return LearningUnitType.video;
      case 4:
        return LearningUnitType.exercise;
      case 5:
        return LearningUnitType.mixed;
      default:
        return LearningUnitType.flashcard;
    }
  }

  @override
  void write(BinaryWriter writer, LearningUnitType obj) {
    switch (obj) {
      case LearningUnitType.flashcard:
        writer.writeByte(0);
        break;
      case LearningUnitType.quiz:
        writer.writeByte(1);
        break;
      case LearningUnitType.lesson:
        writer.writeByte(2);
        break;
      case LearningUnitType.video:
        writer.writeByte(3);
        break;
      case LearningUnitType.exercise:
        writer.writeByte(4);
        break;
      case LearningUnitType.mixed:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LearningUnitTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DifficultyAdapter extends TypeAdapter<Difficulty> {
  @override
  final int typeId = 15;

  @override
  Difficulty read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Difficulty.beginner;
      case 1:
        return Difficulty.intermediate;
      case 2:
        return Difficulty.advanced;
      default:
        return Difficulty.beginner;
    }
  }

  @override
  void write(BinaryWriter writer, Difficulty obj) {
    switch (obj) {
      case Difficulty.beginner:
        writer.writeByte(0);
        break;
      case Difficulty.intermediate:
        writer.writeByte(1);
        break;
      case Difficulty.advanced:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DifficultyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HiveLearningUnitTypeAdapter extends TypeAdapter<HiveLearningUnitType> {
  @override
  final int typeId = 10;

  @override
  HiveLearningUnitType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HiveLearningUnitType.flashcard;
      case 1:
        return HiveLearningUnitType.quiz;
      case 2:
        return HiveLearningUnitType.lesson;
      case 3:
        return HiveLearningUnitType.video;
      case 4:
        return HiveLearningUnitType.exercise;
      case 5:
        return HiveLearningUnitType.mixed;
      default:
        return HiveLearningUnitType.flashcard;
    }
  }

  @override
  void write(BinaryWriter writer, HiveLearningUnitType obj) {
    switch (obj) {
      case HiveLearningUnitType.flashcard:
        writer.writeByte(0);
        break;
      case HiveLearningUnitType.quiz:
        writer.writeByte(1);
        break;
      case HiveLearningUnitType.lesson:
        writer.writeByte(2);
        break;
      case HiveLearningUnitType.video:
        writer.writeByte(3);
        break;
      case HiveLearningUnitType.exercise:
        writer.writeByte(4);
        break;
      case HiveLearningUnitType.mixed:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveLearningUnitTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HiveDifficultyAdapter extends TypeAdapter<HiveDifficulty> {
  @override
  final int typeId = 11;

  @override
  HiveDifficulty read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HiveDifficulty.beginner;
      case 1:
        return HiveDifficulty.intermediate;
      case 2:
        return HiveDifficulty.advanced;
      default:
        return HiveDifficulty.beginner;
    }
  }

  @override
  void write(BinaryWriter writer, HiveDifficulty obj) {
    switch (obj) {
      case HiveDifficulty.beginner:
        writer.writeByte(0);
        break;
      case HiveDifficulty.intermediate:
        writer.writeByte(1);
        break;
      case HiveDifficulty.advanced:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveDifficultyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
