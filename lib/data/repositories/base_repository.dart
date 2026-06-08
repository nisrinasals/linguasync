import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class BaseRepository {
  void handleError(http.Response response) {
    if (response.statusCode >= 400) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Terjadi kesalahan pada sistem jaringan.');
    }
  }
}