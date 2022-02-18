import 'package:hive/hive.dart';

@HiveType(typeId: 0, adapterName: "ArticleHiveAdapter")
class Article {
  @HiveField(0)
  String name = "";
  @HiveField(1)
  int quantity = 1;
  @HiveField(2)
  QuantityUnit quantityUnit = QuantityUnit.pieces;
  @HiveField(3)
  String details = "";

  static String quantityUnitToString(QuantityUnit unit) {
    switch (unit) {
      case QuantityUnit.pieces:
        return "stk";
      case QuantityUnit.gram:
        return "g";
      case QuantityUnit.milliliter:
        return "ml";
    }
  }
}

enum QuantityUnit { pieces, gram, milliliter }

class ArticleHiveAdapter extends TypeAdapter<Article> {
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
      other is ArticleHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
