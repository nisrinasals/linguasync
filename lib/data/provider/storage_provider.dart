import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> get(String endpoint) async {
    final token = await readToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    return await http.get(Uri.parse('$baseUrl$endpoint'), headers: headers);
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final token = await readToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    return await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> delete(String endpoint) async {
    final token = await readToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    return await http.delete(Uri.parse('$baseUrl$endpoint'), headers: headers);
  }
}
