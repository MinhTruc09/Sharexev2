import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/logic/trip/trip_review_cubit.dart';
import 'package:sharexev2/presentation/widgets/trip/trip_summary_section.dart';
import 'package:sharexev2/presentation/widgets/trip/trip_review_section.dart';

class TripReviewPage extends StatelessWidget {
  final Map<String, dynamic> tripData;
  final String role;

  const TripReviewPage({
    super.key,
    required this.tripData,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TripReviewCubit()..initializeReview(tripData, role),
      child: TripReviewView(tripData: tripData, role: role),
    );
  }
}

class TripReviewView extends StatefulWidget {
  final Map<String, dynamic> tripData;
  final String role;

  const TripReviewView({
    super.key,
    required this.tripData,
    required this.role,
  });

  @override
  State<TripReviewView> createState() => _TripReviewViewState();
}

class _TripReviewViewState extends State<TripReviewView> {

  @override
  Widget build(BuildContext context) {
    return BlocListener<TripReviewCubit, TripReviewState>(
      listener: (context, state) {
        if (state.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: const Color(0xFFE53E3E),
              action: SnackBarAction(
                label: 'Đóng',
                textColor: Colors.white,
                onPressed: () {
                  context.read<TripReviewCubit>().clearError();
                },
              ),
            ),
          );
        }
        
        if (state.isSubmitted) {
          _showReviewSummary(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
                      child: Column(
              children: [
                TripSummarySection(),
                const Divider(height: 32),
                TripReviewSection(
                  tripData: widget.tripData,
                  role: widget.role,
                ),
                const SizedBox(height: 32),
              ],
            ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: ThemeManager.getPrimaryColorForRole(widget.role),
      foregroundColor: Colors.white,
      elevation: 0,
      title: Text(
        'Đánh giá chuyến đi',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }



  void _showReviewSummary(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đánh giá đã được gửi!'),
        content: const Text('Cảm ơn bạn đã đánh giá chuyến đi. Đánh giá của bạn sẽ giúp chúng tôi cải thiện dịch vụ.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }







  
}
