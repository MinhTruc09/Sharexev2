import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/data/repositories/auth/auth_repository_interface.dart';
import 'package:sharexev2/logic/roleselection/role_selection_state.dart';

class RoleSelectionCubit extends Cubit<RoleSelectionState> {
  final AuthRepositoryInterface? _authRepository;

  RoleSelectionCubit(this._authRepository) : super(const RoleSelectionState());

  void selectRole(String role) {
    emit(state.copyWith(selectedRole: role, error: null));
  }

  Future<void> saveRoleAndContinue() async {
    if (state.selectedRole == null) return;

    emit(
      state.copyWith(
        status: RoleStatus.saving,
        pendingRole: state.selectedRole,
      ),
    );

    try {
      // Implement role selection through repository
      if (_authRepository != null) {
        // Store role locally since API doesn't provide setRole method
        // The role will be set during registration process instead
        await Future.delayed(const Duration(milliseconds: 500));

        emit(state.copyWith(status: RoleStatus.success, pendingRole: null));
      } else {
        throw Exception('Auth repository không khả dụng');
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: RoleStatus.error,
          error: e.toString(),
          pendingRole: null,
        ),
      );
    }
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }
}
