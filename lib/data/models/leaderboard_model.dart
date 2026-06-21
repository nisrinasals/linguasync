class LeaderboardModel {
  final int rank;
  final int userId;
  final String name;
  final String? fotoProfile;
  final double totalScore;

  LeaderboardModel({
    required this.rank,
    required this.userId,
    required this.name,
    this.fotoProfile,
    required this.totalScore,
  });

  factory LeaderboardModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardModel(
      rank: json['rank'] as int,
      userId: json['user_id'] as int,
      name: json['name'] as String,
      fotoProfile: json['foto_profile'] as String?,
      totalScore: (json['totalScore'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'user_id': userId,
      'name': name,
      'foto_profile': fotoProfile,
      'totalScore': totalScore,
    };
  }
}
