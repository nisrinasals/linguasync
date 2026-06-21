import 'package:equatable/equatable.dart';

abstract class MaterialEvent extends Equatable {
  const MaterialEvent();

  @override
  List<Object?> get props => [];
}

class FetchMaterials extends MaterialEvent {
  final int languageId;
  final String search;
  final bool isRefresh;

  const FetchMaterials({
    required this.languageId,
    this.search = '',
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [languageId, search, isRefresh];
}

class FetchMaterialDetail extends MaterialEvent {
  final int id;

  const FetchMaterialDetail({required this.id});

  @override
  List<Object?> get props => [id];
}


