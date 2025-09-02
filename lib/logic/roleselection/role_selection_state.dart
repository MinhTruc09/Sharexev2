enum RoleStatus { idle, saving, success, error }

class RoleSelectionState {
  final RoleStatus status;
  final String? selectedRole; // Currently selected role
  final String? pendingRole; // 'PASSENGER' | 'DRIVER' khi đang saving
  final String? error;

  const RoleSelectionState({
    this.status = RoleStatus.idle,
    this.selectedRole,
    this.pendingRole,
    this.error,
  });

  RoleSelectionState copyWith({
    RoleStatus? status,
    String? selectedRole,
    String? pendingRole,
    String? error,
  }) {
    return RoleSelectionState(
      status: status ?? this.status,
      selectedRole: selectedRole ?? this.selectedRole,
      pendingRole: pendingRole ?? this.pendingRole,
      error: error ?? this.error,
    );
  }
}
