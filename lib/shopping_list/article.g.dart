// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ArticleAdapter extends TypeAdapter<Article> {
  @override
  final int typeId = 0;

  @override
  Article read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Article()
      ..name = fields[0] as String
      ..quantity = fields[1] as int
      ..quantityUnit = fields[2] as QuantityUnit
      ..details = fields[3] as String;
  }

  @override
  void write(BinaryWriter writer, Article obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.quantity)
      ..writeByte(2)
      ..write(obj.quantityUnit)
      ..writeByte(3)
      ..write(obj.details);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArticleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QuantityUnitAdapter extends TypeAdapter<QuantityUnit> {
  @override
  final int typeId = 1;

  @override
  QuantityUnit read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return QuantityUnit.pieces;
      case 1:
        return QuantityUnit.gram;
      case 2:
        return QuantityUnit.milliliter;
      default:
        return QuantityUnit.pieces;
    }
  }

  @override
  void write(BinaryWriter writer, QuantityUnit obj) {
    switch (obj) {
      case QuantityUnit.pieces:
        writer.writeByte(0);
        break;
      case QuantityUnit.gram:
        writer.writeByte(1);
        break;
      case QuantityUnit.milliliter:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuantityUnitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
