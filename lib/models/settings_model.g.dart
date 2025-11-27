// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 4;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      monthStartDate: fields[0] as int,
      monthEndDate: fields[1] as int,
      googleSheetId: fields[2] as String?,
      minRentIncome: fields[3] as double,
      minDailyExpense: fields[4] as double,
      isDarkMode: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.monthStartDate)
      ..writeByte(1)
      ..write(obj.monthEndDate)
      ..writeByte(2)
      ..write(obj.googleSheetId)
      ..writeByte(3)
      ..write(obj.minRentIncome)
      ..writeByte(4)
      ..write(obj.minDailyExpense)
      ..writeByte(5)
      ..write(obj.isDarkMode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
