import 'package:equatable/equatable.dart';
import '../../../data/models/quiz_model.dart';

abstract class AdminQuizState extends Equatable {
  const AdminQuizState();

  @override
  List<Object?> get props => [];
}

class AdminQuizInitial extends AdminQuizState {}

class AdminQuizLoading extends AdminQuizState {}

class AdminQuizListLoaded extends AdminQuizState {
  final List<QuizModel> questions;
  final int currentPage;
  final bool hasReachedMax;
  final int languageId;
  final String search;

  const AdminQuizListLoaded({
    required this.questions,
    required this.currentPage,
    required this.hasReachedMax,
    required this.languageId,
    required this.search,
  });

  @override
  List<Object?> get props => [
        questions,
        currentPage,
        hasReachedMax,
        languageId,
        search,
      ];

  AdminQuizListLoaded copyWith({
    List<QuizModel>? questions,
    int? currentPage,
    bool? hasReachedMax,
    int? languageId,
    String? search,
  }) {
    return AdminQuizListLoaded(
      questions: questions ?? this.questions,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      languageId: languageId ?? this.languageId,
      search: search ?? this.search,
    );
  }
}

class AdminQuizOperationSuccess extends AdminQuizState {
  final String message;

  const AdminQuizOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class AdminQuizFailure extends AdminQuizState {
  final String error;

  const AdminQuizFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
