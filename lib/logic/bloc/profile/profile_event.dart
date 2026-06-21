import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class FetchProfile extends ProfileEvent {}

class UpdateProfileRequested extends ProfileEvent {
  final String name;
  final String email;
  final String? password;
  final String? filePath;

  const UpdateProfileRequested({
    required this.name,
    required this.email,
    this.password,
    this.filePath,
  });

  @override
  List<Object?> get props => [name, email, password, filePath];
}
