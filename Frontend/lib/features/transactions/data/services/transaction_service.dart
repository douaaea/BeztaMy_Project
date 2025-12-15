import '../../../../core/network/api_client.dart';
import '../models/transaction.dart';
import '../models/transaction_request.dart';

class TransactionService {
  final ApiClient _apiClient;

  TransactionService(this._apiClient);

  /// Get transactions with optional filters
  Future<List<Transaction>> getTransactions(
    int userId, {
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
    String? type,
  }) async {
    final queryParams = {'userId': userId.toString()};
    
    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String().split('T')[0];
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String().split('T')[0];
    }
    if (categoryId != null) {
      queryParams['categoryId'] = categoryId.toString();
    }
    if (type != null) {
      queryParams['type'] = type;
    }

    final response = await _apiClient.get(
      '/transactions',
      queryParameters: queryParams,
    );
    
    return (response.data as List)
        .map((json) => Transaction.fromJson(json))
        .toList();
  }

  /// Get transaction by ID
  Future<Transaction> getTransactionById(int id) async {
    final response = await _apiClient.get('/transactions/$id');
    return Transaction.fromJson(response.data);
  }

  /// Create a new transaction
  Future<Transaction> createTransaction(int userId, TransactionRequest request) async {
    final response = await _apiClient.post(
      '/transactions',
      queryParameters: {'userId': userId.toString()},
      data: request.toJson(),
    );
    return Transaction.fromJson(response.data);
  }

  /// Update a transaction
  Future<Transaction> updateTransaction(int id, TransactionRequest request) async {
    final response = await _apiClient.put(
      '/transactions/$id',
      data: request.toJson(),
    );
    return Transaction.fromJson(response.data);
  }

  /// Delete a transaction
  Future<void> deleteTransaction(int id) async {
    await _apiClient.delete('/transactions/$id');
  }
}
