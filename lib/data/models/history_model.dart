class HistoryModel {
  final int id;
  final int? userId;
  final String? userName;
  final String? userEmail;
  final int? languageId;
  final String? languageName;
  final double score;
  final String createdAt;

  HistoryModel({
    required this.id,
    this.userId,
    this.userName,
    this.userEmail,
    this.languageId,
    this.languageName,
    required this.score,
    required this.createdAt,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      id: json['id'] as int,
      userId: json['user_id'] as int?,
      userName: json['user_name'] as String?,
      userEmail: json['user_email'] as String?,
      languageId: json['language_id'] as int?,
      languageName: json['language_name'] as String?,
      score: (json['score'] as num).toDouble(),
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_email': userEmail,
      'language_id': languageId,
      'language_name': languageName,
      'score': score,
      'createdAt': createdAt,
    };
  }
}
