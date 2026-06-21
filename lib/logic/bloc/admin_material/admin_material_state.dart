import 'package:equatable/equatable.dart';

abstract class AdminMaterialState extends Equatable {
  const AdminMaterialState();

  @override
  List<Object?> get props => [];
}

class AdminMaterialInitial extends AdminMaterialState {}

class AdminMaterialLoading extends AdminMaterialState {}

class AdminMaterialOperationSuccess extends AdminMaterialState {
  final String message;

  const AdminMaterialOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class AdminMaterialFailure extends AdminMaterialState {
  final String error;

  const AdminMaterialFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
