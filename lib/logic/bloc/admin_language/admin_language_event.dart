import 'package:equatable/equatable.dart';

abstract class AdminLanguageEvent extends Equatable {
  const AdminLanguageEvent();

  @override
  List<Object?> get props => [];
}

class CreateLanguageRequested extends AdminLanguageEvent {
  final String name;
  final String description;

  const CreateLanguageRequested({required this.name, required this.description});

  @override
  List<Object?> get props => [name, description];
}

class UpdateLanguageRequested extends AdminLanguageEvent {
  final int id;
  final String name;
  final String description;

  const UpdateLanguageRequested({
    required this.id,
    required this.name,
    required this.description,
  });

  @override
  List<Object?> get props => [id, name, description];
}

class DeleteLanguageRequested extends AdminLanguageEvent {
  final int id;

  const DeleteLanguageRequested({required this.id});

  @override
  List<Object?> get props => [id];
}
