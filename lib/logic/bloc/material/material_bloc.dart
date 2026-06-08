import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/material_repository.dart';
import '../../../data/models/material_model.dart';
import 'material_event.dart';
import 'material_state.dart';

class MaterialBloc extends Bloc<MaterialEvent, MaterialState> {
  final MaterialRepository materialRepository;

  MaterialBloc({required this.materialRepository}) : super(MaterialInitial()) {
    on<FetchMaterials>(_onFetchMaterials);
    on<FetchMaterialDetail>(_onFetchMaterialDetail);
    on<CreateMaterialRequested>(_onCreateMaterialRequested);
    on<UpdateMaterialRequested>(_onUpdateMaterialRequested);
    on<DeleteMaterialRequested>(_onDeleteMaterialRequested);
  }

  Future<void> _onFetchMaterials(
    FetchMaterials event,
    Emitter<MaterialState> emit,
  ) async {
    final currentState = state;

    if (!event.isRefresh && currentState is MaterialListLoaded) {
      if (currentState.languageId == event.languageId &&
          currentState.hasReachedMax)
        return;

      try {
        final pageToFetch = currentState.currentPage + 1;
        final result = await materialRepository.getMaterialsByLanguage(
          event.languageId,
          pageToFetch,
        );
        final materials = result['data'] as List<MaterialModel>;
        final totalPages = result['totalPages'] as int;

        emit(
          currentState.copyWith(
            materials: List.of(currentState.materials)..addAll(materials),
            currentPage: pageToFetch,
            hasReachedMax: pageToFetch >= totalPages,
          ),
        );
      } catch (e) {
        emit(
          MaterialFailure(error: e.toString().replaceAll('Exception: ', '')),
        );
      }
    } else {
      emit(MaterialLoading());
      try {
        final result = await materialRepository.getMaterialsByLanguage(
          event.languageId,
          1,
        );
        final materials = result['data'] as List<MaterialModel>;
        final totalPages = result['totalPages'] as int;

        emit(
          MaterialListLoaded(
            materials: materials,
            currentPage: 1,
            hasReachedMax: 1 >= totalPages,
            languageId: event.languageId,
          ),
        );
      } catch (e) {
        emit(
          MaterialFailure(error: e.toString().replaceAll('Exception: ', '')),
        );
      }
    }
  }

  Future<void> _onFetchMaterialDetail(
    FetchMaterialDetail event,
    Emitter<MaterialState> emit,
  ) async {
    emit(MaterialLoading());
    try {
      final material = await materialRepository.getMaterialById(event.id);
      emit(MaterialDetailLoaded(material: material));
    } catch (e) {
      emit(MaterialFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCreateMaterialRequested(
    CreateMaterialRequested event,
    Emitter<MaterialState> emit,
  ) async {
    emit(MaterialLoading());
    try {
      await materialRepository.createMaterial(
        event.languageId,
        event.title,
        event.content,
        event.order,
      );
      emit(
        const MaterialOperationSuccess(
          message: 'Materi baru berhasil ditambahkan.',
        ),
      );
    } catch (e) {
      emit(MaterialFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateMaterialRequested(
    UpdateMaterialRequested event,
    Emitter<MaterialState> emit,
  ) async {
    emit(MaterialLoading());
    try {
      await materialRepository.updateMaterial(
        event.id,
        event.title,
        event.content,
        event.order,
      );
      emit(
        const MaterialOperationSuccess(
          message: 'Informasi materi berhasil diperbarui.',
        ),
      );
    } catch (e) {
      emit(MaterialFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDeleteMaterialRequested(
    DeleteMaterialRequested event,
    Emitter<MaterialState> emit,
  ) async {
    emit(MaterialLoading());
    try {
      final message = await materialRepository.deleteMaterial(event.id);
      emit(MaterialOperationSuccess(message: message));
    } catch (e) {
      emit(MaterialFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
