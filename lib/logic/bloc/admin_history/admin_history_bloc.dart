import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/history_repository.dart';
import '../../../data/models/history_model.dart';
import 'admin_history_event.dart';
import 'admin_history_state.dart';

class AdminHistoryBloc extends Bloc<AdminHistoryEvent, AdminHistoryState> {
  final HistoryRepository historyRepository;

  AdminHistoryBloc({required this.historyRepository}) : super(AdminHistoryInitial()) {
    on<FetchAdminHistory>(_onFetchAdminHistory);
    on<CreateAdminHistory>(_onCreateAdminHistory);
    on<UpdateAdminHistory>(_onUpdateAdminHistory);
    on<DeleteAdminHistory>(_onDeleteAdminHistory);
  }

  Future<void> _onFetchAdminHistory(FetchAdminHistory event, Emitter<AdminHistoryState> emit) async {
    final currentState = state;
    if (event.isRefresh) {
      emit(AdminHistoryLoading());
      try {
        final result = await historyRepository.getHistoriesAdmin(
          1,
          search: event.search,
          languageId: event.languageId,
        );
        final list = result['data'] as List<HistoryModel>;
        final totalPages = result['totalPages'] as int;
        emit(AdminHistoryLoaded(
          histories: list,
          hasReachedMax: 1 >= totalPages,
          currentPage: 1,
          search: event.search,
          languageId: event.languageId,
        ));
      } catch (e) {
        emit(AdminHistoryFailure(error: e.toString().replaceAll('Exception: ', '')));
      }
    } else {
      if (currentState is AdminHistoryLoaded && !currentState.hasReachedMax) {
        try {
          final nextPage = currentState.currentPage + 1;
          final result = await historyRepository.getHistoriesAdmin(
            nextPage,
            search: currentState.search,
            languageId: currentState.languageId,
          );
          final list = result['data'] as List<HistoryModel>;
          final totalPages = result['totalPages'] as int;
          emit(AdminHistoryLoaded(
            histories: currentState.histories + list,
            hasReachedMax: nextPage >= totalPages,
            currentPage: nextPage,
            search: currentState.search,
            languageId: currentState.languageId,
          ));
        } catch (e) {
          emit(AdminHistoryFailure(error: e.toString().replaceAll('Exception: ', '')));
        }
      }
    }
  }

  Future<void> _onCreateAdminHistory(CreateAdminHistory event, Emitter<AdminHistoryState> emit) async {
    emit(AdminHistoryLoading());
    try {
      await historyRepository.createHistoryAdmin(
        userId: event.userId,
        languageId: event.languageId,
        score: event.score,
      );
      emit(const AdminHistoryOperationSuccess(message: 'Riwayat kuis berhasil dicatat.'));
    } catch (e) {
      emit(AdminHistoryFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateAdminHistory(UpdateAdminHistory event, Emitter<AdminHistoryState> emit) async {
    emit(AdminHistoryLoading());
    try {
      await historyRepository.updateHistoryAdmin(
        event.id,
        userId: event.userId,
        languageId: event.languageId,
        score: event.score,
      );
      emit(const AdminHistoryOperationSuccess(message: 'Data riwayat kuis berhasil diperbarui.'));
    } catch (e) {
      emit(AdminHistoryFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDeleteAdminHistory(DeleteAdminHistory event, Emitter<AdminHistoryState> emit) async {
    emit(AdminHistoryLoading());
    try {
      final message = await historyRepository.deleteHistoryAdmin(event.id);
      emit(AdminHistoryOperationSuccess(message: message));
    } catch (e) {
      emit(AdminHistoryFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
