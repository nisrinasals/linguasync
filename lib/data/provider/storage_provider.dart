import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;

class StorageProvider {
  final String baseUrl = 'http://10.0.2.2:3000/api';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> writeToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  Future<void> writeRole(String role) async {
    await _storage.write(key: 'user_role', value: role);
  }

  Future<String?> readToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<String?> readRole() async {
    return await _storage.read(key: 'user_role');
  }

  Future<void> clearAuthData() async {
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'user_role');
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final token = await readToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    try {
      return await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));
    } catch (e) {
      if (e is SocketException || e is TimeoutException || e.toString().contains('Connection refused')) {
        throw Exception('Tidak dapat terhubung ke server. Periksa koneksi Anda.');
      }
      rethrow;
    }
  }

  Future<http.Response> get(String endpoint) async {
    final token = await readToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    try {
      return await http.get(Uri.parse('$baseUrl$endpoint'), headers: headers).timeout(const Duration(seconds: 10));
    } catch (e) {
      if (e is SocketException || e is TimeoutException || e.toString().contains('Connection refused')) {
        throw Exception('Tidak dapat terhubung ke server. Periksa koneksi Anda.');
      }
      rethrow;
    }
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final token = await readToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    try {
      return await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));
    } catch (e) {
      if (e is SocketException || e is TimeoutException || e.toString().contains('Connection refused')) {
        throw Exception('Tidak dapat terhubung ke server. Periksa koneksi Anda.');
      }
      rethrow;
    }
  }

  Future<http.Response> delete(String endpoint) async {
    final token = await readToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    try {
      return await http.delete(Uri.parse('$baseUrl$endpoint'), headers: headers).timeout(const Duration(seconds: 10));
    } catch (e) {
      if (e is SocketException || e is TimeoutException || e.toString().contains('Connection refused')) {
        throw Exception('Tidak dapat terhubung ke server. Periksa koneksi Anda.');
      }
      rethrow;
    }
  }

  String getProfileImageUrl(String? filename) {
    if (filename == null || filename.isEmpty) return '';
    final base = baseUrl.replaceAll('/api', '');
    return '$base/uploads/$filename';
  }

  Future<http.Response> uploadProfilePicture({
    required String name,
    required String email,
    String? password,
    String? oldPassword,
    String? filePath,
  }) async {
    final token = await readToken();
    final uri = Uri.parse('$baseUrl/auth/profile');
    final request = http.MultipartRequest('PUT', uri);

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields['name'] = name;
    request.fields['email'] = email;
    if (password != null && password.isNotEmpty) {
      request.fields['password'] = password;
    }
    if (oldPassword != null && oldPassword.isNotEmpty) {
      request.fields['old_password'] = oldPassword;
    }

    if (filePath != null && filePath.isNotEmpty) {
      final ext = p.extension(filePath).replaceAll('.', '');
      final file = await http.MultipartFile.fromPath(
        'foto_profile',
        filePath,
        contentType: MediaType('image', ext.isEmpty ? 'jpeg' : ext),
      );
      request.files.add(file);
    }

    try {
      final streamedResponse = await request.send().timeout(const Duration(seconds: 15));
      return await http.Response.fromStream(streamedResponse);
    } catch (e) {
      if (e is SocketException || e is TimeoutException || e.toString().contains('Connection refused')) {
        throw Exception('Tidak dapat terhubung ke server. Periksa koneksi Anda.');
      }
      rethrow;
    }
  }
}
