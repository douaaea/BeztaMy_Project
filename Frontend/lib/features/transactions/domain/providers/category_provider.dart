import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../data/models/category.dart';
import '../../data/services/category_service.dart';

/// Category service provider
final categoryServiceProvider = Provider<CategoryService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CategoryService(apiClient);
});

/// Categories provider - loads all categories for current user
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final categoryService = ref.watch(categoryServiceProvider);
  final userId = ref.watch(userIdProvider);
  
  if (userId == null) {
    throw Exception('User not authenticated');
  }

  return await categoryService.getCategories(userId);
});

/// Expense categories provider
final expenseCategoriesProvider = Provider<List<Category>>((ref) {
  final categories = ref.watch(categoriesProvider);
  
  return categories.when(
    data: (cats) => cats.where((c) => c.type == 'EXPENSE').toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Income categories provider
final incomeCategoriesProvider = Provider<List<Category>>((ref) {
  final categories = ref.watch(categoriesProvider);
  
  return categories.when(
    data: (cats) => cats.where((c) => c.type == 'INCOME').toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});
