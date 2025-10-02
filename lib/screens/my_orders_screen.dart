import 'package:flutter/material.dart';
import 'package:rasoi_app/widgets/order_item_card.dart';
import 'package:rasoi_app/widgets/bill_details_modal.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:rasoi_app/services/firestore_service.dart'; // Import FirestoreService
import 'package:rasoi_app/models/order.dart' as order_model; // Import Order model with alias
import 'package:intl/intl.dart'; // Import for date formatting
// import 'package:rasoi_app/widgets/custom_app_bar.dart'; // Import CustomAppBar

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String? uid = FirebaseAuth.instance.currentUser?.uid; // Get current user UID
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      // appBar: const CustomAppBar(
      //   title: 'My Orders',
      //   showNotification: false,
      //   leading: null,
      // ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'View your order history and track current orders.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              if (uid == null)
                const Center(child: Text('Please log in to view your orders.'))
              else
                StreamBuilder<List<order_model.Order>>(
                  stream: firestoreService.getUserOrders(uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No orders found.'));
                    }

                    final orders = snapshot.data!;

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        final formattedDate = DateFormat('dd/MM/yyyy, HH:mm:ss').format(order.createdAt);
                        final formattedBillDate = DateFormat('MMM d, yyyy, h:mm a').format(order.createdAt);
                        final subtotal = order.items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

                        return OrderItemCard(
                          orderId: order.id,
                          date: formattedDate,
                          status: order.status,
                          totalAmount: 'Rs.${order.total.toStringAsFixed(2)}',
                          items: order.items
                              .map((item) => {
                                    'name': item.name,
                                    'quantity': item.quantity.toString(),
                                    'price': 'Rs.${item.price.toStringAsFixed(2)}',
                                  })
                              .toList(),
                          onPayNow: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Payment integration not yet implemented.')),
                            );
                          },
                          onViewBill: () {
                            showBillDetailsModal(
                              context: context,
                              orderId: order.id,
                              orderDate: formattedBillDate,
                              itemsOrdered: order.items
                                  .map((item) => {
                                        'name': item.name,
                                        'quantity': item.quantity.toString(),
                                        'price': 'Rs.${item.price.toStringAsFixed(2)}',
                                      })
                                  .toList(),
                              subtotal: 'Rs.${subtotal.toStringAsFixed(2)}',
                              deliveryFee: 'Rs.${order.deliveryFee.toStringAsFixed(2)}',
                              taxes: 'Rs.${order.totalTax.toStringAsFixed(2)}',
                              grandTotal: 'Rs.${order.total.toStringAsFixed(2)}',
                              paymentMethod: order.paymentMethod,
                            );
                          },
                          onCancelOrder: () async {
                            await firestoreService.cancelOrder(order.id);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Order ${order.id} cancelled.')),
                            );
                          },
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
}
