import 'package:equatable/equatable.dart';

abstract class QuizEvent extends Equatable {
  const QuizEvent();

  @override
  List<Object?> get props => [];
}

class StartQuiz extends QuizEvent {
  final int languageId;

  const StartQuiz({required this.languageId});

  @override
  List<Object?> get props => [languageId];
}

class QuizTimerTicked extends QuizEvent {
  final int duration;

  const QuizTimerTicked({required this.duration});

  @override
  List<Object?> get props => [duration];
}

class AnswerSelected extends QuizEvent {
  final String selectedOption;

  const AnswerSelected({required this.selectedOption});

  @override
  List<Object?> get props => [selectedOption];
}

class SubmitQuizResultRequested extends QuizEvent {
  final int languageId;
  final double score;

  const SubmitQuizResultRequested({required this.languageId, required this.score});

  @override
  List<Object?> get props => [languageId, score];
}

class FetchAdminQuizzes extends QuizEvent {
  final int languageId;
  final bool isRefresh;

  const FetchAdminQuizzes({required this.languageId, this.isRefresh = false});

  @override
  List<Object?> get props => [languageId, isRefresh];
}

class CreateQuizQuestionRequested extends QuizEvent {
  final int languageId;
  final String question;
  final String optA;
  final String optB;
  final String optC;
  final String optD;
  final String answer;

  const CreateQuizQuestionRequested({
    required this.languageId,
    required this.question,
    required this.optA,
    required this.optB,
    required this.optC,
    required this.optD,
    required this.answer,
  });

  @override
  List<Object?> get props => [languageId, question, optA, optB, optC, optD, answer];
}

class UpdateQuizQuestionRequested extends QuizEvent {
  final int id;
  final String question;
  final String optA;
  final String optB;
  final String optC;
  final String optD;
  final String answer;

  const UpdateQuizQuestionRequested({
    required this.id,
    required this.question,
    required this.optA,
    required this.optB,
    required this.optC,
    required this.optD,
    required this.answer,
  });

  @override
  List<Object?> get props => [id, question, optA, optB, optC, optD, answer];
}

class DeleteQuizQuestionRequested extends QuizEvent {
  final int id;

  const DeleteQuizQuestionRequested({required this.id});

  @override
  List<Object?> get props => [id];
}