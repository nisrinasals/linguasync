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

  const SubmitQuizResultRequested({
    required this.languageId,
    required this.score,
  });

  @override
  List<Object?> get props => [languageId, score];
}

class ResetQuizData extends QuizEvent {}
