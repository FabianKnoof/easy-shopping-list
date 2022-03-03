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
      ..name = fields[0] == null ? '' : fields[0] as String
      ..quantity = fields[1] == null ? 0 : fields[1] as int
      ..quantityUnit =
          fields[2] == null ? QuantityUnit.pieces : fields[2] as QuantityUnit
      ..details = fields[3] == null ? '' : fields[3] as String
      ..isIngredient = fields[4] == null ? true : fields[4] as bool
      ..isChecked = fields[5] == null ? false : fields[5] as bool
      ..mealIndex = fields[6] as int?;
  }

  @override
  void write(BinaryWriter writer, Article obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.quantity)
      ..writeByte(2)
      ..write(obj.quantityUnit)
      ..writeByte(3)
      ..write(obj.details)
      ..writeByte(4)
      ..write(obj.isIngredient)
      ..writeByte(5)
      ..write(obj.isChecked)
      ..writeByte(6)
      ..write(obj.mealIndex);
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

class ArticleEntryAdapter extends TypeAdapter<ArticleEntry> {
  @override
  final int typeId = 1;

  @override
  ArticleEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ArticleEntry(
      fields[0] == null ? '' : fields[0] as String,
      fields[1] == null ? 0 : fields[1] as int,
      fields[2] == null ? QuantityUnit.pieces : fields[2] as QuantityUnit,
      fields[3] == null ? '' : fields[3] as String,
      fields[4] == null ? [] : (fields[4] as List).cast<Article>(),
    );
  }

  @override
  void write(BinaryWriter writer, ArticleEntry obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.quantity)
      ..writeByte(2)
      ..write(obj.quantityUnit)
      ..writeByte(3)
      ..write(obj.details)
      ..writeByte(4)
      ..write(obj.articles);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArticleEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QuantityUnitAdapter extends TypeAdapter<QuantityUnit> {
  @override
  final int typeId = 2;

  @override
  QuantityUnit read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return QuantityUnit.pieces;
      case 1:
        return QuantityUnit.gram;
      case 2:
        return QuantityUnit.milliliter;
      case 3:
        return QuantityUnit.teaspoon;
      case 4:
        return QuantityUnit.tablespoon;
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
      case QuantityUnit.teaspoon:
        writer.writeByte(3);
        break;
      case QuantityUnit.tablespoon:
        writer.writeByte(4);
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

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Article _$ArticleFromJson(Map<String, dynamic> json) => Article()
  ..name = json['name'] as String
  ..quantity = json['quantity'] as int
  ..quantityUnit = $enumDecode(_$QuantityUnitEnumMap, json['quantityUnit'])
  ..details = json['details'] as String
  ..isIngredient = json['isIngredient'] as bool;

Map<String, dynamic> _$ArticleToJson(Article instance) => <String, dynamic>{
      'name': instance.name,
      'quantity': instance.quantity,
      'quantityUnit': _$QuantityUnitEnumMap[instance.quantityUnit],
      'details': instance.details,
      'isIngredient': instance.isIngredient,
    };

const _$QuantityUnitEnumMap = {
  QuantityUnit.pieces: 'pieces',
  QuantityUnit.gram: 'gram',
  QuantityUnit.milliliter: 'milliliter',
  QuantityUnit.teaspoon: 'teaspoon',
  QuantityUnit.tablespoon: 'tablespoon',
};
