import 'package:equatable/equatable.dart';

abstract class MaterialEvent extends Equatable {
  const MaterialEvent();

  @override
  List<Object?> get props => [];
}

class FetchMaterials extends MaterialEvent {
  final int languageId;
  final bool isRefresh;

  const FetchMaterials({required this.languageId, this.isRefresh = false});

  @override
  List<Object?> get props => [languageId, isRefresh];
}

class FetchMaterialDetail extends MaterialEvent {
  final int id;

  const FetchMaterialDetail({required this.id});

  @override
  List<Object?> get props => [id];
}

class CreateMaterialRequested extends MaterialEvent {
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

class UpdateMaterialRequested extends MaterialEvent {
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

class DeleteMaterialRequested extends MaterialEvent {
  final int id;

  const DeleteMaterialRequested({required this.id});

  @override
  List<Object?> get props => [id];
}
