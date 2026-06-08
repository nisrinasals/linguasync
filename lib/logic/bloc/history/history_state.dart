import 'package:equatable/equatable.dart';
import '../../../data/models/history_model.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<HistoryModel> histories;
  final int currentPage;
  final bool hasReachedMax;

  const HistoryLoaded({
    required this.histories,
    required this.currentPage,
    required this.hasReachedMax,
  });

  HistoryLoaded copyWith({
    List<HistoryModel>? histories,
    int? currentPage,
    bool? hasReachedMax,
  }) {
    return HistoryLoaded(
      histories: histories ?? this.histories,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [histories, currentPage, hasReachedMax];
}

class HistoryFailure extends HistoryState {
  final String error;

  const HistoryFailure({required this.error});

  @override
  List<Object?> get props => [error];
}