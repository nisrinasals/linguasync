class QuizModel {
  final int id;
  final int languageId;
  final String question;
  final String optA;
  final String optB;
  final String optC;
  final String optD;
  final String answer;

  QuizModel({
    required this.id,
    required this.languageId,
    required this.question,
    required this.optA,
    required this.optB,
    required this.optC,
    required this.optD,
    required this.answer,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id'] as int,
      languageId: json['language_id'] as int,
      question: json['question'] as String,
      optA: (json['option_a'] ?? json['opt_a']) as String,
      optB: (json['option_b'] ?? json['opt_b']) as String,
      optC: (json['option_c'] ?? json['opt_c']) as String,
      optD: (json['option_d'] ?? json['opt_d']) as String,
      answer: (json['correct_answer'] ?? json['answer']) as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'language_id': languageId,
      'question': question,
      'opt_a': optA,
      'opt_b': optB,
      'opt_c': optC,
      'opt_d': optD,
      'answer': answer,
    };
  }
}
