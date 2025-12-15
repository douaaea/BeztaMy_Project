// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spending_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpendingCategory _$SpendingCategoryFromJson(Map<String, dynamic> json) =>
    SpendingCategory(
      label: json['label'] as String,
      value: (json['value'] as num).toDouble(),
      color: json['color'] as String,
    );

Map<String, dynamic> _$SpendingCategoryToJson(SpendingCategory instance) =>
    <String, dynamic>{
      'label': instance.label,
      'value': instance.value,
      'color': instance.color,
    };
