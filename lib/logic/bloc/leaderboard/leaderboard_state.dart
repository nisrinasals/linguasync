import 'package:equatable/equatable.dart';
import '../../../data/models/leaderboard_model.dart';

abstract class LeaderboardState extends Equatable {
  const LeaderboardState();

  @override
  List<Object?> get props => [];
}

class LeaderboardInitial extends LeaderboardState {}

class LeaderboardLoading extends LeaderboardState {}

class LeaderboardLoaded extends LeaderboardState {
  final List<LeaderboardModel> rankings;
  final int currentPage;
  final bool hasReachedMax;
  final int? currentUserRank;
  final double currentUserScore;

  const LeaderboardLoaded({
    required this.rankings,
    required this.currentPage,
    required this.hasReachedMax,
    this.currentUserRank,
    required this.currentUserScore,
  });

  LeaderboardLoaded copyWith({
    List<LeaderboardModel>? rankings,
    int? currentPage,
    bool? hasReachedMax,
    int? currentUserRank,
    double? currentUserScore,
  }) {
    return LeaderboardLoaded(
      rankings: rankings ?? this.rankings,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentUserRank: currentUserRank ?? this.currentUserRank,
      currentUserScore: currentUserScore ?? this.currentUserScore,
    );
  }

  @override
  List<Object?> get props => [rankings, currentPage, hasReachedMax, currentUserRank, currentUserScore];
}

class LeaderboardFailure extends LeaderboardState {
  final String error;

  const LeaderboardFailure({required this.error});

  @override
  List<Object?> get props => [error];
}