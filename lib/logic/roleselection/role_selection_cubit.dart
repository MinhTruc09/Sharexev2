import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/logic/roleselection/role_selection_state.dart';
import 'package:sharexev2/data/repositories/role_repository.dart';

class RoleSelectionCubit extends Cubit<RoleSelectionState> {
  final IRoleRepository repository;
  
  RoleSelectionCubit(this.repository) : super(const RoleSelectionState());

  Future<void> selectRole(String role) async {
    emit(state.copyWith(status: RoleStatus.saving, pendingRole: role));
    try {
      await repository.setRole(role);
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
