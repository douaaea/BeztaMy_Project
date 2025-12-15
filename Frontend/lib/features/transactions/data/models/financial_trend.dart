import 'package:json_annotation/json_annotation.dart';

part 'financial_trend.g.dart';

@JsonSerializable()
class FinancialTrend {
  final int month;
  final double balance;

  FinancialTrend({
    required this.month,
    required this.balance,
  });

  factory FinancialTrend.fromJson(Map<String, dynamic> json) =>
      _$FinancialTrendFromJson(json);

  Map<String, dynamic> toJson() => _$FinancialTrendToJson(this);
}
