import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/models/auth_model.dart';
import 'admin_user_event.dart';
import 'admin_user_state.dart';

class AdminUserBloc extends Bloc<AdminUserEvent, AdminUserState> {
  final UserRepository userRepository;

  AdminUserBloc({required this.userRepository}) : super(AdminUserInitial()) {
    on<FetchAdminUsers>(_onFetchAdminUsers);
    on<CreateAdminUser>(_onCreateAdminUser);
    on<UpdateAdminUser>(_onUpdateAdminUser);
    on<DeleteAdminUser>(_onDeleteAdminUser);
  }

  Future<void> _onFetchAdminUsers(FetchAdminUsers event, Emitter<AdminUserState> emit) async {
    final currentState = state;
    if (event.isRefresh) {
      emit(AdminUserLoading());
      try {
        final result = await userRepository.getUsers(
          page: 1,
          search: event.search,
          role: event.role,
        );
        final users = result['data'] as List<UserModel>;
        final totalPages = result['totalPages'] as int;
        emit(AdminUserLoaded(
          users: users,
          hasReachedMax: 1 >= totalPages,
          currentPage: 1,
          search: event.search,
          role: event.role,
        ));
      } catch (e) {
        emit(AdminUserFailure(error: e.toString().replaceAll('Exception: ', '')));
      }
    } else {
      if (currentState is AdminUserLoaded && !currentState.hasReachedMax) {
        try {
          final nextPage = currentState.currentPage + 1;
          final result = await userRepository.getUsers(
            page: nextPage,
            search: currentState.search,
            role: currentState.role,
          );
          final users = result['data'] as List<UserModel>;
          final totalPages = result['totalPages'] as int;
          emit(AdminUserLoaded(
            users: currentState.users + users,
            hasReachedMax: nextPage >= totalPages,
            currentPage: nextPage,
            search: currentState.search,
            role: currentState.role,
          ));
        } catch (e) {
          emit(AdminUserFailure(error: e.toString().replaceAll('Exception: ', '')));
        }
      }
    }
  }

  Future<void> _onCreateAdminUser(CreateAdminUser event, Emitter<AdminUserState> emit) async {
    emit(AdminUserLoading());
    try {
      await userRepository.createUser(
        event.name,
        event.email,
        event.password,
        event.role,
      );
      emit(const AdminUserOperationSuccess(message: 'Pengguna berhasil ditambahkan.'));
    } catch (e) {
      emit(AdminUserFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateAdminUser(UpdateAdminUser event, Emitter<AdminUserState> emit) async {
    emit(AdminUserLoading());
    try {
      await userRepository.updateUser(
        id: event.id,
        name: event.name,
        email: event.email,
        password: event.password,
        role: event.role,
      );
      emit(const AdminUserOperationSuccess(message: 'Data pengguna berhasil diperbarui.'));
    } catch (e) {
      emit(AdminUserFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDeleteAdminUser(DeleteAdminUser event, Emitter<AdminUserState> emit) async {
    emit(AdminUserLoading());
    try {
      final message = await userRepository.deleteUser(event.id);
      emit(AdminUserOperationSuccess(message: message));
    } catch (e) {
      emit(AdminUserFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
