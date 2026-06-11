import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class BaseRepository {
  void handleError(http.Response response) {
    if (response.statusCode >= 400) {
      try {
        final data = jsonDecode(response.body);
        if (data['errors'] != null && data['errors'] is List) {
          final errorList = data['errors'] as List;
          final errorMessages = errorList.map((e) => e['message']).join('\n');
          throw Exception(errorMessages);
        }
        
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
