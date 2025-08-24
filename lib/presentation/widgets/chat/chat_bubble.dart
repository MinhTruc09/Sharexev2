import 'package:flutter/material.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/data/models/chat_message.dart';
import 'package:sharexev2/data/services/chat_service.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showAvatar;
  final bool showTimestamp;

  const ChatBubble({
    super.key,
    required this.message,
    this.showAvatar = true,
    this.showTimestamp = true,
  });

  @override
  Widget build(BuildContext context) {
    final isFromMe = message.isFromMe;
    
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: AppTheme.spacingXs,
        horizontal: AppTheme.spacingM,
      ),
      child: Row(
        mainAxisAlignment: isFromMe 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isFromMe && showAvatar) ...[
            _buildAvatar(),
            SizedBox(width: AppTheme.spacingS),
          ],
          
          Flexible(
            child: Column(
              crossAxisAlignment: isFromMe 
                  ? CrossAxisAlignment.end 
                  : CrossAxisAlignment.start,
              children: [
                if (!isFromMe && message.senderName.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(
                      left: AppTheme.spacingS,
                      bottom: AppTheme.spacingXs,
                    ),
                    child: Text(
                      message.senderName,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingM,
                    vertical: AppTheme.spacingS,
                  ),
                  decoration: BoxDecoration(
                    color: isFromMe 
                        ? AppTheme.passengerPrimary
                        : AppTheme.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppTheme.radiusM),
                      topRight: Radius.circular(AppTheme.radiusM),
                      bottomLeft: Radius.circular(isFromMe ? AppTheme.radiusM : AppTheme.radiusS),
                      bottomRight: Radius.circular(isFromMe ? AppTheme.radiusS : AppTheme.radiusM),
                    ),
                    border: isFromMe 
                        ? null 
                        : Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                    boxShadow: AppTheme.shadowLight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.content,
                        style: AppTheme.bodyMedium.copyWith(
                          color: isFromMe ? Colors.white : AppTheme.textPrimary,
                        ),
                      ),
                      
                      if (showTimestamp) ...[
                        SizedBox(height: AppTheme.spacingXs),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatTime(message.timestamp),
                              style: AppTheme.bodySmall.copyWith(
                                color: isFromMe 
                                    ? Colors.white70 
                                    : AppTheme.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                            
                            if (isFromMe) ...[
                              SizedBox(width: AppTheme.spacingXs),
                              Icon(
                                message.read 
                                    ? Icons.done_all 
                                    : Icons.done,
                                size: 14,
                                color: message.read 
                                    ? Colors.blue.shade300
                                    : Colors.white70,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          if (isFromMe && showAvatar) ...[
            SizedBox(width: AppTheme.spacingS),
            _buildAvatar(),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 16,
      backgroundColor: message.isFromMe 
          ? AppTheme.passengerPrimary 
          : AppTheme.driverPrimary,
      child: Text(
        message.senderName.isNotEmpty 
            ? message.senderName[0].toUpperCase()
            : '?',
        style: AppTheme.bodySmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
    
    if (messageDate == today) {
      // Today - show time only
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      // Yesterday
      return 'Yesterday ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      // Older - show date
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}

// Typing indicator widget
class TypingIndicator extends StatefulWidget {
  final String userName;

  const TypingIndicator({
    super.key,
    required this.userName,
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: AppTheme.spacingXs,
        horizontal: AppTheme.spacingM,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.driverPrimary,
            child: Text(
              widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : '?',
              style: AppTheme.bodySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: AppTheme.spacingS),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.spacingM,
              vertical: AppTheme.spacingS,
            ),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${widget.userName} is typing',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(width: AppTheme.spacingS),
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Row(
                      children: List.generate(3, (index) {
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 1),
                          child: Opacity(
                            opacity: (_animation.value + index * 0.3) % 1.0,
                            child: Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppTheme.textSecondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
