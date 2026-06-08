import 'package:equatable/equatable.dart';

abstract class LanguageEvent extends Equatable {
  const LanguageEvent();

  @override
  List<Object?> get props => [];
}

class FetchLanguages extends LanguageEvent {
  final String search;
  final bool isRefresh;

  const FetchLanguages({this.search = '', this.isRefresh = false});

  @override
  List<Object?> get props => [search, isRefresh];
}

class FetchMyLanguages extends LanguageEvent {
  final bool isRefresh;

  const FetchMyLanguages({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class EnrollLanguageRequested extends LanguageEvent {
  final int languageId;

  const EnrollLanguageRequested({required this.languageId});

  @override
  List<Object?> get props => [languageId];
}

class UnenrollLanguageRequested extends LanguageEvent {
  final int enrollmentId;

  const UnenrollLanguageRequested({required this.enrollmentId});

  @override
  List<Object?> get props => [enrollmentId];
}

class CreateLanguageRequested extends LanguageEvent {
  final String name;
  final String description;

  const CreateLanguageRequested({
    required this.name,
    required this.description,
  });

  @override
  List<Object?> get props => [name, description];
}

class UpdateLanguageRequested extends LanguageEvent {
  final int id;
  final String name;
  final String description;

  const UpdateLanguageRequested({
    required this.id,
    required this.name,
    required this.description,
  });

  @override
  List<Object?> get props => [id, name, description];
}

class DeleteLanguageRequested extends LanguageEvent {
  final int id;

  const DeleteLanguageRequested({required this.id});

  @override
  List<Object?> get props => [id];
}
