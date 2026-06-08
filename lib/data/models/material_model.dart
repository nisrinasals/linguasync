class MaterialModel {
  final int id;
  final int languageId;
  final String title;
  final String content;
  final int order;

  MaterialModel({
    required this.id,
    required this.languageId,
    required this.title,
    required this.content,
    required this.order,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id'] as int,
      languageId: json['language_id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      order: json['order'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'language_id': languageId,
      'title': title,
      'content': content,
      'order': order,
    };
  }
}
