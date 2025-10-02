import 'package:cloud_firestore/cloud_firestore.dart';

class SupportTicket {
  final String message;
  final String status;
  final Timestamp timestamp;
  final String userEmail;
  final String userId;
  final String userName;

  SupportTicket({
    required this.message,
    required this.status,
    required this.timestamp,
    required this.userEmail,
    required this.userId,
    required this.userName,
  });

  // Factory constructor to create a SupportTicket from a Firestore document
  factory SupportTicket.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SupportTicket(
      message: data['message'] ?? '',
      status: data['status'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      userEmail: data['userEmail'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
    );
  }

  // Method to convert a SupportTicket object into a Firestore-compatible Map
  Map<String, dynamic> toFirestore() {
    return {
      'message': message,
      'status': status,
      'timestamp': timestamp,
      'userEmail': userEmail,
      'userId': userId,
      'userName': userName,
    };
  }
}
