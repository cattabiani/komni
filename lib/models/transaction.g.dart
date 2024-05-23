// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KTransactionAdapter extends TypeAdapter<KTransaction> {
  @override
  final int typeId = 3;

  @override
  KTransaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KTransaction(
      fields[0] as String,
      fields[1] as int,
      fields[2] as int,
      (fields[3] as List).cast<bool>(),
      (fields[4] as List).cast<int>(),
      fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, KTransaction obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.creditor)
      ..writeByte(3)
      ..write(obj.debtors)
      ..writeByte(4)
      ..write(obj.debts)
      ..writeByte(5)
      ..write(obj.currency);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KTransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
