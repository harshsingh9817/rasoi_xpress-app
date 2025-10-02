import 'package:flutter/material.dart';
import 'package:rasoi_app/screens/notifications_screen.dart'; // Import NotificationsScreen
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:rasoi_app/services/firestore_service.dart'; // Import FirestoreService

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool showNotification;
  final Widget? leading;
  final List<Widget>? actions;
  final Function(String?)? onSearch; // Callback for search functionality

  const CustomAppBar({
    super.key,
    this.title = 'Rasoi Xpress',
    this.showNotification = true,
    this.leading,
    this.actions,
    this.onSearch, // Initialize onSearch
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false; // New state variable to control search bar visibility

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        // If search is deactivated, clear query and notify parent
        _searchController.clear();
        if (widget.onSearch != null) {
          widget.onSearch!(null);
        }
      }
    });
  }

  void _performSearch() {
    if (widget.onSearch != null) {
      widget.onSearch!(_searchController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? uid = FirebaseAuth.instance.currentUser?.uid; // Get current user UID

    return AppBar(
      title: _isSearching
          ? TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search food...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey[700]),
              ),
              style: const TextStyle(color: Colors.black, fontSize: 18),
              autofocus: true,
              onSubmitted: (value) {
                _performSearch();
              },
            )
          : Row(
              children: [
                Image.asset('assets/rasoi_logo.png', height: 30),
                const SizedBox(width: 10),
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      centerTitle: false,
      leading: widget.leading,
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.deepOrange),
          onPressed: _toggleSearch,
        ),
        if (widget.showNotification && uid != null && !_isSearching) // Only show notification icon if not searching
          StreamBuilder<int>(
            stream: FirestoreService().getAdminNotifications(uid, onlyUnread: true).map((notifications) => notifications.length),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data ?? 0;
              return IconButton(
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications_none, color: Colors.deepOrange),
                    if (unreadCount > 0)
                      Positioned(
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(1),
                          constraints: const BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                  ],
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                  );
                  // Mark all unread notifications as read when the notification screen is opened
                  FirestoreService().getAdminNotifications(uid, onlyUnread: true).first.then((notifications) {
                    for (var notification in notifications) {
                      FirestoreService().markNotificationAsRead(uid, notification.id);
                    }
                  });
                },
              );
            },
          ),
        ...?widget.actions,
      ],
    );
  }
}
