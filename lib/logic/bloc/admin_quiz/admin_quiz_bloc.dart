import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/quiz_repository.dart';
import '../../../data/models/quiz_model.dart';
import 'admin_quiz_event.dart';
import 'admin_quiz_state.dart';

class AdminQuizBloc extends Bloc<AdminQuizEvent, AdminQuizState> {
  final QuizRepository quizRepository;

  AdminQuizBloc({required this.quizRepository}) : super(AdminQuizInitial()) {
    on<FetchAdminQuizzes>(_onFetchAdminQuizzes);
    on<CreateQuizQuestionRequested>(_onCreateQuizQuestionRequested);
    on<UpdateQuizQuestionRequested>(_onUpdateQuizQuestionRequested);
    on<DeleteQuizQuestionRequested>(_onDeleteQuizQuestionRequested);
  }

  Future<void> _onFetchAdminQuizzes(
    FetchAdminQuizzes event,
    Emitter<AdminQuizState> emit,
  ) async {
    final currentState = state;

    bool shouldReset =
        event.isRefresh ||
        (currentState is AdminQuizListLoaded &&
            currentState.search != event.search);

    if (!shouldReset && currentState is AdminQuizListLoaded) {
      if (currentState.languageId == event.languageId &&
          currentState.hasReachedMax)
        return;

      try {
        final pageToFetch = currentState.currentPage + 1;
        final result = await quizRepository.adminGetQuestions(
          event.languageId,
          pageToFetch,
          search: currentState.search,
        );
        final questions = result['data'] as List<QuizModel>;
        final totalPages = result['totalPages'] as int;

        emit(
          currentState.copyWith(
            questions: List.of(currentState.questions)..addAll(questions),
            currentPage: pageToFetch,
            hasReachedMax: pageToFetch >= totalPages,
          ),
        );
      } catch (e) {
        emit(AdminQuizFailure(error: e.toString().replaceAll('Exception: ', '')));
      }
    } else {
      emit(AdminQuizLoading());
      try {
        final result = await quizRepository.adminGetQuestions(
          event.languageId,
          1,
          search: event.search,
        );
        final questions = result['data'] as List<QuizModel>;
        final totalPages = result['totalPages'] as int;

        emit(
          AdminQuizListLoaded(
            questions: questions,
            currentPage: 1,
            hasReachedMax: 1 >= totalPages,
            languageId: event.languageId,
            search: event.search,
          ),
        );
      } catch (e) {
        emit(AdminQuizFailure(error: e.toString().replaceAll('Exception: ', '')));
      }
    }
  }

  Future<void> _onCreateQuizQuestionRequested(
    CreateQuizQuestionRequested event,
    Emitter<AdminQuizState> emit,
  ) async {
    emit(AdminQuizLoading());
    final optA = event.optA.trim().toLowerCase();
    final optB = event.optB.trim().toLowerCase();
    final optC = event.optC.trim().toLowerCase();
    final optD = event.optD.trim().toLowerCase();

    final uniqueOptions = {optA, optB, optC, optD};
    if (uniqueOptions.length < 4) {
      emit(
        const AdminQuizFailure(
          error: 'Pilihan opsi jawaban (A, B, C, D) tidak boleh ada yang sama.',
        ),
      );
      return;
    }

    try {
      await quizRepository.adminCreateQuestion(
        event.languageId,
        event.question,
        event.optA,
        event.optB,
        event.optC,
        event.optD,
        event.answer,
      );
      emit(
        const AdminQuizOperationSuccess(
          message: 'Pertanyaan kuis baru berhasil ditambahkan.',
        ),
      );
    } catch (e) {
      emit(AdminQuizFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateQuizQuestionRequested(
    UpdateQuizQuestionRequested event,
    Emitter<AdminQuizState> emit,
  ) async {
    emit(AdminQuizLoading());
    final optA = event.optA.trim().toLowerCase();
    final optB = event.optB.trim().toLowerCase();
    final optC = event.optC.trim().toLowerCase();
    final optD = event.optD.trim().toLowerCase();

    final uniqueOptions = {optA, optB, optC, optD};
    if (uniqueOptions.length < 4) {
      emit(
        const AdminQuizFailure(
          error: 'Pilihan opsi jawaban (A, B, C, D) tidak boleh ada yang sama.',
        ),
      );
      return;
    }

    try {
      await quizRepository.adminUpdateQuestion(
        event.id,
        event.question,
        event.optA,
        event.optB,
        event.optC,
        event.optD,
        event.answer,
      );
      emit(
        const AdminQuizOperationSuccess(
          message: 'Pertanyaan kuis berhasil diperbarui.',
        ),
      );
    } catch (e) {
      emit(AdminQuizFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDeleteQuizQuestionRequested(
    DeleteQuizQuestionRequested event,
    Emitter<AdminQuizState> emit,
  ) async {
    emit(AdminQuizLoading());
    try {
      final message = await quizRepository.adminDeleteQuestion(event.id);
      emit(AdminQuizOperationSuccess(message: message));
    } catch (e) {
      emit(AdminQuizFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
