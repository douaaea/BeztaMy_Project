import 'package:json_annotation/json_annotation.dart';

part 'monthly_summary.g.dart';

@JsonSerializable()
class MonthlySummary {
  final String month;
  final double income;
  final double expense;

  MonthlySummary({
    required this.month,
    required this.income,
    required this.expense,
  });

  factory MonthlySummary.fromJson(Map<String, dynamic> json) =>
      _$MonthlySummaryFromJson(json);

  Map<String, dynamic> toJson() => _$MonthlySummaryToJson(this);
}
