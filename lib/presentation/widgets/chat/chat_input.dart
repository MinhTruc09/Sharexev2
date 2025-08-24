import 'package:flutter/material.dart';
import 'package:sharexev2/config/theme.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final Function()? onStartTyping;
  final Function()? onStopTyping;
  final bool isConnected;
  final bool isSending;

  const ChatInput({
    super.key,
    required this.onSendMessage,
    this.onStartTyping,
    this.onStopTyping,
    this.isConnected = true,
    this.isSending = false,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    
    if (hasText && !_isTyping) {
      _isTyping = true;
      widget.onStartTyping?.call();
    } else if (!hasText && _isTyping) {
      _isTyping = false;
      widget.onStopTyping?.call();
    }
  }

  void _sendMessage() {
    final message = _controller.text.trim();
    if (message.isNotEmpty && widget.isConnected && !widget.isSending) {
      widget.onSendMessage(message);
      _controller.clear();
      _isTyping = false;
      widget.onStopTyping?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!widget.isConnected)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingS,
                ),
                margin: EdgeInsets.only(bottom: AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.wifi_off,
                      color: Colors.orange.shade700,
                      size: 16,
                    ),
                    SizedBox(width: AppTheme.spacingS),
                    Text(
                      'Reconnecting...',
                      style: AppTheme.bodySmall.copyWith(
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            
            Row(
              children: [
                // Attachment button
                IconButton(
                  onPressed: widget.isConnected ? _showAttachmentOptions : null,
                  icon: Icon(
                    Icons.attach_file,
                    color: widget.isConnected 
                        ? AppTheme.passengerPrimary 
                        : Colors.grey,
                  ),
                ),
                
                // Text input
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                      border: Border.all(
                        color: _focusNode.hasFocus 
                            ? AppTheme.passengerPrimary 
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      enabled: widget.isConnected && !widget.isSending,
                      maxLines: 4,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: widget.isConnected 
                            ? 'Type a message...' 
                            : 'Connecting...',
                        hintStyle: AppTheme.bodyMedium.copyWith(
                          color: Colors.grey.shade500,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingM,
                          vertical: AppTheme.spacingS,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                
                SizedBox(width: AppTheme.spacingS),
                
                // Send button
                Container(
                  decoration: BoxDecoration(
                    color: _canSendMessage() 
                        ? AppTheme.passengerPrimary 
                        : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _canSendMessage() ? _sendMessage : null,
                    icon: widget.isSending
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _canSendMessage() {
    return widget.isConnected && 
           !widget.isSending && 
           _controller.text.trim().isNotEmpty;
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppTheme.radiusL),
            topRight: Radius.circular(AppTheme.radiusL),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(top: AppTheme.spacingM),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Padding(
              padding: EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                children: [
                  Text(
                    'Send Attachment',
                    style: AppTheme.headingMedium,
                  ),
                  
                  SizedBox(height: AppTheme.spacingL),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildAttachmentOption(
                        icon: Icons.photo_camera,
                        label: 'Camera',
                        onTap: () {
                          Navigator.pop(context);
                          _handleCameraAttachment();
                        },
                      ),
                      _buildAttachmentOption(
                        icon: Icons.photo_library,
                        label: 'Gallery',
                        onTap: () {
                          Navigator.pop(context);
                          _handleGalleryAttachment();
                        },
                      ),
                      _buildAttachmentOption(
                        icon: Icons.location_on,
                        label: 'Location',
                        onTap: () {
                          Navigator.pop(context);
                          _handleLocationAttachment();
                        },
                      ),
                    ],
                  ),
                  
                  SizedBox(height: AppTheme.spacingL),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.passengerPrimary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppTheme.passengerPrimary,
              size: 28,
            ),
          ),
          SizedBox(height: AppTheme.spacingS),
          Text(
            label,
            style: AppTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _handleCameraAttachment() {
    // TODO: Implement camera functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Camera feature coming soon')),
    );
  }

  void _handleGalleryAttachment() {
    // TODO: Implement gallery functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gallery feature coming soon')),
    );
  }

  void _handleLocationAttachment() {
    // TODO: Implement location sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location sharing coming soon')),
    );
  }
}
