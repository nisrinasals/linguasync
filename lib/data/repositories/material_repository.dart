import 'dart:convert';
import '../models/material_model.dart';
import '../provider/storage_provider.dart';
import 'base_repository.dart';

class MaterialRepository extends BaseRepository {
  final StorageProvider storageProvider;

  MaterialRepository({required this.storageProvider});

  Future<Map<String, dynamic>> getMaterialsByLanguage(
    int languageId,
    int page, {
    String search = '',
  }) async {
    final response = await storageProvider.get(
      '/materials?language_id=$languageId&page=$page&limit=10&search=${Uri.encodeComponent(search)}',
    );
    handleError(response);
    final body = jsonDecode(response.body);
    final List<dynamic> rawList = body['data'];
    final materials = rawList
        .map((json) => MaterialModel.fromJson(json))
        .toList();
    return {
      'totalPages': body['totalPages'] as int,
      'totalItems': body['totalItems'] as int,
      'data': materials,
    };
  }

  Future<MaterialModel> getMaterialById(int id) async {
    final response = await storageProvider.get('/materials/$id');
    handleError(response);
    final body = jsonDecode(response.body);
    return MaterialModel.fromJson(body['data']);
  }

  Future<MaterialModel> createMaterial(
    int languageId,
    String title,
    String content,
    int order,
  ) async {
    final response = await storageProvider.post('/materials/admin', {
      'language_id': languageId,
      'title': title,
      'content': content,
      'order': order,
    });
    handleError(response);
    final body = jsonDecode(response.body);
    return MaterialModel.fromJson(body['data']);
  }

  Future<MaterialModel> updateMaterial(
    int id,
    String title,
    String content,
    int order,
  ) async {
    final response = await storageProvider.put('/materials/admin/$id', {
      'title': title,
      'content': content,
      'order': order,
    });
    handleError(response);
    final body = jsonDecode(response.body);
    return MaterialModel.fromJson(body['data']);
  }

  Future<String> deleteMaterial(int id) async {
    final response = await storageProvider.delete('/materials/admin/$id');
    handleError(response);
    final body = jsonDecode(response.body);
    return body['message'] ?? 'Materi berhasil dihapus.';
  }
}
