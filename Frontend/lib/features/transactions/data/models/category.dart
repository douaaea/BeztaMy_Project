import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable()
class Category {
  final int id;
  final int userId;
  final String name;
  final String type; // "INCOME" or "EXPENSE"
  final String? icon;
  final bool isDefault;
  final String createdAt;

  Category({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    this.icon,
    required this.isDefault,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}
