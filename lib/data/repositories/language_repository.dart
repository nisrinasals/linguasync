import 'dart:convert';
import '../models/language_model.dart';
import '../provider/storage_provider.dart';
import 'base_repository.dart';

class LanguageRepository extends BaseRepository {
  final StorageProvider storageProvider;

  LanguageRepository({required this.storageProvider});

  Future<Map<String, dynamic>> exploreLanguages(
    int page, {
    int limit = 10,
    String search = '',
  }) async {
    final response = await storageProvider.get(
      '/languages?page=$page&limit=$limit&search=$search',
    );
    handleError(response);
    final body = jsonDecode(response.body);
    final List<dynamic> rawList = body['data'];
    final languages = rawList
        .map((json) => LanguageModel.fromJson(json))
        .toList();
    return {
      'totalPages': body['totalPages'] as int,
      'totalItems': body['totalItems'] as int,
      'data': languages,
    };
  }

  Future<String> enrollLanguage(int languageId) async {
    final response = await storageProvider.post('/languages/enroll', {
      'language_id': languageId,
    });
    handleError(response);
    final body = jsonDecode(response.body);
    return body['message'] ?? 'Berhasil mendaftar kelas bahasa.';
  }

  Future<Map<String, dynamic>> getMyLanguages(int page) async {
    final response = await storageProvider.get(
      '/languages/my-study?page=$page&limit=10',
    );
    handleError(response);
    final body = jsonDecode(response.body);
    final List<dynamic> rawList = body['data'];
    final languages = rawList
        .map((json) => LanguageModel.fromJson(json['Language']))
        .toList();
    return {
      'totalPages': body['totalPages'] as int,
      'totalItems': body['totalItems'] as int,
      'data': languages,
    };
  }

  Future<String> unenrollLanguage(int enrollmentId) async {
    final response = await storageProvider.delete(
      '/languages/my-study/$enrollmentId',
    );
    handleError(response);
    final body = jsonDecode(response.body);
    return body['message'] ?? 'Berhasil menghapus kelas studi.';
  }

  Future<LanguageModel> createLanguage(String name, String description) async {
    final response = await storageProvider.post('/languages/admin', {
      'name': name,
      'description': description,
    });
    handleError(response);
    final body = jsonDecode(response.body);
    return LanguageModel.fromJson(body['data']);
  }

  Future<LanguageModel> updateLanguage(
    int id,
    String name,
    String description,
  ) async {
    final response = await storageProvider.put('/languages/admin/$id', {
      'name': name,
      'description': description,
    });
    handleError(response);
    final body = jsonDecode(response.body);
    return LanguageModel.fromJson(body['data']);
  }

  Future<String> deleteLanguage(int id) async {
    final response = await storageProvider.delete('/languages/admin/$id');
    handleError(response);
    final body = jsonDecode(response.body);
    return body['message'] ?? 'Bahasa berhasil dihapus.';
  }
}
