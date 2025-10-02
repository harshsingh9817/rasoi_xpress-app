import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rasoi_app/models/slider_item.dart'; // Corrected import for SliderItem
import 'package:rasoi_app/models/category.dart'; // Import for Category model
import 'package:rasoi_app/models/user.dart'; // Import for User model
import 'package:rasoi_app/models/address.dart'; // Import for Address model
import 'package:rasoi_app/models/cart_item.dart'; // Import for CartItem model
import 'package:rasoi_app/models/order.dart' as order_model; // Import for Order model with alias
// import 'package:rasoi_app/models/order_item.dart'; // Import for OrderItem model
import 'package:rasoi_app/models/app_notification.dart'; // Import AppNotification model
import 'package:rasoi_app/models/support_ticket.dart'; // Import SupportTicket model

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Example: Get all food items from a 'food_items' collection
  Stream<List<Map<String, dynamic>>> getFoodItems({
    String? searchQuery,
    String? categoryName, // Add categoryName parameter
  }) {
    Query collectionRef = _db.collection('menuItems');

    if (searchQuery != null && searchQuery.isNotEmpty) {
      // For case-insensitive search, you need to store a 'lowercaseName' field in Firestore.
      // Make sure all your 'menuItems' documents have a 'lowercaseName' field set to the lowercase version of their 'name'.
      String lowerCaseSearchQuery = searchQuery.toLowerCase();
      collectionRef = collectionRef
          .where('lowercaseName', isGreaterThanOrEqualTo: lowerCaseSearchQuery)
          .where('lowercaseName', isLessThanOrEqualTo: '$lowerCaseSearchQuery\uf8ff');
    }

    // Add category filtering
    if (categoryName != null && categoryName.isNotEmpty) {
      collectionRef = collectionRef.where('category', isEqualTo: categoryName);
    }

    return collectionRef.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          return {
            ...?data, // Null-aware spread operator
            'id': doc.id,
          };
        }).toList());
  }

  // Example: Add a new user to a 'users' collection
  Future<void> addUser(String uid, Map<String, dynamic> userData) async {
    await _db.collection('users').doc(uid).set(userData);
  }

  // Example: Update user data
  Future<void> updateUserData(String uid, Map<String, dynamic> newData) async {
    await _db.collection('users').doc(uid).update(newData);
  }

  Stream<User?> getUser(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      return User.fromFirestore(snapshot.data()!, snapshot.id);
    });
  }

  Stream<List<Address>> getAddresses(String uid) {
    return _db.collection('users').doc(uid).collection('addresses').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Address.fromFirestore(doc.data(), doc.id)).toList());
  }

  Stream<List<CartItem>> getCartItems(String uid) {
    return _db.collection('users').doc(uid).collection('cart').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => CartItem.fromFirestore(doc.data(), doc.id)).toList());
  }

  Future<void> placeOrder(order_model.Order order) async {
    await _db.collection('orders').add(order.toFirestore());
  }

  Stream<List<order_model.Order>> getUserOrders(String userId) {
    return _db.collection('orders').where('userId', isEqualTo: userId).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => order_model.Order.fromFirestore(doc)).toList());
  }

  Stream<List<AppNotification>> getAdminNotifications(String userId, {bool onlyUnread = false}) {
    Query collectionRef = _db.collection('adminMessages')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true);

    if (onlyUnread) {
      collectionRef = collectionRef.where('isRead', isEqualTo: false);
    }

    return collectionRef.snapshots().map((snapshot) => snapshot.docs
            .map((doc) => AppNotification.fromFirestore(doc))
            .toList());
  }

  Future<void> markNotificationAsRead(String userId, String notificationId) async {
    await _db.collection('adminMessages').doc(notificationId).update({'isRead': true});
  }

  Future<void> addOrUpdateCartItem(String uid, CartItem item) async {
    await _db.collection('users').doc(uid).collection('cart').doc(item.id).set(item.toFirestore());
  }

  Future<void> removeCartItem(String uid, String itemId) async {
    await _db.collection('users').doc(uid).collection('cart').doc(itemId).delete();
  }

  Future<void> clearCart(String uid) async {
    final batch = _db.batch();
    final cartSnapshot = await _db.collection('users').doc(uid).collection('cart').get();
    for (var doc in cartSnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // Address Management
  Future<void> addAddress(String uid, Address address) async {
    await _db.collection('users').doc(uid).collection('addresses').add(address.toFirestore());
  }

  Future<void> updateAddress(String uid, Address address) async {
    await _db.collection('users').doc(uid).collection('addresses').doc(address.id).update(address.toFirestore());
  }

  Future<void> deleteAddress(String uid, String addressId) async {
    await _db.collection('users').doc(uid).collection('addresses').doc(addressId).delete();
  }

  // You can add more methods here for other collections and operations

  // Get hero slider items from the 'globals' collection and 'hero' document
  Stream<List<SliderItem>> getHeroSliderItems() {
    return _db.collection('globals').doc('hero').snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return [];
      }
      final data = snapshot.data()!;
      final List<SliderItem> sliderItems = [];
      // Check if 'media' field exists and is a List
      if (data.containsKey('media') && data['media'] is List) {
        for (var item in data['media']) {
          if (item is Map<String, dynamic> && item.containsKey('type')) {
            sliderItems.add(SliderItem.fromFirestore(item));
          }
        }
      }

      // Sort by order
      sliderItems.sort((a, b) => a.order.compareTo(b.order));
      return sliderItems;
    });
  }

  Stream<List<Category>> getCategories() {
    return _db.collection('categories').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Category.fromFirestore(doc.data(), doc.id)).toList());
  }

  Future<void> sendHelpMessage(SupportTicket ticket) async {
    await _db.collection('supportTickets').add(ticket.toFirestore());
  }

  Future<void> cancelOrder(String orderId) async {
    await _db.collection('orders').doc(orderId).update({'status': 'Cancelled'});
  }
}
