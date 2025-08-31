import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/logic/roleselection/role_selection_state.dart';

class RoleSelectionCubit extends Cubit<RoleSelectionState> {
  final dynamic _authService; // TODO: Type as AuthRepositoryInterface when DI is ready

  RoleSelectionCubit(this._authService) : super(const RoleSelectionState());

  Future<void> selectRole(String role) async {
    emit(state.copyWith(status: RoleStatus.saving, pendingRole: role));
    try {
      // TODO: Implement role selection through repository
      // await _authService.setRole(role);

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
}
