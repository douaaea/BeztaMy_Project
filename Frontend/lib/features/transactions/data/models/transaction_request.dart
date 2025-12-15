import 'package:json_annotation/json_annotation.dart';

part 'transaction_request.g.dart';

@JsonSerializable()
class TransactionRequest {
  final int categoryId;
  final String type;
  final double amount;
  final String? description;
  final String? location;
  final String transactionDate; // ISO format yyyy-MM-dd
  final bool isRecurring;
  final String? frequency;
  final String? nextExecutionDate;
  final String? endDate;

  TransactionRequest({
    required this.categoryId,
    required this.type,
    required this.amount,
    this.description,
    this.location,
    required this.transactionDate,
    this.isRecurring = false,
    this.frequency,
    this.nextExecutionDate,
    this.endDate,
  });

  factory TransactionRequest.fromJson(Map<String, dynamic> json) =>
      _$TransactionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionRequestToJson(this);
}
