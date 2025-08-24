part of 'registration_cubit.dart';

enum RegistrationStatus { initial, loading, success, error }

class RegistrationState {
  final RegistrationStatus status;
  final RegistrationStep currentStep;
  final RegistrationData data;
  final String role;
  final String? error;

  const RegistrationState({
    this.status = RegistrationStatus.initial,
    this.currentStep = RegistrationStep.stepOne,
    this.data = const RegistrationData(),
    required this.role,
    this.error,
  });

  RegistrationState copyWith({
    RegistrationStatus? status,
    RegistrationStep? currentStep,
    RegistrationData? data,
    String? role,
    String? error,
  }) {
    return RegistrationState(
      status: status ?? this.status,
      currentStep: currentStep ?? this.currentStep,
      data: data ?? this.data,
      role: role ?? this.role,
      error: error,
    );
  }

  bool get isStepOneComplete => data.isStepOneValid;
  bool get isStepTwoComplete => data.isStepTwoValidForRole(role);
  bool get canProceedToStepTwo => isStepOneComplete;
  bool get canSubmit => isStepOneComplete && isStepTwoComplete;

  @override
  String toString() {
    return 'RegistrationState(status: $status, currentStep: $currentStep, role: $role, error: $error)';
  }
}
