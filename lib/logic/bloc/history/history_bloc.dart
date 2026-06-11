import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/history_repository.dart';
import '../../../data/models/history_model.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final HistoryRepository historyRepository;

  HistoryBloc({required this.historyRepository}) : super(HistoryInitial()) {
    on<FetchHistory>(_onFetchHistory);
    on<ResetHistoryData>(_onResetHistoryData);
  }

  Future<void> _onFetchHistory(FetchHistory event, Emitter<HistoryState> emit) async {
    final currentState = state;

    if (!event.isRefresh && currentState is HistoryLoaded) {
      if (currentState.hasReachedMax) return;

      try {
        final pageToFetch = currentState.currentPage + 1;
        final result = await historyRepository.getUserHistory(pageToFetch);
        final histories = result['data'] as List<HistoryModel>;
        final totalPages = result['totalPages'] as int;

        emit(currentState.copyWith(
          histories: List.of(currentState.histories)..addAll(histories),
          currentPage: pageToFetch,
          hasReachedMax: pageToFetch >= totalPages,
        ));
      } catch (e) {
        emit(HistoryFailure(error: e.toString().replaceAll('Exception: ', '')));
      }
    } else {
      emit(HistoryLoading());
      try {
        final result = await historyRepository.getUserHistory(1);
        final histories = result['data'] as List<HistoryModel>;
        final totalPages = result['totalPages'] as int;

        emit(HistoryLoaded(
          histories: histories,
          currentPage: 1,
          hasReachedMax: 1 >= totalPages,
        ));
      } catch (e) {
        emit(HistoryFailure(error: e.toString().replaceAll('Exception: ', '')));
      }
    }
  }

  void _onResetHistoryData(ResetHistoryData event, Emitter<HistoryState> emit) {
    emit(HistoryInitial());
  }
}