import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../data/models/dashboard_balance.dart';
import '../../data/models/monthly_summary.dart';
import '../../data/models/transaction.dart';
import '../../data/models/spending_categories_response.dart';
import '../../data/models/financial_trend.dart';
import '../../data/services/dashboard_service.dart';

/// Dashboard service provider
final dashboardServiceProvider = Provider<DashboardService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DashboardService(apiClient);
});

/// Dashboard balance provider
final dashboardBalanceProvider = FutureProvider<DashboardBalance>((ref) async {
  final dashboardService = ref.watch(dashboardServiceProvider);
  final userId = ref.watch(userIdProvider);
  
  if (userId == null) {
    throw Exception('User not authenticated');
  }

  return await dashboardService.getBalance(userId);
});

/// Dashboard monthly summary provider
final dashboardMonthlySummaryProvider = FutureProvider<List<MonthlySummary>>((ref) async {
  final dashboardService = ref.watch(dashboardServiceProvider);
  final userId = ref.watch(userIdProvider);
  
  if (userId == null) {
    throw Exception('User not authenticated');
  }

  final currentYear = DateTime.now().year;
  return await dashboardService.getMonthlySummary(userId, currentYear);
});

/// Dashboard recent transactions provider
final dashboardRecentTransactionsProvider = FutureProvider<List<Transaction>>((ref) async {
  final dashboardService = ref.watch(dashboardServiceProvider);
  final userId = ref.watch(userIdProvider);
  
  if (userId == null) {
    throw Exception('User not authenticated');
  }

  return await dashboardService.getRecentTransactions(userId, limit: 5);
});

/// Dashboard spending categories provider
final dashboardSpendingCategoriesProvider = FutureProvider<SpendingCategoriesResponse>((ref) async {
  final dashboardService = ref.watch(dashboardServiceProvider);
  final userId = ref.watch(userIdProvider);
  
  if (userId == null) {
    throw Exception('User not authenticated');
  }

  // Get spending for current month
  final now = DateTime.now();
  final startDate = DateTime(now.year, now.month, 1);
  final endDate = DateTime(now.year, now.month + 1, 0);

  return await dashboardService.getSpendingCategories(
    userId,
    startDate: startDate,
    endDate: endDate,
  );
});

/// Dashboard financial trends provider
final dashboardTrendsProvider = FutureProvider<List<FinancialTrend>>((ref) async {
  final dashboardService = ref.watch(dashboardServiceProvider);
  final userId = ref.watch(userIdProvider);
  
  if (userId == null) {
    throw Exception('User not authenticated');
  }

  // Get trends for last 12 months
  final endDate = DateTime.now();
  final startDate = DateTime(endDate.year - 1, endDate.month, endDate.day);

  return await dashboardService.getFinancialTrends(userId, startDate, endDate);
});
