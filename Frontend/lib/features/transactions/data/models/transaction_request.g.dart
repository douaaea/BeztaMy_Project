// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionRequest _$TransactionRequestFromJson(Map<String, dynamic> json) =>
    TransactionRequest(
      categoryId: (json['categoryId'] as num).toInt(),
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String?,
      location: json['location'] as String?,
      transactionDate: json['transactionDate'] as String,
      isRecurring: json['isRecurring'] as bool? ?? false,
      frequency: json['frequency'] as String?,
      nextExecutionDate: json['nextExecutionDate'] as String?,
      endDate: json['endDate'] as String?,
    );

Map<String, dynamic> _$TransactionRequestToJson(TransactionRequest instance) =>
    <String, dynamic>{
      'categoryId': instance.categoryId,
      'type': instance.type,
      'amount': instance.amount,
      'description': instance.description,
      'location': instance.location,
      'transactionDate': instance.transactionDate,
      'isRecurring': instance.isRecurring,
      'frequency': instance.frequency,
      'nextExecutionDate': instance.nextExecutionDate,
      'endDate': instance.endDate,
    };
