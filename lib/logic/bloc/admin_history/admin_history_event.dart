import 'package:equatable/equatable.dart';

abstract class AdminHistoryEvent extends Equatable {
  const AdminHistoryEvent();

  @override
  List<Object?> get props => [];
}

class FetchAdminHistory extends AdminHistoryEvent {
  final String search;
  final bool isRefresh;

  const FetchAdminHistory({
    this.search = '',
    required this.isRefresh,
  });

  @override
  List<Object?> get props => [search, isRefresh];
}

class CreateAdminHistory extends AdminHistoryEvent {
  final int userId;
  final int languageId;
  final double score;

  const CreateAdminHistory({
    required this.userId,
    required this.languageId,
    required this.score,
  });

  @override
  List<Object?> get props => [userId, languageId, score];
}

class UpdateAdminHistory extends AdminHistoryEvent {
  final int id;
  final int userId;
  final int languageId;
  final double score;

  const UpdateAdminHistory({
    required this.id,
    required this.userId,
    required this.languageId,
    required this.score,
  });

  @override
  List<Object?> get props => [id, userId, languageId, score];
}

class DeleteAdminHistory extends AdminHistoryEvent {
  final int id;

  const DeleteAdminHistory({required this.id});

  @override
  List<Object?> get props => [id];
}
