import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/data/repositories/auth/auth_repository_interface.dart';
import 'package:sharexev2/logic/roleselection/role_selection_state.dart';

class RoleSelectionCubit extends Cubit<RoleSelectionState> {
  final AuthRepositoryInterface? _authRepository;

  RoleSelectionCubit(this._authRepository) : super(const RoleSelectionState());

  void selectRole(String role) {
    emit(state.copyWith(
      selectedRole: role,
      error: null,
    ));
  }

  Future<void> saveRoleAndContinue() async {
    if (state.selectedRole == null) return;
    
    emit(state.copyWith(status: RoleStatus.saving, pendingRole: state.selectedRole));
    try {
      // TODO: Implement role selection through repository
      // await _authService.setRole(state.selectedRole!);

      // Mock successful role selection
      await Future.delayed(const Duration(seconds: 1));
      emit(state.copyWith(status: RoleStatus.success, pendingRole: null));
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
