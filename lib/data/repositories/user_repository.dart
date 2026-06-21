import 'dart:convert';
import '../models/auth_model.dart';
import '../provider/storage_provider.dart';
import 'base_repository.dart';

class UserRepository extends BaseRepository {
  final StorageProvider storageProvider;

  UserRepository({required this.storageProvider});

  Future<Map<String, dynamic>> getUsers({
    int page = 1,
    int limit = 10,
    String search = '',
    String role = '',
  }) async {
    final response = await storageProvider.get(
      '/users?page=$page&limit=$limit&search=${Uri.encodeComponent(search)}&role=$role',
    );
    handleError(response);
    final body = jsonDecode(response.body);
    final List<dynamic> rawList = body['data'];
    final users = rawList.map((json) => UserModel.fromJson(json)).toList();
    return {
      'totalPages': body['totalPages'] as int,
      'totalItems': body['totalItems'] as int,
      'data': users,
    };
  }

  Future<UserModel> getUserById(int id) async {
    final response = await storageProvider.get('/users/$id');
    handleError(response);
    final body = jsonDecode(response.body);
    return UserModel.fromJson(body['data']);
  }

  Future<UserModel> createUser(
    String name,
    String email,
    String password,
    String role,
  ) async {
    final response = await storageProvider.post('/users', {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    });
    handleError(response);
    final body = jsonDecode(response.body);
    return UserModel.fromJson(body['data']);
  }

  Future<UserModel> updateUser({
    required int id,
    required String name,
    required String email,
    String? password,
    required String role,
  }) async {
    final bodyData = {
      'name': name,
      'email': email,
      'role': role,
      if (password != null && password.trim().isNotEmpty) 'password': password,
    };
    final response = await storageProvider.put('/users/$id', bodyData);
    handleError(response);
    final body = jsonDecode(response.body);
    return UserModel.fromJson(body['data']);
  }

  Future<String> deleteUser(int id) async {
    final response = await storageProvider.delete('/users/$id');
    handleError(response);
    final body = jsonDecode(response.body);
    return body['message'] ?? 'Pengguna berhasil dihapus.';
  }
}
