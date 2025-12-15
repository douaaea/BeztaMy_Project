// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_balance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardBalance _$DashboardBalanceFromJson(Map<String, dynamic> json) =>
    DashboardBalance(
      totalIncome: (json['totalIncome'] as num).toDouble(),
      totalExpense: (json['totalExpense'] as num).toDouble(),
      currentBalance: (json['currentBalance'] as num).toDouble(),
    );

Map<String, dynamic> _$DashboardBalanceToJson(DashboardBalance instance) =>
    <String, dynamic>{
      'totalIncome': instance.totalIncome,
      'totalExpense': instance.totalExpense,
      'currentBalance': instance.currentBalance,
    };
