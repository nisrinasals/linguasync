class LanguageModel {
  final int id;
  final String name;
  final String description;

  LanguageModel({
    required this.id,
    required this.name,
    required this.description,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'description': description};
  }
}
