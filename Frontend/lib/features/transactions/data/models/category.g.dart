// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  name: json['name'] as String,
  type: json['type'] as String,
  icon: json['icon'] as String?,
  isDefault: json['isDefault'] as bool,
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'name': instance.name,
  'type': instance.type,
  'icon': instance.icon,
  'isDefault': instance.isDefault,
  'createdAt': instance.createdAt,
};
