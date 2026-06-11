import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/quiz_repository.dart';
import '../../../data/models/quiz_model.dart';
import 'quiz_event.dart';
import 'quiz_state.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final QuizRepository quizRepository;
  StreamSubscription<int>? _timerSubscription;

  QuizBloc({required this.quizRepository}) : super(QuizInitial()) {
    on<StartQuiz>(_onStartQuiz);
    on<QuizTimerTicked>(_onQuizTimerTicked);
    on<AnswerSelected>(_onAnswerSelected);
    on<SubmitQuizResultRequested>(_onSubmitQuizResultRequested);
    on<FetchAdminQuizzes>(_onFetchAdminQuizzes);
    on<CreateQuizQuestionRequested>(_onCreateQuizQuestionRequested);
    on<UpdateQuizQuestionRequested>(_onUpdateQuizQuestionRequested);
    on<DeleteQuizQuestionRequested>(_onDeleteQuizQuestionRequested);
    on<ResetQuizData>(_onResetQuizData);
  }

  Future<void> _onStartQuiz(StartQuiz event, Emitter<QuizState> emit) async {
    emit(QuizLoading());
    try {
      final questions = await quizRepository.getQuestionsByLanguage(event.languageId);
      if (questions.isEmpty) {
        emit(const QuizFinished(score: 0.0, totalQuestions: 0, correctAnswers: 0));
      } else {
        emit(QuizQuestionActive(
          questions: questions,
          currentIndex: 0,
          remainingSeconds: 5,
          correctAnswersCount: 0,
        ));
        _startTimer();
      }
    } catch (e) {
      emit(QuizFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onQuizTimerTicked(QuizTimerTicked event, Emitter<QuizState> emit) {
    final currentState = state;
    if (currentState is QuizQuestionActive) {
      if (event.duration == 0) {
        _moveToNextQuestion(currentState, emit);
      } else {
        emit(currentState.copyWith(remainingSeconds: event.duration));
      }
    }
  }

  void _onAnswerSelected(AnswerSelected event, Emitter<QuizState> emit) {
    final currentState = state;
    if (currentState is QuizQuestionActive) {
      _timerSubscription?.cancel();
      final currentQuestion = currentState.questions[currentState.currentIndex];
      int correctCount = currentState.correctAnswersCount;

      if (currentQuestion.answer.toUpperCase() == event.selectedOption.toUpperCase()) {
        correctCount++;
      }

      final nextIndex = currentState.currentIndex + 1;
      if (nextIndex < currentState.questions.length) {
        emit(QuizQuestionActive(
          questions: currentState.questions,
          currentIndex: nextIndex,
          remainingSeconds: 5,
          correctAnswersCount: correctCount,
        ));
        _startTimer();
      } else {
        final total = currentState.questions.length;
        final score = (correctCount / total) * 100.0;
        emit(QuizFinished(
          score: score,
          totalQuestions: total,
          correctAnswers: correctCount,
        ));
      }
    }
  }

  void _moveToNextQuestion(QuizQuestionActive currentState, Emitter<QuizState> emit) {
    final nextIndex = currentState.currentIndex + 1;
    if (nextIndex < currentState.questions.length) {
      emit(QuizQuestionActive(
        questions: currentState.questions,
        currentIndex: nextIndex,
        remainingSeconds: 5,
        correctAnswersCount: currentState.correctAnswersCount,
      ));
      _startTimer();
    } else {
      _timerSubscription?.cancel();
      final total = currentState.questions.length;
      final score = (currentState.correctAnswersCount / total) * 100.0;
      emit(QuizFinished(
        score: score,
        totalQuestions: total,
        correctAnswers: currentState.correctAnswersCount,
      ));
    }
  }

  void _startTimer() {
    _timerSubscription?.cancel();
    _timerSubscription = Stream.periodic(const Duration(seconds: 1), (x) => 4 - x)
        .take(5)
        .listen((remaining) {
      add(QuizTimerTicked(duration: remaining));
    });
  }

  Future<void> _onSubmitQuizResultRequested(SubmitQuizResultRequested event, Emitter<QuizState> emit) async {
    emit(QuizLoading());
    try {
      final message = await quizRepository.submitQuizResult(event.languageId, event.score);
      emit(QuizOperationSuccess(message: message));
    } catch (e) {
      emit(QuizFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onFetchAdminQuizzes(FetchAdminQuizzes event, Emitter<QuizState> emit) async {
    final currentState = state;

    if (!event.isRefresh && currentState is QuizAdminListLoaded) {
      if (currentState.languageId == event.languageId && currentState.hasReachedMax) return;

      try {
        final pageToFetch = currentState.currentPage + 1;
        final result = await quizRepository.adminGetQuestions(event.languageId, pageToFetch);
        final questions = result['data'] as List<QuizModel>;
        final totalPages = result['totalPages'] as int;

        emit(currentState.copyWith(
          questions: List.of(currentState.questions)..addAll(questions),
          currentPage: pageToFetch,
          hasReachedMax: pageToFetch >= totalPages,
        ));
      } catch (e) {
        emit(QuizFailure(error: e.toString().replaceAll('Exception: ', '')));
      }
    } else {
      emit(QuizLoading());
      try {
        final result = await quizRepository.adminGetQuestions(event.languageId, 1);
        final questions = result['data'] as List<QuizModel>;
        final totalPages = result['totalPages'] as int;

        emit(QuizAdminListLoaded(
          questions: questions,
          currentPage: 1,
          hasReachedMax: 1 >= totalPages,
          languageId: event.languageId,
        ));
      } catch (e) {
        emit(QuizFailure(error: e.toString().replaceAll('Exception: ', '')));
      }
    }
  }

  Future<void> _onCreateQuizQuestionRequested(CreateQuizQuestionRequested event, Emitter<QuizState> emit) async {
    emit(QuizLoading());
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
      emit(const QuizOperationSuccess(message: 'Pertanyaan kuis baru berhasil ditambahkan.'));
    } catch (e) {
      emit(QuizFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateQuizQuestionRequested(UpdateQuizQuestionRequested event, Emitter<QuizState> emit) async {
    emit(QuizLoading());
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
      emit(const QuizOperationSuccess(message: 'Pertanyaan kuis berhasil diperbarui.'));
    } catch (e) {
      emit(QuizFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDeleteQuizQuestionRequested(DeleteQuizQuestionRequested event, Emitter<QuizState> emit) async {
    emit(QuizLoading());
    try {
      final message = await quizRepository.adminDeleteQuestion(event.id);
      emit(QuizOperationSuccess(message: message));
    } catch (e) {
      emit(QuizFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onResetQuizData(ResetQuizData event, Emitter<QuizState> emit) {
    emit(QuizInitial());
  }

  @override
  Future<void> close() {
    _timerSubscription?.cancel();
    return super.close();
  }
}