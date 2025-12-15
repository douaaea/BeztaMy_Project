// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'financial_trend.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FinancialTrend _$FinancialTrendFromJson(Map<String, dynamic> json) =>
    FinancialTrend(
      month: (json['month'] as num).toInt(),
      balance: (json['balance'] as num).toDouble(),
    );

Map<String, dynamic> _$FinancialTrendToJson(FinancialTrend instance) =>
    <String, dynamic>{'month': instance.month, 'balance': instance.balance};
