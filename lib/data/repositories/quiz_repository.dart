import 'dart:convert';
import '../models/quiz_model.dart';
import '../provider/storage_provider.dart';
import 'base_repository.dart';

class QuizRepository extends BaseRepository {
  final StorageProvider storageProvider;

  QuizRepository({required this.storageProvider});

  Future<List<QuizModel>> getQuestionsByLanguage(int languageId) async {
    final response = await storageProvider.get(
      '/quizzes?language_id=$languageId',
    );
    handleError(response);
    final body = jsonDecode(response.body);
    final List<dynamic> rawList = body['data'];
    return rawList.map((json) => QuizModel.fromJson(json)).toList();
  }

  Future<String> submitQuizResult(int languageId, double score) async {
    final response = await storageProvider.post('/quizzes/submit', {
      'language_id': languageId,
      'score': score,
    });
    handleError(response);
    final body = jsonDecode(response.body);
    return body['message'] ?? 'Hasil kuis berhasil disimpan.';
  }

  Future<Map<String, dynamic>> adminGetQuestions(
    int languageId,
    int page, {
    String search = '',
  }) async {
    final response = await storageProvider.get(
      '/quizzes/admin?language_id=$languageId&page=$page&limit=10&search=$search',
    );
    handleError(response);
    final body = jsonDecode(response.body);
    final List<dynamic> rawList = body['data'];
    final questions = rawList.map((json) => QuizModel.fromJson(json)).toList();
    return {
      'totalPages': body['totalPages'] as int,
      'totalItems': body['totalItems'] as int,
      'data': questions,
    };
  }

  Future<QuizModel> adminCreateQuestion(
    int languageId,
    String question,
    String optA,
    String optB,
    String optC,
    String optD,
    String answer,
  ) async {
    final response = await storageProvider.post('/quizzes/admin', {
      'language_id': languageId,
      'question': question,
      'opt_a': optA,
      'opt_b': optB,
      'opt_c': optC,
      'opt_d': optD,
      'answer': answer,
    });
    handleError(response);
    final body = jsonDecode(response.body);
    return QuizModel.fromJson(body['data']);
  }

  Future<QuizModel> adminUpdateQuestion(
    int id,
    String question,
    String optA,
    String optB,
    String optC,
    String optD,
    String answer,
  ) async {
    final response = await storageProvider.put('/quizzes/admin/$id', {
      'question': question,
      'opt_a': optA,
      'opt_b': optB,
      'opt_c': optC,
      'opt_d': optD,
      'answer': answer,
    });
    handleError(response);
    final body = jsonDecode(response.body);
    return QuizModel.fromJson(body['data']);
  }

  Future<String> adminDeleteQuestion(int id) async {
    final response = await storageProvider.delete('/quizzes/admin/$id');
    handleError(response);
    final body = jsonDecode(response.body);
    return body['message'] ?? 'Pertanyaan kuis berhasil dihapus.';
  }
}
