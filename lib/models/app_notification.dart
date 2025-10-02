import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final String? userEmail;
  final String? userId;
  final bool isRead; // Add isRead field

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.userEmail,
    this.userId,
    this.isRead = false, // Default to false
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      userEmail: data['userEmail'] as String?,
      userId: data['userId'] as String?,
      isRead: data['isRead'] ?? false, // Parse isRead field
    );
  }
}
