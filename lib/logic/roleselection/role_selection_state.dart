enum RoleStatus { idle, saving, success, error }

class RoleSelectionState {
  final RoleStatus status;
  final String? pendingRole; // 'PASSENGER' | 'DRIVER' khi đang saving
  final String? error;

  const RoleSelectionState({
    this.status = RoleStatus.idle,
    this.pendingRole,
    this.error,
  });

  RoleSelectionState copyWith({
    RoleStatus? status,
    String? pendingRole,
    String? error,
  }) {
    return RoleSelectionState(
      status: status ?? this.status,
      pendingRole: pendingRole,
      error: error,
    );
  }
}
