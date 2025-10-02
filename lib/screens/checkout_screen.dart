import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rasoi_app/providers/cart_provider.dart';
import 'package:rasoi_app/screens/payment_screen.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:rasoi_app/services/firestore_service.dart'; // Import FirestoreService
// import 'package:rasoi_app/models/user.dart' as user_model; // Import User model with alias
import 'package:rasoi_app/models/address.dart'; // Import Address model
import 'package:rasoi_app/models/order.dart' as order_model; // Import Order model with alias
import 'package:rasoi_app/models/order_item.dart'; // Import OrderItem model
// import 'package:intl/intl.dart'; // Import for date formatting

class CheckoutScreen extends StatefulWidget { // Change to StatefulWidget
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  User? _currentUser;
  Address? _selectedAddress; // To store the selected address
  late Stream<List<Address>> _addressesStream; // Stream for user addresses

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      _addressesStream = _firestoreService.getAddresses(_currentUser!.uid);
      _addressesStream.listen((addresses) {
        if (addresses.isNotEmpty) {
          setState(() {
            _selectedAddress = addresses.firstWhere((addr) => addr.isDefault, orElse: () => addresses.first);
          });
        } else {
          // If no addresses are found, set selected address to null
          setState(() {
            _selectedAddress = null;
          });
        }
      });
    }
  }

  Future<void> _placeOrder(CartProvider cart) async {
    if (_currentUser == null || _selectedAddress == null || cart.itemCount == 0) {
      // Handle error: user not logged in, no address selected, or cart is empty
      if (!context.mounted) return; // Check context validity after async gap
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in, select an address, and add items to your cart.')),
      );
      return;
    }

    try {
      final List<OrderItem> orderItems = cart.items.values
          .map((cartItem) => OrderItem(
                id: cartItem.id,
                category: cartItem.category,
                description: cartItem.description,
                imageUrl: cartItem.imageUrl,
                ingredients: cartItem.ingredients,
                isPopular: cartItem.isPopular,
                isVegetarian: cartItem.isVegetarian,
                isVisible: cartItem.isVisible,
                name: cartItem.name,
                price: cartItem.price,
                quantity: cartItem.quantity,
                taxRate: cartItem.taxRate,
              ))
          .toList();

      final double subtotal = cart.totalAmount;
      final double taxes = subtotal * 0.05; // 5% tax
      const double deliveryFee = 0.0; // Currently free
      final double grandTotal = subtotal + taxes + deliveryFee;

      final order = order_model.Order(
        id: DateTime.now().toIso8601String(), // Unique ID for the order
        userId: _currentUser!.uid,
        userEmail: _currentUser!.email ?? '',
        customerName: _currentUser!.displayName ?? _selectedAddress!.fullName,
        customerPhone: _selectedAddress!.phone,
        shippingAddress: '${_selectedAddress!.street}, ${_selectedAddress!.city}, ${_selectedAddress!.pinCode}, India',
        shippingLat: _selectedAddress!.lat,
        shippingLng: _selectedAddress!.lng,
        paymentMethod: "Cash on Delivery", // Default to COD for now
        status: "Pending",
        total: grandTotal,
        totalTax: taxes,
        deliveryFee: deliveryFee,
        items: orderItems,
        createdAt: DateTime.now(),
      );

      await _firestoreService.placeOrder(order);
      cart.clearCart(); // Clear cart after successful order

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const PaymentScreen()), // Navigate to payment screen or confirmation
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order: ${error.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shipping Address',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Select an address or add a new one using the map.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),
            StreamBuilder<List<Address>>(
              stream: _addressesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final List<Address> addresses = snapshot.data ?? [];

                if (addresses.isEmpty) {
                  return const Text('No addresses found. Please add one in your profile.');
                }

                return Column(
                  children: addresses.map((address) {
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: _selectedAddress?.id == address.id ? Colors.deepOrange : Colors.grey.shade300),
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedAddress = address;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(address.type == 'Home' ? Icons.home : Icons.work, color: Colors.deepOrange),
                                      const SizedBox(width: 10),
                                      Text(
                                        '${address.type} Address ${address.isDefault ? '(Default)' : ''}',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  if (_selectedAddress?.id == address.id)
                                    const Icon(Icons.check_circle, color: Colors.green),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(address.fullName),
                              Text('${address.street}, ${address.city}, ${address.pinCode}, India'),
                              Text(address.phone),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Handle Add New Address via Map
                },
                icon: const Icon(Icons.add_location_alt_outlined, color: Colors.deepOrange),
                label: const Text('Add New Address via Map', style: TextStyle(color: Colors.deepOrange)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.deepOrange),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildOrderSummaryRow('Free Delivery Unlocked!', 'All delivery fees are currently waived as part of a special promotion.', isPromotion: true),
                    const Divider(),
                    _buildOrderSummaryRow('Subtotal:', 'Rs.${cart.totalAmount.toStringAsFixed(2)}'),
                    _buildOrderSummaryRow('Taxes:', 'Rs.${(cart.totalAmount * 0.05).toStringAsFixed(2)}'), // 5% tax
                    _buildOrderSummaryRow('Delivery Fee:', 'FREE', isFree: true, distance: '4.48 km'),
                    const Divider(),
                    _buildOrderSummaryRow('Total:', 'Rs.${(cart.totalAmount * 1.05).toStringAsFixed(2)}', isTotal: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () => _placeOrder(cart), // Call _placeOrder on press
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                ),
                child: const Text('Place Order', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryRow(String label, String value, {bool isPromotion = false, bool isFree = false, String? distance, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isPromotion ? 14 : 16,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  color: isPromotion ? Colors.green : Colors.black,
                ),
              ),
              if (isPromotion)
                Text(
                  value,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isFree ? 'FREE' : value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  color: isFree ? Colors.green : Colors.black,
                ),
              ),
              if (isFree && distance != null)
                Text(
                  'Distance: $distance',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
