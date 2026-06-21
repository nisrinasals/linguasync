import 'package:equatable/equatable.dart';

abstract class AdminUserEvent extends Equatable {
  const AdminUserEvent();

  @override
  List<Object?> get props => [];
}

class FetchAdminUsers extends AdminUserEvent {
  final String search;
  final String role;
  final bool isRefresh;

  const FetchAdminUsers({
    this.search = '',
    this.role = '',
    required this.isRefresh,
  });

  @override
  List<Object?> get props => [search, role, isRefresh];
}

class CreateAdminUser extends AdminUserEvent {
  final String name;
  final String email;
  final String password;
  final String role;

  const CreateAdminUser({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  @override
  List<Object?> get props => [name, email, password, role];
}

class UpdateAdminUser extends AdminUserEvent {
  final int id;
  final String name;
  final String email;
  final String? password;
  final String role;

  const UpdateAdminUser({
    required this.id,
    required this.name,
    required this.email,
    this.password,
    required this.role,
  });

  @override
  List<Object?> get props => [id, name, email, password, role];
}

class DeleteAdminUser extends AdminUserEvent {
  final int id;

  const DeleteAdminUser({required this.id});

  @override
  List<Object?> get props => [id];
}
