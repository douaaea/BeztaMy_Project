import '../../../../core/network/api_client.dart';
import '../models/category.dart';
import '../models/category_request.dart';

class CategoryService {
  final ApiClient _apiClient;

  CategoryService(this._apiClient);

  /// Get categories for user
  Future<List<Category>> getCategories(int userId, {String? type}) async {
    final queryParams = {'userId': userId.toString()};
    if (type != null) {
      queryParams['type'] = type;
    }

    final response = await _apiClient.get(
      '/categories',
      queryParameters: queryParams,
    );

    return (response.data as List)
        .map((json) => Category.fromJson(json))
        .toList();
  }

  /// Create a new category
  Future<Category> createCategory(int userId, CategoryRequest request) async {
    final response = await _apiClient.post(
      '/categories',
      queryParameters: {'userId': userId.toString()},
      data: request.toJson(),
    );

    return Category.fromJson(response.data);
  }

  /// Update a category
  Future<Category> updateCategory(int id, int userId, CategoryRequest request) async {
    final response = await _apiClient.put(
      '/categories/$id',
      queryParameters: {'userId': userId.toString()},
      data: request.toJson(),
    );

    return Category.fromJson(response.data);
  }

  /// Delete a category
  Future<void> deleteCategory(int id, int userId) async {
    await _apiClient.delete(
      '/categories/$id',
      queryParameters: {'userId': userId.toString()},
    );
  }
}
