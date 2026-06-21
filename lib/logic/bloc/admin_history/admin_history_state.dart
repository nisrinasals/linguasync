import 'package:equatable/equatable.dart';
import '../../../data/models/history_model.dart';

abstract class AdminHistoryState extends Equatable {
  const AdminHistoryState();

  @override
  List<Object?> get props => [];
}

class AdminHistoryInitial extends AdminHistoryState {}

class AdminHistoryLoading extends AdminHistoryState {}

class AdminHistoryLoaded extends AdminHistoryState {
  final List<HistoryModel> histories;
  final bool hasReachedMax;
  final int currentPage;
  final String search;

  const AdminHistoryLoaded({
    required this.histories,
    required this.hasReachedMax,
    required this.currentPage,
    required this.search,
  });

  @override
  List<Object?> get props => [histories, hasReachedMax, currentPage, search];

  AdminHistoryLoaded copyWith({
    List<HistoryModel>? histories,
    bool? hasReachedMax,
    int? currentPage,
    String? search,
  }) {
    return AdminHistoryLoaded(
      histories: histories ?? this.histories,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      search: search ?? this.search,
    );
  }
}

class AdminHistoryOperationSuccess extends AdminHistoryState {
  final String message;

  const AdminHistoryOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class AdminHistoryFailure extends AdminHistoryState {
  final String error;

  const AdminHistoryFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
