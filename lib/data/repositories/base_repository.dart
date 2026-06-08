import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class BaseRepository {
  void handleError(http.Response response) {
    if (response.statusCode >= 400) {
      try {
        final data = jsonDecode(response.body);
        throw Exception(
          data['message'] ?? 'Terjadi kesalahan sistem jaringan.',
        );
      } catch (e) {
        if (e is Exception) {
          rethrow;
        }
        throw Exception(
          'Server merespons dengan kode status: ${response.statusCode}',
        );
      }
    }
  }
}
