import 'package:equatable/equatable.dart';
import '../../../data/models/language_model.dart';

abstract class LanguageState extends Equatable {
  const LanguageState();

  @override
  List<Object?> get props => [];
}

class LanguageInitial extends LanguageState {}

class LanguageLoading extends LanguageState {}

class LanguageExploreLoaded extends LanguageState {
  final List<LanguageModel> languages;
  final int currentPage;
  final bool hasReachedMax;
  final String search;

  const LanguageExploreLoaded({
    required this.languages,
    required this.currentPage,
    required this.hasReachedMax,
    required this.search,
  });

  LanguageExploreLoaded copyWith({
    List<LanguageModel>? languages,
    int? currentPage,
    bool? hasReachedMax,
    String? search,
  }) {
    return LanguageExploreLoaded(
      languages: languages ?? this.languages,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      search: search ?? this.search,
    );
  }

  @override
  List<Object?> get props => [languages, currentPage, hasReachedMax, search];
}

class LanguageMyStudyLoaded extends LanguageState {
  final List<LanguageModel> myLanguages;
  final int currentPage;
  final bool hasReachedMax;

  const LanguageMyStudyLoaded({
    required this.myLanguages,
    required this.currentPage,
    required this.hasReachedMax,
  });

  LanguageMyStudyLoaded copyWith({
    List<LanguageModel>? myLanguages,
    int? currentPage,
    bool? hasReachedMax,
  }) {
    return LanguageMyStudyLoaded(
      myLanguages: myLanguages ?? this.myLanguages,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [myLanguages, currentPage, hasReachedMax];
}

class LanguageOperationSuccess extends LanguageState {
  final String message;

  const LanguageOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class LanguageFailure extends LanguageState {
  final String error;

  const LanguageFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
