import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/language_repository.dart';
import '../../../data/models/language_model.dart';
import 'language_event.dart';
import 'language_state.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  final LanguageRepository languageRepository;

  LanguageBloc({required this.languageRepository}) : super(LanguageInitial()) {
    on<FetchLanguages>(_onFetchLanguages);
    on<FetchMyLanguages>(_onFetchMyLanguages);
    on<EnrollLanguageRequested>(_onEnrollLanguageRequested);
    on<UnenrollLanguageRequested>(_onUnenrollLanguageRequested);
    on<ResetLanguageData>(_onResetLanguageData);
  }

  Future<void> _onFetchLanguages(
    FetchLanguages event,
    Emitter<LanguageState> emit,
  ) async {
    final currentState = state;

    if (!event.isRefresh && currentState is LanguageExploreLoaded) {
      if (currentState.search == event.search && currentState.hasReachedMax)
        return;

      try {
        final pageToFetch = currentState.currentPage + 1;
        final result = await languageRepository.exploreLanguages(
          pageToFetch,
          search: event.search,
        );
        final languages = result['data'] as List<LanguageModel>;
        final totalPages = result['totalPages'] as int;

        emit(
          currentState.copyWith(
            languages: List.of(currentState.languages)..addAll(languages),
            currentPage: pageToFetch,
            hasReachedMax: pageToFetch >= totalPages,
          ),
        );
      } catch (e) {
        emit(
          LanguageFailure(error: e.toString().replaceAll('Exception: ', '')),
        );
      }
    } else {
      emit(LanguageLoading());
      try {
        final result = await languageRepository.exploreLanguages(
          1,
          search: event.search,
        );
        final languages = result['data'] as List<LanguageModel>;
        final totalPages = result['totalPages'] as int;

        emit(
          LanguageExploreLoaded(
            languages: languages,
            currentPage: 1,
            hasReachedMax: 1 >= totalPages,
            search: event.search,
          ),
        );
      } catch (e) {
        emit(
          LanguageFailure(error: e.toString().replaceAll('Exception: ', '')),
        );
      }
    }
  }

  Future<void> _onFetchMyLanguages(
    FetchMyLanguages event,
    Emitter<LanguageState> emit,
  ) async {
    final currentState = state;

    if (!event.isRefresh && currentState is LanguageMyStudyLoaded) {
      if (currentState.hasReachedMax) return;

      try {
        final pageToFetch = currentState.currentPage + 1;
        final result = await languageRepository.getMyLanguages(pageToFetch);
        final myLanguages = result['data'] as List<LanguageModel>;
        final totalPages = result['totalPages'] as int;

        emit(
          currentState.copyWith(
            myLanguages: List.of(currentState.myLanguages)..addAll(myLanguages),
            currentPage: pageToFetch,
            hasReachedMax: pageToFetch >= totalPages,
          ),
        );
      } catch (e) {
        emit(
          LanguageFailure(error: e.toString().replaceAll('Exception: ', '')),
        );
      }
    } else {
      emit(LanguageLoading());
      try {
        final result = await languageRepository.getMyLanguages(1);
        final myLanguages = result['data'] as List<LanguageModel>;
        final totalPages = result['totalPages'] as int;

        emit(
          LanguageMyStudyLoaded(
            myLanguages: myLanguages,
            currentPage: 1,
            hasReachedMax: 1 >= totalPages,
          ),
        );
      } catch (e) {
        emit(
          LanguageFailure(error: e.toString().replaceAll('Exception: ', '')),
        );
      }
    }
  }

  Future<void> _onEnrollLanguageRequested(
    EnrollLanguageRequested event,
    Emitter<LanguageState> emit,
  ) async {
    emit(LanguageLoading());
    try {
      final message = await languageRepository.enrollLanguage(event.languageId);
      emit(LanguageOperationSuccess(message: message));
    } catch (e) {
      emit(LanguageFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUnenrollLanguageRequested(
    UnenrollLanguageRequested event,
    Emitter<LanguageState> emit,
  ) async {
    emit(LanguageLoading());
    try {
      final message = await languageRepository.unenrollLanguage(
        event.enrollmentId,
      );
      emit(LanguageOperationSuccess(message: message));
    } catch (e) {
      emit(LanguageFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onResetLanguageData(
    ResetLanguageData event,
    Emitter<LanguageState> emit,
  ) {
    emit(LanguageInitial());
  }
}
