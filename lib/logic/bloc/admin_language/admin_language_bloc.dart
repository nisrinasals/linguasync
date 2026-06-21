import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/language_repository.dart';
import 'admin_language_event.dart';
import 'admin_language_state.dart';

class AdminLanguageBloc extends Bloc<AdminLanguageEvent, AdminLanguageState> {
  final LanguageRepository languageRepository;

  AdminLanguageBloc({required this.languageRepository}) : super(AdminLanguageInitial()) {
    on<CreateLanguageRequested>(_onCreateLanguageRequested);
    on<UpdateLanguageRequested>(_onUpdateLanguageRequested);
    on<DeleteLanguageRequested>(_onDeleteLanguageRequested);
  }

  Future<void> _onCreateLanguageRequested(
    CreateLanguageRequested event,
    Emitter<AdminLanguageState> emit,
  ) async {
    emit(AdminLanguageLoading());
    try {
      await languageRepository.createLanguage(event.name, event.description);
      emit(
        const AdminLanguageOperationSuccess(
          message: 'Bahasa baru berhasil ditambahkan.',
        ),
      );
    } catch (e) {
      emit(AdminLanguageFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateLanguageRequested(
    UpdateLanguageRequested event,
    Emitter<AdminLanguageState> emit,
  ) async {
    emit(AdminLanguageLoading());
    try {
      await languageRepository.updateLanguage(
        event.id,
        event.name,
        event.description,
      );
      emit(
        const AdminLanguageOperationSuccess(
          message: 'Informasi bahasa berhasil diperbarui.',
        ),
      );
    } catch (e) {
      emit(AdminLanguageFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDeleteLanguageRequested(
    DeleteLanguageRequested event,
    Emitter<AdminLanguageState> emit,
  ) async {
    emit(AdminLanguageLoading());
    try {
      final message = await languageRepository.deleteLanguage(event.id);
      emit(AdminLanguageOperationSuccess(message: message));
    } catch (e) {
      emit(AdminLanguageFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
