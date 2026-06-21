import 'package:equatable/equatable.dart';

abstract class AdminLanguageState extends Equatable {
  const AdminLanguageState();

  @override
  List<Object?> get props => [];
}

class AdminLanguageInitial extends AdminLanguageState {}

class AdminLanguageLoading extends AdminLanguageState {}

class AdminLanguageOperationSuccess extends AdminLanguageState {
  final String message;

  const AdminLanguageOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class AdminLanguageFailure extends AdminLanguageState {
  final String error;

  const AdminLanguageFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
