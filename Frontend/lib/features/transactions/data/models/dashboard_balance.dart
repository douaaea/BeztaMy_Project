import 'package:json_annotation/json_annotation.dart';

part 'dashboard_balance.g.dart';

@JsonSerializable()
class DashboardBalance {
  final double totalIncome;
  final double totalExpense;
  final double currentBalance;

  DashboardBalance({
    required this.totalIncome,
    required this.totalExpense,
    required this.currentBalance,
  });

  factory DashboardBalance.fromJson(Map<String, dynamic> json) =>
      _$DashboardBalanceFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardBalanceToJson(this);
}
