// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_time_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MealTimeTypeAdapter extends TypeAdapter<MealTimeType> {
  @override
  final int typeId = 1;

  @override
  MealTimeType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MealTimeType.breakfast;
      case 1:
        return MealTimeType.lunch;
      case 2:
        return MealTimeType.dinner;
      case 3:
        return MealTimeType.snack;
      default:
        return MealTimeType.breakfast;
    }
  }

  @override
  void write(BinaryWriter writer, MealTimeType obj) {
    switch (obj) {
      case MealTimeType.breakfast:
        writer.writeByte(0);
        break;
      case MealTimeType.lunch:
        writer.writeByte(1);
        break;
      case MealTimeType.dinner:
        writer.writeByte(2);
        break;
      case MealTimeType.snack:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealTimeTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
