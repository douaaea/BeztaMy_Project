import 'package:json_annotation/json_annotation.dart';
import 'category.dart';

part 'transaction.g.dart';

@JsonSerializable()
class Transaction {
  final int id;
  final int userId;
  final Category category;
  final String type; // "INCOME" or "EXPENSE"
  final double amount;
  final String? description;
  final String? location;
  final String transactionDate; // ISO format
  final bool isRecurring;
  final String? frequency;
  final String? nextExecutionDate;
  final String? endDate;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  Transaction({
    required this.id,
    required this.userId,
    required this.category,
    required this.type,
    required this.amount,
    this.description,
    this.location,
    required this.transactionDate,
    required this.isRecurring,
    this.frequency,
    this.nextExecutionDate,
    this.endDate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionToJson(this);
}
