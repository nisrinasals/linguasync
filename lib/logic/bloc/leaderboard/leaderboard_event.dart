import 'package:equatable/equatable.dart';

abstract class LeaderboardEvent extends Equatable {
  const LeaderboardEvent();

  @override
  List<Object?> get props => [];
}

class FetchLeaderboard extends LeaderboardEvent {
  final bool isRefresh;

  const FetchLeaderboard({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class ResetLeaderboardData extends LeaderboardEvent {}