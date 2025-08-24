import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(OnboardingState.initial());

  void setPage(int index) {
    if (index >= 0 && index <= 2) {
      emit(state.copyWith(pageIndex: index));
    }
  }

  void nextPage() {
    if (state.pageIndex < 2) {
      emit(state.copyWith(pageIndex: state.pageIndex + 1));
    }
  }

  void prevPage() {
    if (state.pageIndex > 0) {
      emit(state.copyWith(pageIndex: state.pageIndex - 1));
    }
  }

  Future<void> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstOpen', false);
      emit(state.copyWith(status: OnboardingStatus.completed, completed: true));
    } catch (_) {
      emit(state); // Giữ nguyên state nếu lỗi
    }
  }
}
