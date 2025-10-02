import 'package:flutter/material.dart';
import 'package:rasoi_app/widgets/custom_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:rasoi_app/services/firestore_service.dart'; // Import FirestoreService
import 'package:rasoi_app/models/app_notification.dart'; // Import AppNotification model

class NotificationsScreen extends StatefulWidget { // Change to StatefulWidget
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  String _getTimeAgo(DateTime timestamp) {
    final Duration diff = DateTime.now().difference(timestamp);

    if (diff.inDays > 365) {
      return '${(diff.inDays / 365).floor()} years ago';
    } else if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()} months ago';
    } else if (diff.inDays > 7) {
      return '${(diff.inDays / 7).floor()} weeks ago';
    }
    if (diff.inDays > 0) {
      return '${diff.inDays} days ago';
    }
    if (diff.inHours > 0) {
      return '${diff.inHours} hours ago';
    }
    if (diff.inMinutes > 0) {
      return '${diff.inMinutes} minutes ago';
    }
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    final String? uid = _currentUser?.uid; // Get UID of the current user

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Notifications',
        showNotification: false, // Don't show notification icon on the notification screen itself
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your recent updates and messages.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              if (uid == null)
                const Center(child: Text('Please log in to view your notifications.'))
              else
                StreamBuilder<List<AppNotification>>(
                  stream: _firestoreService.getAdminNotifications(uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No notifications found.'));
                    }

                    final notifications = snapshot.data!;

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return GestureDetector(
                          onTap: () => _showNotificationDialog(context, notification),
                          child: _buildNotificationCard(
                            icon: Icons.notifications,
                            title: notification.title,
                            subtitle: notification.message,
                            description: '', // Admin messages typically have message as main content
                            time: _getTimeAgo(notification.timestamp),
                          ),
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationDialog(BuildContext context, AppNotification notification) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(notification.title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(notification.message),
                const SizedBox(height: 10),
                Text('Received: ${_getTimeAgo(notification.timestamp)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required String time,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.deepOrange),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[700]),
            ),
            if (description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  description,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                time,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
