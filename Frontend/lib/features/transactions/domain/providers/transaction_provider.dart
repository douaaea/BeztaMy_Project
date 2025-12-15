import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../data/models/transaction.dart';
import '../../data/services/transaction_service.dart';

/// Transaction service provider
final transactionServiceProvider = Provider<TransactionService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TransactionService(apiClient);
});

/// Transactions provider - loads all transactions for current user
final transactionsProvider = FutureProvider<List<Transaction>>((ref) async {
  final transactionService = ref.watch(transactionServiceProvider);
  final userId = ref.watch(userIdProvider);
  
  if (userId == null) {
    throw Exception('User not authenticated');
  }

  return await transactionService.getTransactions(userId);
});

/// Transaction filter state
class TransactionFilter {
  final String searchQuery;
  final String? type; // 'INCOME', 'EXPENSE', or null for all
  final int? categoryId;
  final String sortOrder; // 'newest', 'oldest'

  TransactionFilter({
    this.searchQuery = '',
    this.type,
    this.categoryId,
    this.sortOrder = 'newest',
  });

  TransactionFilter copyWith({
    String? searchQuery,
    Object? type = _notProvided,
    Object? categoryId = _notProvided,
    String? sortOrder,
  }) {
    return TransactionFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      type: type == _notProvided ? this.type : type as String?,
      categoryId: categoryId == _notProvided ? this.categoryId : categoryId as int?,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

// Sentinel value for nullable parameters
const Object _notProvided = Object();

/// Filter provider
final transactionFilterProvider = StateNotifierProvider<TransactionFilterNotifier, TransactionFilter>((ref) {
  return TransactionFilterNotifier();
});

class TransactionFilterNotifier extends StateNotifier<TransactionFilter> {
  TransactionFilterNotifier() : super(TransactionFilter());

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setType(String? type) {
    state = state.copyWith(type: type);
  }

  void setCategory(int? categoryId) {
    state = state.copyWith(categoryId: categoryId);
  }

  void setSortOrder(String sortOrder) {
    state = state.copyWith(sortOrder: sortOrder);
  }

  void reset() {
    state = TransactionFilter();
  }
}

/// Filtered transactions provider
final filteredTransactionsProvider = Provider<AsyncValue<List<Transaction>>>((ref) {
  final transactionsAsync = ref.watch(transactionsProvider);
  final filter = ref.watch(transactionFilterProvider);

  return transactionsAsync.whenData((transactions) {
    var filtered = transactions.where((t) {
      // Search filter
      if (filter.searchQuery.isNotEmpty) {
        final query = filter.searchQuery.toLowerCase();
        final matchesSearch = t.description?.toLowerCase().contains(query) == true ||
            t.category.name.toLowerCase().contains(query) ||
            t.location?.toLowerCase().contains(query) == true;
        if (!matchesSearch) return false;
      }

      // Type filter
      if (filter.type != null && t.type != filter.type) {
        return false;
      }

      // Category filter
      if (filter.categoryId != null && t.category.id != filter.categoryId) {
        return false;
      }

      return true;
    }).toList();

    // Sort
    filtered.sort((a, b) {
      final dateA = DateTime.parse(a.transactionDate);
      final dateB = DateTime.parse(b.transactionDate);
      return filter.sortOrder == 'newest'
          ? dateB.compareTo(dateA)
          : dateA.compareTo(dateB);
    });

    return filtered;
  });
});
