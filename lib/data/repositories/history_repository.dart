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

  Future<Map<String, dynamic>> getHistoriesAdmin(
    int page, {
    String search = '',
    int? languageId,
  }) async {
    final langQuery = languageId != null ? '&language_id=$languageId' : '';
    final response = await storageProvider.get(
      '/history/admin?page=$page&limit=10&search=${Uri.encodeComponent(search)}$langQuery',
    );
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

  Future<HistoryModel> createHistoryAdmin({
    required int userId,
    required int languageId,
    required double score,
  }) async {
    final response = await storageProvider.post('/history/admin', {
      'user_id': userId,
      'language_id': languageId,
      'score': score,
    });
    handleError(response);
    final body = jsonDecode(response.body);
    return HistoryModel.fromJson(body['data']);
  }

  Future<HistoryModel> updateHistoryAdmin(
    int id, {
    required int userId,
    required int languageId,
    required double score,
  }) async {
    final response = await storageProvider.put('/history/admin/$id', {
      'user_id': userId,
      'language_id': languageId,
      'score': score,
    });
    handleError(response);
    final body = jsonDecode(response.body);
    return HistoryModel.fromJson(body['data']);
  }

  Future<String> deleteHistoryAdmin(int id) async {
    final response = await storageProvider.delete('/history/admin/$id');
    handleError(response);
    final body = jsonDecode(response.body);
    return body['message'] ?? 'Riwayat kuis berhasil dihapus.';
  }
}
