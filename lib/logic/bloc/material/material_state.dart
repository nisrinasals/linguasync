import 'package:equatable/equatable.dart';
import '../../../data/models/material_model.dart';

abstract class MaterialState extends Equatable {
  const MaterialState();

  @override
  List<Object?> get props => [];
}

class MaterialInitial extends MaterialState {}

class MaterialLoading extends MaterialState {}

class MaterialListLoaded extends MaterialState {
  final List<MaterialModel> materials;
  final int currentPage;
  final bool hasReachedMax;
  final int languageId;
  final String search;

  const MaterialListLoaded({
    required this.materials,
    required this.currentPage,
    required this.hasReachedMax,
    required this.languageId,
    this.search = '',
  });

  MaterialListLoaded copyWith({
    List<MaterialModel>? materials,
    int? currentPage,
    bool? hasReachedMax,
    int? languageId,
    String? search,
  }) {
    return MaterialListLoaded(
      materials: materials ?? this.materials,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      languageId: languageId ?? this.languageId,
      search: search ?? this.search,
    );
  }

  @override
  List<Object?> get props => [
    materials,
    currentPage,
    hasReachedMax,
    languageId,
    search,
  ];
}

class MaterialDetailLoaded extends MaterialState {
  final MaterialModel material;

  const MaterialDetailLoaded({required this.material});

  @override
  List<Object?> get props => [material];
}

class MaterialOperationSuccess extends MaterialState {
  final String message;

  const MaterialOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class MaterialFailure extends MaterialState {
  final String error;

  const MaterialFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
