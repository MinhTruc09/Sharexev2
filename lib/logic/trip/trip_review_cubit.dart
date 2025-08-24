import 'package:flutter_bloc/flutter_bloc.dart';

part 'trip_review_state.dart';

class TripReviewCubit extends Cubit<TripReviewState> {
  TripReviewCubit() : super(const TripReviewState());

  void initializeReview(Map<String, dynamic> tripData, String role) {
    emit(state.copyWith(
      tripData: tripData,
      role: role,
      status: TripReviewStatus.loaded,
    ));
  }

  void updateRating(double rating) {
    emit(state.copyWith(
      rating: rating,
      error: null,
    ));
  }

  void updateTags(List<String> tags) {
    emit(state.copyWith(
      selectedTags: tags,
      error: null,
    ));
  }

  void updateComment(String comment) {
    emit(state.copyWith(
      comment: comment,
      error: null,
    ));
  }

  void updateRecommendation(bool wouldRecommend) {
    emit(state.copyWith(
      wouldRecommend: wouldRecommend,
      error: null,
    ));
  }

  Future<void> submitReview() async {
    if (!_validateReview()) {
      emit(state.copyWith(
        status: TripReviewStatus.error,
        error: 'Vui lòng điền đầy đủ thông tin đánh giá',
      ));
      return;
    }

    emit(state.copyWith(
      status: TripReviewStatus.submitting,
      error: null,
    ));

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      final reviewData = {
        'rating': state.rating,
        'tags': state.selectedTags,
        'comment': state.comment,
        'wouldRecommend': state.wouldRecommend,
        'submittedAt': DateTime.now().toIso8601String(),
      };
      
      emit(state.copyWith(
        status: TripReviewStatus.submitted,
        reviewData: reviewData,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TripReviewStatus.error,
        error: 'Lỗi gửi đánh giá: $e',
      ));
    }
  }

  bool _validateReview() {
    return state.rating > 0 && 
           state.selectedTags.isNotEmpty && 
           state.comment.isNotEmpty;
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }

  void resetReview() {
    emit(state.copyWith(
      rating: 0,
      selectedTags: [],
      comment: '',
      wouldRecommend: true,
      reviewData: null,
      error: null,
    ));
  }

  void resetStatus() {
    emit(state.copyWith(status: TripReviewStatus.loaded));
  }
}
