// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transaction _$TransactionFromJson(Map<String, dynamic> json) => Transaction(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  category: Category.fromJson(json['category'] as Map<String, dynamic>),
  type: json['type'] as String,
  amount: (json['amount'] as num).toDouble(),
  description: json['description'] as String?,
  location: json['location'] as String?,
  transactionDate: json['transactionDate'] as String,
  isRecurring: json['isRecurring'] as bool,
  frequency: json['frequency'] as String?,
  nextExecutionDate: json['nextExecutionDate'] as String?,
  endDate: json['endDate'] as String?,
  isActive: json['isActive'] as bool,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
);

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'category': instance.category,
      'type': instance.type,
      'amount': instance.amount,
      'description': instance.description,
      'location': instance.location,
      'transactionDate': instance.transactionDate,
      'isRecurring': instance.isRecurring,
      'frequency': instance.frequency,
      'nextExecutionDate': instance.nextExecutionDate,
      'endDate': instance.endDate,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
