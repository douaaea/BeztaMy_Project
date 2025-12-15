import 'package:json_annotation/json_annotation.dart';
import 'spending_category.dart';

part 'spending_categories_response.g.dart';

@JsonSerializable()
class SpendingCategoriesResponse {
  final double totalSpending;
  final List<SpendingCategory> categories;

  SpendingCategoriesResponse({
    required this.totalSpending,
    required this.categories,
  });

  factory SpendingCategoriesResponse.fromJson(Map<String, dynamic> json) =>
      _$SpendingCategoriesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SpendingCategoriesResponseToJson(this);
}
