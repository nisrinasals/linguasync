class LeaderboardModel {
  final int rank;
  final int userId;
  final String name;
  final double totalScore;

  LeaderboardModel({
    required this.rank,
    required this.userId,
    required this.name,
    required this.totalScore,
  });

  factory LeaderboardModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardModel(
      rank: json['rank'] as int,
      userId: json['user_id'] as int,
      name: json['name'] as String,
      totalScore: (json['totalScore'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'user_id': userId,
      'name': name,
      'totalScore': totalScore,
    };
  }
}
