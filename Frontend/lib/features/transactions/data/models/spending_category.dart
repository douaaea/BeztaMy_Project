import 'package:json_annotation/json_annotation.dart';

part 'spending_category.g.dart';

@JsonSerializable()
class SpendingCategory {
  final String label;
  final double value;
  final String color; // Hex color string

  SpendingCategory({
    required this.label,
    required this.value,
    required this.color,
  });

  factory SpendingCategory.fromJson(Map<String, dynamic> json) =>
      _$SpendingCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$SpendingCategoryToJson(this);
}
