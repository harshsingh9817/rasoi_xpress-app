import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rasoi_app/providers/cart_provider.dart';
import 'package:rasoi_app/screens/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(
                      'Rs.${cart.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context, i) {
                final cartItem = cart.items.values.toList()[i];
                return CartItemWidget(
                  cartItem.id,
                  cartItem.id,
                  cartItem.price,
                  cartItem.quantity,
                  cartItem.name, // Use name instead of title
                  cartItem.imageUrl, // Use imageUrl instead of imagePath
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Enter coupon code',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        // Handle apply coupon
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade100,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Apply',
                        style: TextStyle(color: Colors.deepOrange.shade700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        cart.clearCart();
                      },
                      icon: const Icon(Icons.delete, color: Colors.deepOrange),
                      label: const Text(
                        'Clear Cart',
                        style: TextStyle(color: Colors.deepOrange),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: cart.totalAmount <= 0
                          ? null
                          : () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CheckoutScreen()));
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Proceed to Checkout →',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CartItemWidget extends StatelessWidget {
  final String id;
  final String productId;
  final double price;
  final int quantity;
  final String name; // Change from title to name
  final String imageUrl; // Change from imagePath to imageUrl

  const CartItemWidget(
    this.id,
    this.productId,
    this.price,
    this.quantity,
    this.name, // Change from title to name
    this.imageUrl, {super.key,}
  );

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      background: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        Provider.of<CartProvider>(context, listen: false).removeItem(productId);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(imageUrl), // Use NetworkImage
            ),
            title: Text(name),
            subtitle: Text('Total: Rs.${(price * quantity).toStringAsFixed(2)}'),
            trailing: FittedBox(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      Provider.of<CartProvider>(context, listen: false).removeSingleItem(productId);
                    },
                  ),
                  Text('$quantity x'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      Provider.of<CartProvider>(context, listen: false).incrementItemQuantity(productId);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
