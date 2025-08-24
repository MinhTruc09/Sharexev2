import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:sharexev2/config/theme.dart';

class NotificationDetailsPage extends StatelessWidget {
  const NotificationDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final message = ModalRoute.of(context)!.settings.arguments as RemoteMessage;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: ThemeManager.getPrimaryColorForRole('PASSENGER'),
        foregroundColor: Colors.white,
        title: Text(
          'Notification Details',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: ThemeManager.getPrimaryColorForRole('PASSENGER').withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getNotificationIcon(message.data['type']),
                size: 40,
                color: ThemeManager.getPrimaryColorForRole('PASSENGER'),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Title
            if (message.notification?.title != null)
              Text(
                message.notification!.title!,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Body
            if (message.notification?.body != null)
              Text(
                message.notification!.body!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Data section
            if (message.data.isNotEmpty) ...[
              Text(
                'Additional Information:',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: message.data.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(
                              '${entry.key}:',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              entry.value.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            
            const Spacer(),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: ThemeManager.getPrimaryColorForRole('PASSENGER')),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        color: ThemeManager.getPrimaryColorForRole('PASSENGER'),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleAction(context, message),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeManager.getPrimaryColorForRole('PASSENGER'),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      _getActionText(message.data['type']),
                      style: const TextStyle(
                        color: Colors.white,
                      ),
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

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'chat_message':
        return Icons.chat_bubble;
      case 'trip_update':
        return Icons.directions_car;
      case 'booking_request':
        return Icons.book_online;
      case 'payment':
        return Icons.payment;
      default:
        return Icons.notifications;
    }
  }

  String _getActionText(String? type) {
    switch (type) {
      case 'chat_message':
        return 'Open Chat';
      case 'trip_update':
        return 'View Trip';
      case 'booking_request':
        return 'View Booking';
      case 'payment':
        return 'View Payment';
      default:
        return 'Take Action';
    }
  }

  void _handleAction(BuildContext context, RemoteMessage message) {
    final data = message.data;
    
    switch (data['type']) {
      case 'chat_message':
        Navigator.pushReplacementNamed(
          context,
          '/chat',
          arguments: {
            'roomId': data['roomId'],
            'participantName': data['senderName'] ?? 'Unknown',
            'participantEmail': data['senderEmail'],
          },
        );
        break;
      case 'trip_update':
        Navigator.pushReplacementNamed(
          context,
          '/trip-details',
          arguments: data['tripId'],
        );
        break;
      case 'booking_request':
        Navigator.pushReplacementNamed(
          context,
          '/booking-details',
          arguments: data['bookingId'],
        );
        break;
      default:
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Action not available')),
        );
    }
  }
}
