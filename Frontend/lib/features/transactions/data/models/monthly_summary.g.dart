// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MonthlySummary _$MonthlySummaryFromJson(Map<String, dynamic> json) =>
    MonthlySummary(
      month: json['month'] as String,
      income: (json['income'] as num).toDouble(),
      expense: (json['expense'] as num).toDouble(),
    );

Map<String, dynamic> _$MonthlySummaryToJson(MonthlySummary instance) =>
    <String, dynamic>{
      'month': instance.month,
      'income': instance.income,
      'expense': instance.expense,
    };
