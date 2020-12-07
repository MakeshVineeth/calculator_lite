// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currencyListItem.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CurrencyListItemAdapter extends TypeAdapter<CurrencyListItem> {
  @override
  final int typeId = 0;

  @override
  CurrencyListItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CurrencyListItem(
      currencyCode: fields[0] as String,
      flagURL: fields[1] as String,
      currencyName: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CurrencyListItem obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.currencyCode)
      ..writeByte(1)
      ..write(obj.flagURL)
      ..writeByte(2)
      ..write(obj.currencyName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrencyListItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
