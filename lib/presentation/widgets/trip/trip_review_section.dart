import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/logic/trip/trip_review_cubit.dart';
import 'package:sharexev2/presentation/widgets/booking/trip_review_stepper.dart';

class TripReviewSection extends StatelessWidget {
  final Map<String, dynamic> tripData;
  final String role;

  const TripReviewSection({
    super.key,
    required this.tripData,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripReviewCubit, TripReviewState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Đánh giá chuyến đi',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hãy chia sẻ trải nghiệm của bạn để chúng tôi có thể cải thiện dịch vụ',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF757575),
                ),
              ),
              const SizedBox(height: 20),
              
              if (!state.isSubmitted)
                TripReviewStepper(
                  role: role,
                  tripData: {
                    'tripId': tripData['id'] ?? 'TRIP_001',
                    'driverName': tripData['driverName'] ?? 'Tài xế',
                    'passengerName': 'Bạn',
                    'from': state.tripOrigin,
                    'to': state.tripDestination,
                    'duration': state.tripDuration,
                    'totalPrice': state.tripPrice,
                  },
                  onReviewCompleted: (reviewData) {
                    // Update cubit with review data
                    context.read<TripReviewCubit>().updateRating(reviewData['rating'] ?? 0.0);
                    context.read<TripReviewCubit>().updateTags(reviewData['tags'] ?? []);
                    context.read<TripReviewCubit>().updateComment(reviewData['comment'] ?? '');
                    context.read<TripReviewCubit>().updateRecommendation(reviewData['wouldRecommend'] ?? true);
                    
                    // Submit review
                    context.read<TripReviewCubit>().submitReview();
                  },
                )
              else
                _buildReviewCompleted(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewCompleted() {
    return BlocBuilder<TripReviewCubit, TripReviewState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF38A169).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF38A169).withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.check_circle,
                size: 64,
                color: const Color(0xFF38A169),
              ),
              const SizedBox(height: 16),
              Text(
                'Cảm ơn bạn đã đánh giá!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF38A169),
                ).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Đánh giá của bạn rất quan trọng để chúng tôi cải thiện dịch vụ',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF757575),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38A169),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Hoàn thành'),
              ),
            ],
          ),
        );
      },
    );
  }
}
