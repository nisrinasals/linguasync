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
  }

  Future<void> _onFetchMaterials(
    FetchMaterials event,
    Emitter<MaterialState> emit,
  ) async {
    final currentState = state;

    if (!event.isRefresh && currentState is MaterialListLoaded) {
      if (currentState.languageId == event.languageId &&
          currentState.hasReachedMax &&
          currentState.search == event.search)
        return;

      try {
        final pageToFetch = currentState.currentPage + 1;
        final result = await materialRepository.getMaterialsByLanguage(
          event.languageId,
          pageToFetch,
          search: event.search,
        );
        final materials = result['data'] as List<MaterialModel>;
        final totalPages = result['totalPages'] as int;

        emit(
          currentState.copyWith(
            materials: List.of(currentState.materials)..addAll(materials),
            currentPage: pageToFetch,
            hasReachedMax: pageToFetch >= totalPages,
            search: event.search,
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
          search: event.search,
        );
        final materials = result['data'] as List<MaterialModel>;
        final totalPages = result['totalPages'] as int;

        emit(
          MaterialListLoaded(
            materials: materials,
            currentPage: 1,
            hasReachedMax: 1 >= totalPages,
            languageId: event.languageId,
            search: event.search,
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
}
