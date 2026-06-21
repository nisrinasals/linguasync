import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/auth_model.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthRepository authRepository;

  ProfileBloc({required this.authRepository}) : super(ProfileInitial()) {
    on<FetchProfile>(_onFetchProfile);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
  }

  Future<void> _onFetchProfile(FetchProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final response = await authRepository.storageProvider.get('/auth/profile');
      authRepository.handleError(response);
      final body = jsonDecode(response.body);
      final user = UserModel.fromJson(body['data']);
      emit(ProfileLoaded(user: user));
    } catch (e) {
      emit(ProfileFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateProfileRequested(UpdateProfileRequested event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final response = await authRepository.storageProvider.uploadProfilePicture(
        name: event.name,
        email: event.email,
        password: event.password,
        filePath: event.filePath,
      );
      authRepository.handleError(response);
      final body = jsonDecode(response.body);
      final user = UserModel.fromJson(body['data']);
      emit(ProfileUpdateSuccess(user: user, message: body['message'] ?? 'Profil berhasil diperbarui.'));
      emit(ProfileLoaded(user: user));
    } catch (e) {
      emit(ProfileFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
