// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_progress.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProgressAdapter extends TypeAdapter<UserProgress> {
  @override
  final int typeId = 5;

  @override
  UserProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProgress(
      id: fields[0] as String,
      userId: fields[1] as String,
      learningUnitId: fields[2] as String,
      status: fields[3] as ProgressStatus,
      attempts: fields[4] as int,
      score: fields[5] as double,
      lastReviewed: fields[6] as DateTime?,
      nextReview: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserProgress obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.learningUnitId)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.attempts)
      ..writeByte(5)
      ..write(obj.score)
      ..writeByte(6)
      ..write(obj.lastReviewed)
      ..writeByte(7)
      ..write(obj.nextReview);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProgressStatusAdapter extends TypeAdapter<ProgressStatus> {
  @override
  final int typeId = 16;

  @override
  ProgressStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ProgressStatus.notStarted;
      case 1:
        return ProgressStatus.inProgress;
      case 2:
        return ProgressStatus.completed;
      case 3:
        return ProgressStatus.mastered;
      default:
        return ProgressStatus.notStarted;
    }
  }

  @override
  void write(BinaryWriter writer, ProgressStatus obj) {
    switch (obj) {
      case ProgressStatus.notStarted:
        writer.writeByte(0);
        break;
      case ProgressStatus.inProgress:
        writer.writeByte(1);
        break;
      case ProgressStatus.completed:
        writer.writeByte(2);
        break;
      case ProgressStatus.mastered:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgressStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HiveProgressStatusAdapter extends TypeAdapter<HiveProgressStatus> {
  @override
  final int typeId = 12;

  @override
  HiveProgressStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HiveProgressStatus.notStarted;
      case 1:
        return HiveProgressStatus.inProgress;
      case 2:
        return HiveProgressStatus.completed;
      case 3:
        return HiveProgressStatus.mastered;
      default:
        return HiveProgressStatus.notStarted;
    }
  }

  @override
  void write(BinaryWriter writer, HiveProgressStatus obj) {
    switch (obj) {
      case HiveProgressStatus.notStarted:
        writer.writeByte(0);
        break;
      case HiveProgressStatus.inProgress:
        writer.writeByte(1);
        break;
      case HiveProgressStatus.completed:
        writer.writeByte(2);
        break;
      case HiveProgressStatus.mastered:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveProgressStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
