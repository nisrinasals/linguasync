import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/auth_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
    on<UserUpdated>(_onUserUpdated);
  }

  void _onUserUpdated(UserUpdated event, Emitter<AuthState> emit) {
    emit(Authenticated(user: event.user));
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    try {
      // Tunggu minimal 2 detik untuk efek splash screen
      await Future.delayed(const Duration(seconds: 2));

      final token = await authRepository.storageProvider.readToken();
      final role = await authRepository.storageProvider.readRole();

      if (token != null && role != null) {
        // Cek apakah token kedaluwarsa secara lokal
        bool isExpired = JwtDecoder.isExpired(token);
        if (isExpired) {
          // Token expired, hapus dari storage & paksa login ulang
          await authRepository.storageProvider.clearAuthData();
          emit(Unauthenticated());
        } else {
          final dummyUser = UserModel(id: 0, name: '', email: '', role: role);
          emit(Authenticated(user: dummyUser));
        }
      } else {
        emit(Unauthenticated());
      }
    } catch (_) {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final authModel = await authRepository.login(event.email, event.password);
      emit(Authenticated(user: authModel.user));
    } catch (e) {
      emit(AuthFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final successMessage = await authRepository.register(
        event.name,
        event.email,
        event.password,
      );
      emit(AuthSuccessMessage(message: successMessage));
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.logout();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
