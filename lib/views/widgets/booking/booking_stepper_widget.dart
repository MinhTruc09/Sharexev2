import 'package:flutter/material.dart';
import 'package:sharexev2/config/theme.dart';

/// Stepper widget cho quy trình đặt xe ShareXe
class ShareXeBookingStepper extends StatefulWidget {
  final BookingStepData stepData;
  final Function(int step)? onStepChanged;
  final Function()? onCompleted;
  final bool canGoBack;
  final bool canGoNext;

  const ShareXeBookingStepper({
    super.key,
    required this.stepData,
    this.onStepChanged,
    this.onCompleted,
    this.canGoBack = true,
    this.canGoNext = true,
  });

  @override
  State<ShareXeBookingStepper> createState() => _ShareXeBookingStepperState();
}

class _ShareXeBookingStepperState extends State<ShareXeBookingStepper> {
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.stepData.currentStep;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stepper(
        currentStep: _currentStep,
        type: StepperType.vertical,
        elevation: 0,
        margin: EdgeInsets.zero,
        controlsBuilder: (context, details) {
          return _buildCustomControls(details);
        },
        steps: _buildSteps(),
        onStepTapped: (step) {
          if (step <= widget.stepData.maxCompletedStep) {
            setState(() {
              _currentStep = step;
            });
            widget.onStepChanged?.call(step);
          }
        },
      ),
    );
  }

  List<Step> _buildSteps() {
    final steps = <Step>[];
    
    for (int i = 0; i < widget.stepData.steps.length; i++) {
      final stepInfo = widget.stepData.steps[i];
      final isActive = i == _currentStep;
      final isCompleted = i < widget.stepData.maxCompletedStep;
      final isAccessible = i <= widget.stepData.maxCompletedStep;
      
      steps.add(
        Step(
          title: Text(
            stepInfo.title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
              color: isAccessible ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
          content: _buildStepContent(stepInfo, i),
          isActive: isActive,
          state: _getStepState(i, isCompleted),
        ),
      );
    }
    
    return steps;
  }

  StepState _getStepState(int index, bool isCompleted) {
    if (index == _currentStep) {
      return StepState.editing;
    } else if (isCompleted) {
      return StepState.complete;
    } else if (index < _currentStep) {
      return StepState.disabled;
    } else {
      return StepState.indexed;
    }
  }

  Widget _buildStepContent(BookingStepInfo stepInfo, int stepIndex) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step icon and title
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: stepInfo.iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  stepInfo.icon,
                  color: stepInfo.iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stepInfo.title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (stepInfo.subtitle != null)
                      Text(
                        stepInfo.subtitle!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          
          if (stepInfo.description != null) ...[
            const SizedBox(height: 12),
            Text(
              stepInfo.description!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
          
          // Step content widget
          if (stepInfo.content != null) ...[
            const SizedBox(height: 16),
            stepInfo.content!,
          ],
          
          // Step details
          if (stepInfo.details.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...stepInfo.details.map((detail) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      detail,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomControls(ControlsDetails details) {
    final isLastStep = _currentStep == widget.stepData.steps.length - 1;
    final canProceed = widget.stepData.steps[_currentStep].canProceed;
    
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          // Back button
          if (_currentStep > 0 && widget.canGoBack)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: details.onStepCancel,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: BorderSide(color: AppColors.borderMedium),
                ),
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Quay lại'),
              ),
            ),
          
          if (_currentStep > 0 && widget.canGoBack) const SizedBox(width: 12),
          
          // Next/Complete button
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: canProceed && widget.canGoNext
                  ? () {
                      if (isLastStep) {
                        widget.onCompleted?.call();
                      } else {
                        details.onStepContinue?.call();
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: Icon(
                isLastStep ? Icons.check : Icons.arrow_forward,
                size: 18,
              ),
              label: Text(
                isLastStep ? 'Hoàn thành' : 'Tiếp tục',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget hiển thị tiến trình ngang
class ShareXeHorizontalStepper extends StatelessWidget {
  final List<String> stepTitles;
  final int currentStep;
  final int completedSteps;

  const ShareXeHorizontalStepper({
    super.key,
    required this.stepTitles,
    required this.currentStep,
    this.completedSteps = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: stepTitles.asMap().entries.map((entry) {
          final index = entry.key;
          final title = entry.value;
          final isActive = index == currentStep;
          final isCompleted = index < completedSteps;
          final isLast = index == stepTitles.length - 1;
          
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      // Step circle
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isCompleted 
                              ? AppColors.success
                              : isActive 
                                  ? AppColors.primary
                                  : AppColors.borderLight,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isActive ? AppColors.primary : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: isCompleted
                              ? Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                )
                              : Text(
                                  '${index + 1}',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: isActive ? Colors.white : AppColors.textSecondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Step title
                      Text(
                        title,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isActive ? AppColors.primary : AppColors.textSecondary,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Connector line
                if (!isLast)
                  Container(
                    height: 2,
                    width: 20,
                    margin: const EdgeInsets.only(bottom: 24),
                    color: isCompleted ? AppColors.success : AppColors.borderLight,
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Data class cho booking stepper
class BookingStepData {
  final List<BookingStepInfo> steps;
  final int currentStep;
  final int maxCompletedStep;

  const BookingStepData({
    required this.steps,
    this.currentStep = 0,
    this.maxCompletedStep = 0,
  });

  BookingStepData copyWith({
    List<BookingStepInfo>? steps,
    int? currentStep,
    int? maxCompletedStep,
  }) {
    return BookingStepData(
      steps: steps ?? this.steps,
      currentStep: currentStep ?? this.currentStep,
      maxCompletedStep: maxCompletedStep ?? this.maxCompletedStep,
    );
  }
}

/// Data class cho từng bước
class BookingStepInfo {
  final String title;
  final String? subtitle;
  final String? description;
  final IconData icon;
  final Color iconColor;
  final Widget? content;
  final List<String> details;
  final bool canProceed;

  const BookingStepInfo({
    required this.title,
    this.subtitle,
    this.description,
    required this.icon,
    required this.iconColor,
    this.content,
    this.details = const [],
    this.canProceed = true,
  });
}

/// Factory tạo booking steps cho ShareXe
class ShareXeBookingSteps {
  static BookingStepData createRideBookingSteps({
    Widget? searchContent,
    Widget? selectionContent,
    Widget? paymentContent,
    Widget? confirmationContent,
  }) {
    return BookingStepData(
      steps: [
        BookingStepInfo(
          title: 'Tìm chuyến đi',
          subtitle: 'Nhập thông tin điểm đi và điểm đến',
          description: 'Chọn địa điểm xuất phát, điểm đến và thời gian khởi hành phù hợp với lịch trình của bạn.',
          icon: Icons.search,
          iconColor: AppColors.info,
          content: searchContent,
          details: [
            'Chọn điểm xuất phát',
            'Chọn điểm đến',
            'Chọn thời gian khởi hành',
            'Số lượng hành khách',
          ],
        ),
        BookingStepInfo(
          title: 'Chọn chuyến đi',
          subtitle: 'Chọn chuyến đi phù hợp',
          description: 'Xem danh sách các chuyến đi có sẵn và chọn chuyến phù hợp nhất với bạn.',
          icon: Icons.directions_car,
          iconColor: AppColors.primary,
          content: selectionContent,
          details: [
            'Xem thông tin tài xế',
            'Kiểm tra đánh giá',
            'So sánh giá cả',
            'Chọn chỗ ngồi',
          ],
        ),
        BookingStepInfo(
          title: 'Thanh toán',
          subtitle: 'Xác nhận và thanh toán',
          description: 'Kiểm tra thông tin đặt chỗ và tiến hành thanh toán để hoàn tất đặt chuyến.',
          icon: Icons.payment,
          iconColor: AppColors.warning,
          content: paymentContent,
          details: [
            'Kiểm tra thông tin đặt chỗ',
            'Chọn phương thức thanh toán',
            'Xác nhận thanh toán',
          ],
        ),
        BookingStepInfo(
          title: 'Xác nhận',
          subtitle: 'Đặt chỗ thành công',
          description: 'Đặt chỗ của bạn đã được xác nhận. Hãy chuẩn bị cho chuyến đi!',
          icon: Icons.check_circle,
          iconColor: AppColors.success,
          content: confirmationContent,
          details: [
            'Nhận mã đặt chỗ',
            'Lưu thông tin chuyến đi',
            'Liên hệ với tài xế',
            'Chuẩn bị cho chuyến đi',
          ],
        ),
      ],
    );
  }

  static BookingStepData createDriverRideSteps({
    Widget? routeContent,
    Widget? scheduleContent,
    Widget? pricingContent,
    Widget? publishContent,
  }) {
    return BookingStepData(
      steps: [
        BookingStepInfo(
          title: 'Lộ trình',
          subtitle: 'Thiết lập lộ trình đi',
          description: 'Nhập thông tin điểm xuất phát, điểm đến và các điểm dừng trung gian.',
          icon: Icons.route,
          iconColor: AppColors.info,
          content: routeContent,
          details: [
            'Điểm xuất phát',
            'Điểm đến',
            'Điểm dừng trung gian',
            'Ước tính thời gian',
          ],
        ),
        BookingStepInfo(
          title: 'Lịch trình',
          subtitle: 'Chọn thời gian khởi hành',
          description: 'Thiết lập thời gian khởi hành và các thông tin về chuyến đi.',
          icon: Icons.schedule,
          iconColor: AppColors.primary,
          content: scheduleContent,
          details: [
            'Thời gian khởi hành',
            'Số ghế trống',
            'Ghi chú cho hành khách',
          ],
        ),
        BookingStepInfo(
          title: 'Định giá',
          subtitle: 'Thiết lập giá cước',
          description: 'Đặt giá cho chuyến đi dựa trên quãng đường và thời gian.',
          icon: Icons.attach_money,
          iconColor: AppColors.warning,
          content: pricingContent,
          details: [
            'Giá mỗi ghế',
            'Phí dịch vụ',
            'Chính sách hủy',
          ],
        ),
        BookingStepInfo(
          title: 'Đăng chuyến',
          subtitle: 'Xuất bản chuyến đi',
          description: 'Xem lại thông tin và đăng chuyến đi để hành khách có thể đặt chỗ.',
          icon: Icons.publish,
          iconColor: AppColors.success,
          content: publishContent,
          details: [
            'Kiểm tra thông tin',
            'Xuất bản chuyến đi',
            'Chờ hành khách đặt chỗ',
          ],
        ),
      ],
    );
  }
}
