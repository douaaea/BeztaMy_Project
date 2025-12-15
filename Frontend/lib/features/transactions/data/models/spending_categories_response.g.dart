// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spending_categories_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpendingCategoriesResponse _$SpendingCategoriesResponseFromJson(
  Map<String, dynamic> json,
) => SpendingCategoriesResponse(
  totalSpending: (json['totalSpending'] as num).toDouble(),
  categories: (json['categories'] as List<dynamic>)
      .map((e) => SpendingCategory.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SpendingCategoriesResponseToJson(
  SpendingCategoriesResponse instance,
) => <String, dynamic>{
  'totalSpending': instance.totalSpending,
  'categories': instance.categories,
};
