import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/material_repository.dart';
import 'admin_material_event.dart';
import 'admin_material_state.dart';

class AdminMaterialBloc extends Bloc<AdminMaterialEvent, AdminMaterialState> {
  final MaterialRepository materialRepository;

  AdminMaterialBloc({required this.materialRepository}) : super(AdminMaterialInitial()) {
    on<CreateMaterialRequested>(_onCreateMaterialRequested);
    on<UpdateMaterialRequested>(_onUpdateMaterialRequested);
    on<DeleteMaterialRequested>(_onDeleteMaterialRequested);
  }

  Future<void> _onCreateMaterialRequested(
    CreateMaterialRequested event,
    Emitter<AdminMaterialState> emit,
  ) async {
    emit(AdminMaterialLoading());
    try {
      await materialRepository.createMaterial(
        event.languageId,
        event.title,
        event.content,
        event.order,
      );
      emit(
        const AdminMaterialOperationSuccess(
          message: 'Materi baru berhasil ditambahkan.',
        ),
      );
    } catch (e) {
      emit(AdminMaterialFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateMaterialRequested(
    UpdateMaterialRequested event,
    Emitter<AdminMaterialState> emit,
  ) async {
    emit(AdminMaterialLoading());
    try {
      await materialRepository.updateMaterial(
        event.id,
        event.title,
        event.content,
        event.order,
      );
      emit(
        const AdminMaterialOperationSuccess(
          message: 'Informasi materi berhasil diperbarui.',
        ),
      );
    } catch (e) {
      emit(AdminMaterialFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDeleteMaterialRequested(
    DeleteMaterialRequested event,
    Emitter<AdminMaterialState> emit,
  ) async {
    emit(AdminMaterialLoading());
    try {
      final message = await materialRepository.deleteMaterial(event.id);
      emit(AdminMaterialOperationSuccess(message: message));
    } catch (e) {
      emit(AdminMaterialFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
