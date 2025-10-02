import 'package:flutter/foundation.dart';
import 'package:rasoi_app/models/cart_item.dart';
import 'package:rasoi_app/screens/menu_screen.dart'; // Import FoodItem
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:rasoi_app/services/firestore_service.dart'; // Import FirestoreService

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};
  final FirestoreService _firestoreService = FirestoreService(); // Instance of FirestoreService
  String? _userId; // To store the current user's UID

  CartProvider() {
    _setupAuthListener();
  }

  void _setupAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _userId = user.uid;
        _fetchCartItems(); // Fetch cart items when user logs in
      } else {
        _userId = null;
        _items.clear(); // Clear cart if user logs out
        notifyListeners();
      }
    });
  }

  Future<void> _fetchCartItems() async {
    if (_userId == null) return;

    _firestoreService.getCartItems(_userId!).listen((cartItems) {
      _items.clear();
      for (var item in cartItems) {
        _items[item.id] = item;
      }
      notifyListeners();
    });
  }

  Map<String, CartItem> get items => {..._items};

  int get itemCount {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalAmount {
    return _items.values.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  void addItem(
    FoodItem foodItem,
  ) async { // Make it async
    if (_userId == null) return; // Only add if user is logged in

    if (_items.containsKey(foodItem.id)) {
      final existingCartItem = _items[foodItem.id]!;
      final updatedItem = existingCartItem.copyWith(quantity: existingCartItem.quantity + 1);
      _items.update(foodItem.id, (existing) => updatedItem);
      await _firestoreService.addOrUpdateCartItem(_userId!, updatedItem); // Update in Firestore
    } else {
      final newItem = CartItem(
        id: foodItem.id,
        category: foodItem.category ?? '',
        description: foodItem.description,
        imageUrl: foodItem.imageUrl,
        ingredients: foodItem.ingredients ?? '',
        isPopular: foodItem.isPopular,
        isVegetarian: foodItem.isVegetarian,
        isVisible: true, // Assuming new items are visible
        name: foodItem.title,
        price: double.parse(foodItem.price.replaceAll('Rs.', '')), // Parse price string to double
        quantity: 1,
        taxRate: 0.05, // Default tax rate, adjust as needed
      );
      _items.putIfAbsent(foodItem.id, () => newItem);
      await _firestoreService.addOrUpdateCartItem(_userId!, newItem); // Add to Firestore
    }
    notifyListeners();
  }

  void incrementItemQuantity(String productId) async {
    if (_userId == null || !_items.containsKey(productId)) return;

    final existingCartItem = _items[productId]!;
    final updatedItem = existingCartItem.copyWith(quantity: existingCartItem.quantity + 1);
    _items.update(productId, (existing) => updatedItem);
    await _firestoreService.addOrUpdateCartItem(_userId!, updatedItem);
    notifyListeners();
  }

  void removeItem(String productId) async { // Make it async
    if (_userId == null) return;
    _items.remove(productId);
    await _firestoreService.removeCartItem(_userId!, productId); // Remove from Firestore
    notifyListeners();
  }

  void removeSingleItem(String productId) async { // Make it async
    if (_userId == null) return;

    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId]!.quantity > 1) {
      final existingCartItem = _items[productId]!;
      final updatedItem = existingCartItem.copyWith(quantity: existingCartItem.quantity - 1);
      _items.update(productId, (existing) => updatedItem);
      await _firestoreService.addOrUpdateCartItem(_userId!, updatedItem); // Update in Firestore
    } else {
      _items.remove(productId);
      await _firestoreService.removeCartItem(_userId!, productId); // Remove from Firestore
    }
    notifyListeners();
  }

  void clearCart() async { // Make it async
    if (_userId == null) return;
    _items.clear();
    await _firestoreService.clearCart(_userId!); // Clear from Firestore
    notifyListeners();
  }
}

