// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'balance_sheet.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KBalanceSheetAdapter extends TypeAdapter<KBalanceSheet> {
  @override
  final int typeId = 2;

  @override
  KBalanceSheet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KBalanceSheet(
      fields[0] as String,
      (fields[1] as List).cast<KTransaction>(),
      (fields[2] as List).cast<KBalanceSheetResults>(),
      (fields[3] as List).cast<String>(),
      (fields[4] as List).cast<String>(),
      fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, KBalanceSheet obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.ledger)
      ..writeByte(2)
      ..write(obj.results)
      ..writeByte(3)
      ..write(obj.people)
      ..writeByte(4)
      ..write(obj.currencies)
      ..writeByte(5)
      ..write(obj.isEditTransactionMode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KBalanceSheetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
