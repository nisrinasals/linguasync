import 'package:equatable/equatable.dart';

abstract class AdminMaterialEvent extends Equatable {
  const AdminMaterialEvent();

  @override
  List<Object?> get props => [];
}

class CreateMaterialRequested extends AdminMaterialEvent {
  final int languageId;
  final String title;
  final String content;
  final int order;

  const CreateMaterialRequested({
    required this.languageId,
    required this.title,
    required this.content,
    required this.order,
  });

  @override
  List<Object?> get props => [languageId, title, content, order];
}

class UpdateMaterialRequested extends AdminMaterialEvent {
  final int id;
  final String title;
  final String content;
  final int order;

  const UpdateMaterialRequested({
    required this.id,
    required this.title,
    required this.content,
    required this.order,
  });

  @override
  List<Object?> get props => [id, title, content, order];
}

class DeleteMaterialRequested extends AdminMaterialEvent {
  final int id;

  const DeleteMaterialRequested({required this.id});

  @override
  List<Object?> get props => [id];
}
