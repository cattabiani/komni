// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'balance_sheet_results.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KBalanceSheetResultsAdapter extends TypeAdapter<KBalanceSheetResults> {
  @override
  final int typeId = 4;

  @override
  KBalanceSheetResults read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KBalanceSheetResults(
      (fields[0] as Map).cast<Tuple3<int, int, int>, int>(),
    );
  }

  @override
  void write(BinaryWriter writer, KBalanceSheetResults obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj._s);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KBalanceSheetResultsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
