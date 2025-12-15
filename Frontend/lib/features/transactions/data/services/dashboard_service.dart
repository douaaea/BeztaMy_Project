import '../../../../core/network/api_client.dart';
import '../models/dashboard_balance.dart';
import '../models/monthly_summary.dart';
import '../models/transaction.dart';
import '../models/spending_categories_response.dart';
import '../models/financial_trend.dart';

class DashboardService {
  final ApiClient _apiClient;

  DashboardService(this._apiClient);

  /// Get balance summary
  Future<DashboardBalance> getBalance(int userId) async {
    final response = await _apiClient.get(
      '/transactions/dashboard/balance',
      queryParameters: {'userId': userId.toString()},
    );
    return DashboardBalance.fromJson(response.data);
  }

  /// Get monthly summary for income vs expenses chart
  Future<List<MonthlySummary>> getMonthlySummary(int userId, int year) async {
    final response = await _apiClient.get(
      '/transactions/dashboard/monthly-summary',
      queryParameters: {
        'userId': userId.toString(),
        'year': year.toString(),
      },
    );
    return (response.data as List)
        .map((json) => MonthlySummary.fromJson(json))
        .toList();
  }

  /// Get recent transactions
  Future<List<Transaction>> getRecentTransactions(int userId, {int limit = 5}) async {
    final response = await _apiClient.get(
      '/transactions/dashboard/recent',
      queryParameters: {
        'userId': userId.toString(),
        'limit': limit.toString(),
      },
    );
    return (response.data as List)
        .map((json) => Transaction.fromJson(json))
        .toList();
  }

  /// Get spending categories breakdown
  Future<SpendingCategoriesResponse> getSpendingCategories(
    int userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = {'userId': userId.toString()};
    
    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String().split('T')[0];
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String().split('T')[0];
    }

    final response = await _apiClient.get(
      '/transactions/dashboard/spending-categories',
      queryParameters: queryParams,
    );
    return SpendingCategoriesResponse.fromJson(response.data);
  }

  /// Get financial trends
  Future<List<FinancialTrend>> getFinancialTrends(
    int userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final response = await _apiClient.get(
      '/transactions/dashboard/financial-trends',
      queryParameters: {
        'userId': userId.toString(),
        'startDate': startDate.toIso8601String().split('T')[0],
        'endDate': endDate.toIso8601String().split('T')[0],
      },
    );
    return (response.data as List)
        .map((json) => FinancialTrend.fromJson(json))
        .toList();
  }
}
