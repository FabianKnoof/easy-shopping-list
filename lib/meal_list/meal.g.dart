// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MealAdapter extends TypeAdapter<Meal> {
  @override
  final int typeId = 2;

  @override
  Meal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Meal()
      ..name = fields[0] == null ? '' : fields[0] as String
      ..quantity = fields[1] == null ? 1 : fields[1] as int
      ..quantityUnit = fields[2] == null ? 'Portion(en)' : fields[2] as String
      ..ingredients =
          fields[3] == null ? [] : (fields[3] as List).cast<Article>();
  }

  @override
  void write(BinaryWriter writer, Meal obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.quantity)
      ..writeByte(2)
      ..write(obj.quantityUnit)
      ..writeByte(3)
      ..write(obj.ingredients);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Meal _$MealFromJson(Map<String, dynamic> json) => Meal()
  ..name = json['name'] as String
  ..quantity = json['quantity'] as int
  ..quantityUnit = json['quantityUnit'] as String
  ..ingredients = (json['ingredients'] as List<dynamic>)
      .map((e) => Article.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$MealToJson(Meal instance) => <String, dynamic>{
      'name': instance.name,
      'quantity': instance.quantity,
      'quantityUnit': instance.quantityUnit,
      'ingredients': instance.ingredients.map((e) => e.toJson()).toList(),
    };
