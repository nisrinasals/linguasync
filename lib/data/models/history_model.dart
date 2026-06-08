class HistoryModel {
  final int id;
  final String? languageName;
  final double score;
  final String createdAt;

  HistoryModel({
    required this.id,
    this.languageName,
    required this.score,
    required this.createdAt,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      id: json['id'] as int,
      languageName: json['language_name'] as String?,
      score: (json['score'] as num).toDouble(),
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'language_name': languageName,
      'score': score,
      'createdAt': createdAt,
    };
  }
}
