import 'package:equatable/equatable.dart';
import '../../../data/models/auth_model.dart';

abstract class AdminUserState extends Equatable {
  const AdminUserState();

  @override
  List<Object?> get props => [];
}

class AdminUserInitial extends AdminUserState {}

class AdminUserLoading extends AdminUserState {}

class AdminUserLoaded extends AdminUserState {
  final List<UserModel> users;
  final bool hasReachedMax;
  final int currentPage;
  final String search;
  final String role;

  const AdminUserLoaded({
    required this.users,
    required this.hasReachedMax,
    required this.currentPage,
    required this.search,
    required this.role,
  });

  @override
  List<Object?> get props => [users, hasReachedMax, currentPage, search, role];

  AdminUserLoaded copyWith({
    List<UserModel>? users,
    bool? hasReachedMax,
    int? currentPage,
    String? search,
    String? role,
  }) {
    return AdminUserLoaded(
      users: users ?? this.users,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      search: search ?? this.search,
      role: role ?? this.role,
    );
  }
}

class AdminUserOperationSuccess extends AdminUserState {
  final String message;

  const AdminUserOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class AdminUserFailure extends AdminUserState {
  final String error;

  const AdminUserFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
