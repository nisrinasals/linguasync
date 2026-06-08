import 'dart:convert';
import '../models/history_model.dart';
import '../provider/storage_provider.dart';
import 'base_repository.dart';

class HistoryRepository extends BaseRepository {
  final StorageProvider storageProvider;

  HistoryRepository({required this.storageProvider});

  Future<Map<String, dynamic>> getUserHistory(int page) async {
    final response = await storageProvider.get('/history?page=$page&limit=10');
    handleError(response);
    final body = jsonDecode(response.body);
    final List<dynamic> rawList = body['data'];
    final histories = rawList
        .map((json) => HistoryModel.fromJson(json))
        .toList();
    return {
      'totalPages': body['totalPages'] as int,
      'totalItems': body['totalItems'] as int,
      'data': histories,
    };
  }
}
