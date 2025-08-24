import 'package:flutter/material.dart';
import 'package:sharexev2/config/theme.dart';

class TripReviewStepper extends StatefulWidget {
  final String role;
  final Map<String, dynamic> tripData;
  final Function(Map<String, dynamic> reviewData) onReviewCompleted;

  const TripReviewStepper({
    super.key,
    required this.role,
    required this.tripData,
    required this.onReviewCompleted,
  });

  @override
  State<TripReviewStepper> createState() => _TripReviewStepperState();
}

class _TripReviewStepperState extends State<TripReviewStepper> {
  int _currentStep = 0;
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _wouldRecommend = false;
  List<String> _selectedTags = [];

  final List<String> _positiveTags = [
    'Đúng giờ',
    'Lái xe an toàn',
    'Thân thiện',
    'Xe sạch sẽ',
    'Giá hợp lý',
    'Thoải mái',
  ];

  final List<String> _negativeTags = [
    'Trễ giờ',
    'Lái xe không an toàn',
    'Không thân thiện',
    'Xe không sạch',
    'Giá cao',
    'Không thoải mái',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: AppTheme.getPrimaryColor(widget.role),
          ),
        ),
        child: Stepper(
          currentStep: _currentStep,
          onStepTapped: (step) {
            if (step <= _currentStep) {
              setState(() {
                _currentStep = step;
              });
            }
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: EdgeInsets.only(top: AppTheme.spacingL),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: details.onStepCancel,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppTheme.getPrimaryColor(widget.role),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: AppTheme.spacingM,
                          ),
                        ),
                        child: Text(
                          'Quay lại',
                          style: AppTheme.labelMedium.copyWith(
                            color: AppTheme.getPrimaryColor(widget.role),
                          ),
                        ),
                      ),
                    ),
                  if (_currentStep > 0) SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _currentStep == 2 ? _submitReview : details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.getPrimaryColor(widget.role),
                        padding: EdgeInsets.symmetric(
                          vertical: AppTheme.spacingM,
                        ),
                      ),
                      child: Text(
                        _currentStep == 2 ? 'Hoàn thành' : 'Tiếp tục',
                        style: AppTheme.labelMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          onStepContinue: () {
            if (_currentStep < 2) {
              setState(() {
                _currentStep += 1;
              });
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep -= 1;
              });
            }
          },
          steps: [
            Step(
              title: Text(
                'Thông tin chuyến đi',
                style: AppTheme.labelLarge,
              ),
              content: _buildTripInfoStep(),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.editing,
            ),
            Step(
              title: Text(
                'Đánh giá',
                style: AppTheme.labelLarge,
              ),
              content: _buildRatingStep(),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : 
                     _currentStep == 1 ? StepState.editing : StepState.disabled,
            ),
            Step(
              title: Text(
                'Nhận xét',
                style: AppTheme.labelLarge,
              ),
              content: _buildCommentStep(),
              isActive: _currentStep >= 2,
              state: _currentStep == 2 ? StepState.editing : StepState.disabled,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoCard(
          icon: Icons.person,
          title: widget.role == 'PASSENGER' ? 'Tài xế' : 'Hành khách',
          subtitle: widget.tripData['driverName'] ?? widget.tripData['passengerName'] ?? 'N/A',
        ),
        SizedBox(height: AppTheme.spacingM),
        _buildInfoCard(
          icon: Icons.location_on,
          title: 'Tuyến đường',
          subtitle: '${widget.tripData['from']} → ${widget.tripData['to']}',
        ),
        SizedBox(height: AppTheme.spacingM),
        _buildInfoCard(
          icon: Icons.access_time,
          title: 'Thời gian',
          subtitle: widget.tripData['duration'] ?? 'N/A',
        ),
        SizedBox(height: AppTheme.spacingM),
        _buildInfoCard(
          icon: Icons.attach_money,
          title: 'Tổng tiền',
          subtitle: '${widget.tripData['totalPrice']}k VNĐ',
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppTheme.spacingS),
            decoration: BoxDecoration(
              color: AppTheme.getPrimaryColor(widget.role).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusS),
            ),
            child: Icon(
              icon,
              color: AppTheme.getPrimaryColor(widget.role),
              size: 20,
            ),
          ),
          SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStep() {
    return Column(
      children: [
        Text(
          'Bạn đánh giá chuyến đi này như thế nào?',
          style: AppTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppTheme.spacingL),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _rating = index + 1;
                });
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingXs),
                child: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 40,
                ),
              ),
            );
          }),
        ),
        SizedBox(height: AppTheme.spacingM),
        if (_rating > 0)
          Text(
            _getRatingText(_rating),
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.getPrimaryColor(widget.role),
              fontWeight: FontWeight.w600,
            ),
          ),
        SizedBox(height: AppTheme.spacingL),
        
        // Tags selection
        Text(
          'Chọn những điểm nổi bật:',
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppTheme.spacingM),
        Wrap(
          spacing: AppTheme.spacingS,
          runSpacing: AppTheme.spacingS,
          children: (_rating >= 4 ? _positiveTags : _negativeTags).map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedTags.remove(tag);
                  } else {
                    _selectedTags.add(tag);
                  }
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingS,
                ),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.getPrimaryColor(widget.role)
                      : Colors.transparent,
                  border: Border.all(
                    color: AppTheme.getPrimaryColor(widget.role),
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                ),
                child: Text(
                  tag,
                  style: AppTheme.bodySmall.copyWith(
                    color: isSelected 
                        ? Colors.white 
                        : AppTheme.getPrimaryColor(widget.role),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCommentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chia sẻ thêm về trải nghiệm của bạn:',
          style: AppTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppTheme.spacingM),
        TextField(
          controller: _commentController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Viết nhận xét của bạn...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              borderSide: BorderSide(
                color: AppTheme.getPrimaryColor(widget.role),
                width: 2,
              ),
            ),
          ),
        ),
        SizedBox(height: AppTheme.spacingL),
        Row(
          children: [
            Checkbox(
              value: _wouldRecommend,
              onChanged: (value) {
                setState(() {
                  _wouldRecommend = value ?? false;
                });
              },
              activeColor: AppTheme.getPrimaryColor(widget.role),
            ),
            Expanded(
              child: Text(
                'Tôi sẽ giới thiệu ${widget.role == 'PASSENGER' ? 'tài xế' : 'hành khách'} này cho bạn bè',
                style: AppTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Rất không hài lòng';
      case 2:
        return 'Không hài lòng';
      case 3:
        return 'Bình thường';
      case 4:
        return 'Hài lòng';
      case 5:
        return 'Rất hài lòng';
      default:
        return '';
    }
  }

  void _submitReview() {
    final reviewData = {
      'rating': _rating,
      'comment': _commentController.text,
      'tags': _selectedTags,
      'wouldRecommend': _wouldRecommend,
      'tripId': widget.tripData['tripId'],
    };
    
    widget.onReviewCompleted(reviewData);
  }
}
