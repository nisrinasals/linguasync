import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/leaderboard_repository.dart';
import '../../../data/models/leaderboard_model.dart';
import 'leaderboard_event.dart';
import 'leaderboard_state.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final LeaderboardRepository leaderboardRepository;

  LeaderboardBloc({required this.leaderboardRepository}) : super(LeaderboardInitial()) {
    on<FetchLeaderboard>(_onFetchLeaderboard);
  }

  Future<void> _onFetchLeaderboard(FetchLeaderboard event, Emitter<LeaderboardState> emit) async {
    final currentState = state;

    if (!event.isRefresh && currentState is LeaderboardLoaded) {
      if (currentState.hasReachedMax) return;

      try {
        final pageToFetch = currentState.currentPage + 1;
        final result = await leaderboardRepository.getGlobalLeaderboard(pageToFetch);
        final rankings = result['data'] as List<LeaderboardModel>;
        final totalPages = result['totalPages'] as int;

        emit(currentState.copyWith(
          rankings: List.of(currentState.rankings)..addAll(rankings),
          currentPage: pageToFetch,
          hasReachedMax: pageToFetch >= totalPages,
          currentUserRank: result['currentUserRank'] as int?,
          currentUserScore: result['currentUserScore'] as double,
        ));
      } catch (e) {
        emit(LeaderboardFailure(error: e.toString().replaceAll('Exception: ', '')));
      }
    } else {
      emit(LeaderboardLoading());
      try {
        final result = await leaderboardRepository.getGlobalLeaderboard(1);
        final rankings = result['data'] as List<LeaderboardModel>;
        final totalPages = result['totalPages'] as int;

        emit(LeaderboardLoaded(
          rankings: rankings,
          currentPage: 1,
          hasReachedMax: 1 >= totalPages,
          currentUserRank: result['currentUserRank'] as int?,
          currentUserScore: result['currentUserScore'] as double,
        ));
      } catch (e) {
        emit(LeaderboardFailure(error: e.toString().replaceAll('Exception: ', '')));
      }
    }
  }
}