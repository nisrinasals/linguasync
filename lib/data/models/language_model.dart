class LanguageModel {
  final int id;
  final String name;
  final String description;
  final bool isEnrolled;

  LanguageModel({
    required this.id,
    required this.name,
    required this.description,
    this.isEnrolled = false,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      isEnrolled: json['is_enrolled'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'description': description};
  }
}
