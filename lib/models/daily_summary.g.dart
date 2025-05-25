// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_summary.dart';

class DailySummaryAdapter extends TypeAdapter<DailySummary> {
  @override
  final int typeId = 3;

  @override
  DailySummary read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailySummary(
      date: fields[0] as DateTime,
      caloriesConsumed: fields[1] as double,
      caloriesBurned: fields[2] as double,
      weight: fields[3] as double?,
      bodyFatPercentage: fields[4] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, DailySummary obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.caloriesConsumed)
      ..writeByte(2)
      ..write(obj.caloriesBurned)
      ..writeByte(3)
      ..write(obj.weight)
      ..writeByte(4)
      ..write(obj.bodyFatPercentage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailySummaryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

