import 'package:equatable/equatable.dart';

enum OnboardingStatus { initial, inProgress, completed }

class OnboardingState extends Equatable {
  final int pageIndex;
  final bool completed;
  final OnboardingStatus status;

  const OnboardingState({
    required this.pageIndex,
    required this.completed,
    required this.status,
  });

  factory OnboardingState.initial() {
    return const OnboardingState(
      pageIndex: 0,
      completed: false,
      status: OnboardingStatus.initial,
    );
  }

  OnboardingState copyWith({
    int? pageIndex,
    bool? completed,
    OnboardingStatus? status,
  }) {
    return OnboardingState(
      pageIndex: pageIndex ?? this.pageIndex,
      completed: completed ?? this.completed,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [pageIndex, completed, status];
}
