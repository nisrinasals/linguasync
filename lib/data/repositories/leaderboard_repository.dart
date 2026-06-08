import 'dart:convert';
import '../models/leaderboard_model.dart';
import '../provider/storage_provider.dart';
import 'base_repository.dart';

class LeaderboardRepository extends BaseRepository {
  final StorageProvider storageProvider;

  LeaderboardRepository({required this.storageProvider});

  Future<Map<String, dynamic>> getGlobalLeaderboard(int page) async {
    final response = await storageProvider.get(
      '/leaderboard?page=$page&limit=10',
    );
    handleError(response);
    final body = jsonDecode(response.body);
    final List<dynamic> rawList = body['data'];
    final rankings = rawList
        .map((json) => LeaderboardModel.fromJson(json))
        .toList();
    return {
      'totalPages': body['totalPages'] as int,
      'totalItems': body['totalItems'] as int,
      'currentUserRank': body['currentUser']['rank'] as int?,
      'currentUserScore': (body['currentUser']['totalScore'] as num).toDouble(),
      'data': rankings,
    };
  }
}
