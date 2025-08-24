part of 'trip_review_cubit.dart';

enum TripReviewStatus {
  initial,
  loading,
  loaded,
  submitting,
  submitted,
  error,
}

class TripReviewState {
  final Map<String, dynamic> tripData;
  final String role;
  final TripReviewStatus status;
  final double rating;
  final List<String> selectedTags;
  final String comment;
  final bool wouldRecommend;
  final Map<String, dynamic>? reviewData;
  final String? error;

  const TripReviewState({
    this.tripData = const {},
    this.role = 'PASSENGER',
    this.status = TripReviewStatus.initial,
    this.rating = 0,
    this.selectedTags = const [],
    this.comment = '',
    this.wouldRecommend = true,
    this.reviewData,
    this.error,
  });

  TripReviewState copyWith({
    Map<String, dynamic>? tripData,
    String? role,
    TripReviewStatus? status,
    double? rating,
    List<String>? selectedTags,
    String? comment,
    bool? wouldRecommend,
    Map<String, dynamic>? reviewData,
    String? error,
  }) {
    return TripReviewState(
      tripData: tripData ?? this.tripData,
      role: role ?? this.role,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      selectedTags: selectedTags ?? this.selectedTags,
      comment: comment ?? this.comment,
      wouldRecommend: wouldRecommend ?? this.wouldRecommend,
      reviewData: reviewData ?? this.reviewData,
      error: error ?? this.error,
    );
  }

  bool get isLoaded => status == TripReviewStatus.loaded;
  bool get isLoading => status == TripReviewStatus.loading;
  bool get isSubmitting => status == TripReviewStatus.submitting;
  bool get isSubmitted => status == TripReviewStatus.submitted;
  bool get hasError => status == TripReviewStatus.error;
  
  String get tripOrigin => tripData['origin'] ?? 'Chưa xác định';
  String get tripDestination => tripData['destination'] ?? 'Chưa xác định';
  String get tripDuration => tripData['duration'] ?? '45 phút';
  String get tripPrice => tripData['totalPrice']?.toString() ?? '0';
}
