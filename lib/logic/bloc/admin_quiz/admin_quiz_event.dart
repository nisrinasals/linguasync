import 'package:equatable/equatable.dart';

abstract class AdminQuizEvent extends Equatable {
  const AdminQuizEvent();

  @override
  List<Object?> get props => [];
}

class FetchAdminQuizzes extends AdminQuizEvent {
  final int languageId;
  final String search;
  final bool isRefresh;

  const FetchAdminQuizzes({
    required this.languageId,
    this.search = '',
    required this.isRefresh,
  });

  @override
  List<Object?> get props => [languageId, search, isRefresh];
}

class CreateQuizQuestionRequested extends AdminQuizEvent {
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

class UpdateQuizQuestionRequested extends AdminQuizEvent {
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

class DeleteQuizQuestionRequested extends AdminQuizEvent {
  final int id;

  const DeleteQuizQuestionRequested({required this.id});

  @override
  List<Object?> get props => [id];
}
