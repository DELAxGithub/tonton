// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MealRecordAdapter extends TypeAdapter<MealRecord> {
  @override
  final int typeId = 2;

  @override
  MealRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MealRecord(
      id: fields[0] as String?,
      mealName: fields[1] as String,
      description: fields[2] as String,
      calories: fields[3] as double,
      protein: fields[4] as double,
      fat: fields[5] as double,
      carbs: fields[6] as double,
      mealTimeType: fields[7] as MealTimeType,
      consumedAt: fields[8] as DateTime?,
      createdAt: fields[9] as DateTime?,
      updatedAt: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, MealRecord obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.mealName)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.calories)
      ..writeByte(4)
      ..write(obj.protein)
      ..writeByte(5)
      ..write(obj.fat)
      ..writeByte(6)
      ..write(obj.carbs)
      ..writeByte(7)
      ..write(obj.mealTimeType)
      ..writeByte(8)
      ..write(obj.consumedAt)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
