// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuizStateAdapter extends TypeAdapter<QuizState> {
  @override
  final int typeId = 14;

  @override
  QuizState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuizState(
      userId: fields[0] as String,
      learningUnitId: fields[1] as String,
      currentQuestionIndex: fields[2] as int,
      correctAnswers: fields[3] as int,
      lastUpdated: fields[4] as DateTime,
      answeredQuestions: (fields[5] as List).cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, QuizState obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.learningUnitId)
      ..writeByte(2)
      ..write(obj.currentQuestionIndex)
      ..writeByte(3)
      ..write(obj.correctAnswers)
      ..writeByte(4)
      ..write(obj.lastUpdated)
      ..writeByte(5)
      ..write(obj.answeredQuestions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
