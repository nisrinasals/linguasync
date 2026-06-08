import 'dart:convert';
import '../models/auth_model.dart';
import '../provider/storage_provider.dart';
import 'base_repository.dart';

class AuthRepository extends BaseRepository {
  final StorageProvider storageProvider;

  AuthRepository({required this.storageProvider});

  Future<AuthModel> login(String email, String password) async {
    final response = await storageProvider.post('/auth/login', {
      'email': email,
      'password': password,
    });
    handleError(response);
    final body = jsonDecode(response.body);
    final authModel = AuthModel.fromJson(body['data']);
    await storageProvider.writeToken(authModel.token);
    await storageProvider.writeRole(authModel.user.role);
    return authModel;
  }

  Future<String> register(String name, String email, String password) async {
    final response = await storageProvider.post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
    });
    handleError(response);
    final body = jsonDecode(response.body);
    return body['message'] ?? 'Pendaftaran berhasil.';
  }

  Future<void> logout() async {
    await storageProvider.clearAuthData();
  }
}
