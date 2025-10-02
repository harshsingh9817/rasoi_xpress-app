import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rasoi_app/providers/cart_provider.dart';
import 'package:rasoi_app/screens/menu_screen.dart'; // Import FoodItem

class FoodItemCard extends StatefulWidget {
  final String id;
  final String imagePath;
  final String title;
  final String price;
  final bool isPopular;
  final VoidCallback? onTap;

  const FoodItemCard({
    super.key,
    required this.id,
    required this.imagePath,
    required this.title,
    required this.price,
    this.isPopular = false,
    this.onTap,
  });

  @override
  State<FoodItemCard> createState() => _FoodItemCardState();
}

class _FoodItemCardState extends State<FoodItemCard> {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      widget.imagePath,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (widget.isPopular)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          'Popular',
                          style: TextStyle(color: Colors.deepOrange.shade700, fontSize: 12),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2, // Allow text to wrap to 2 lines
                      overflow: TextOverflow.ellipsis, // Add ellipsis if text overflows
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                widget.price,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
              const SizedBox(height: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 120.0, // Fixed width for the button
                    child: OutlinedButton(
                      onPressed: () {
                        // Handle Buy Now (can navigate directly to checkout or cart)
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.deepOrange,
                        side: const BorderSide(color: Colors.deepOrange),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Buy Now'),
                    ),
                  ),
                  const SizedBox(height: 10), // Vertical spacing between buttons
                  SizedBox(
                    width: 120.0, // Fixed width for the button
                    child: ElevatedButton(
                      onPressed: () {
                        final foodItem = FoodItem(
                          id: widget.id,
                          imageUrl: widget.imagePath,
                          title: widget.title,
                          description: "", // Placeholder: FoodItemCard doesn't have description
                          price: widget.price,
                          isPopular: widget.isPopular,
                          isVegetarian: false, // Placeholder: FoodItemCard doesn't have isVegetarian
                          ingredients: null, // Placeholder: FoodItemCard doesn't have ingredients
                          category: null, // Placeholder: FoodItemCard doesn't have category
                        );
                        cart.addItem(foodItem);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Add to Cart'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
