import 'package:equatable/equatable.dart';
import '../../../data/models/quiz_model.dart';

abstract class QuizState extends Equatable {
  const QuizState();

  @override
  List<Object?> get props => [];
}

class QuizInitial extends QuizState {}

class QuizLoading extends QuizState {}

class QuizQuestionActive extends QuizState {
  final List<QuizModel> questions;
  final int currentIndex;
  final int remainingSeconds;
  final int correctAnswersCount;

  const QuizQuestionActive({
    required this.questions,
    required this.currentIndex,
    required this.remainingSeconds,
    required this.correctAnswersCount,
  });

  QuizQuestionActive copyWith({
    List<QuizModel>? questions,
    int? currentIndex,
    int? remainingSeconds,
    int? correctAnswersCount,
  }) {
    return QuizQuestionActive(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      correctAnswersCount: correctAnswersCount ?? this.correctAnswersCount,
    );
  }

  @override
  List<Object?> get props => [questions, currentIndex, remainingSeconds, correctAnswersCount];
}

class QuizFinished extends QuizState {
  final double score;
  final int totalQuestions;
  final int correctAnswers;

  const QuizFinished({
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
  });

  @override
  List<Object?> get props => [score, totalQuestions, correctAnswers];
}

class QuizAdminListLoaded extends QuizState {
  final List<QuizModel> questions;
  final int currentPage;
  final bool hasReachedMax;
  final int languageId;

  const QuizAdminListLoaded({
    required this.questions,
    required this.currentPage,
    required this.hasReachedMax,
    required this.languageId,
  });

  QuizAdminListLoaded copyWith({
    List<QuizModel>? questions,
    int? currentPage,
    bool? hasReachedMax,
    int? languageId,
  }) {
    return QuizAdminListLoaded(
      questions: questions ?? this.questions,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      languageId: languageId ?? this.languageId,
    );
  }

  @override
  List<Object?> get props => [questions, currentPage, hasReachedMax, languageId];
}

class QuizOperationSuccess extends QuizState {
  final String message;

  const QuizOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class QuizFailure extends QuizState {
  final String error;

  const QuizFailure({required this.error});

  @override
  List<Object?> get props => [error];
}