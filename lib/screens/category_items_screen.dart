import 'package:flutter/material.dart';
import 'package:rasoi_app/widgets/food_item_card.dart';
import 'package:rasoi_app/screens/food_item_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:rasoi_app/providers/cart_provider.dart';
import 'package:rasoi_app/services/firestore_service.dart';
import 'package:rasoi_app/screens/cart_screen.dart';

// Re-using the FoodItem model from menu_screen.dart, or you can create a separate one if needed.
class FoodItem {
  final String id;
  final String imageUrl;
  final String title;
  final String description;
  final String price;
  final bool isPopular;
  final bool isVegetarian;
  final String? ingredients;
  final String? category;

  FoodItem({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.price,
    this.isPopular = false,
    this.isVegetarian = false,
    this.ingredients,
    this.category,
  });

  factory FoodItem.fromFirestore(Map<String, dynamic> data, String id) {
    return FoodItem(
      id: id,
      imageUrl: data['imageUrl'] ?? '',
      title: data['name'] ?? 'N/A',
      description: data['description'] ?? 'No description',
      price: 'Rs.${(data['price'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
      isPopular: data['isPopular'] ?? false,
      isVegetarian: data['isVegetarian'] ?? false,
      ingredients: data['ingredients'] as String?,
      category: data['category'] as String?,
    );
  }
}

class CategoryItemsScreen extends StatefulWidget {
  final String categoryName;

  const CategoryItemsScreen({super.key, required this.categoryName});

  @override
  State<CategoryItemsScreen> createState() => _CategoryItemsScreenState();
}

class _CategoryItemsScreenState extends State<CategoryItemsScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
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
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _firestoreService.getFoodItems(
          categoryName: widget.categoryName,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No food items found for this category.'));
          }

          final List<FoodItem> foodItems = snapshot.data!
              .map((itemData) => FoodItem.fromFirestore(itemData, itemData['id']))
              .toList();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 0.55,
                    ),
                    itemCount: foodItems.length,
                    itemBuilder: (context, index) {
                      final item = foodItems[index];
                      return FoodItemCard(
                        id: item.id,
                        imagePath: item.imageUrl,
                        title: item.title,
                        price: item.price,
                        isPopular: item.isPopular,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FoodItemDetailScreen(
                                imagePath: item.imageUrl,
                                title: item.title,
                                description: item.description,
                                price: item.price,
                                isVegetarian: item.isVegetarian,
                                ingredients: item.ingredients,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: Consumer<CartProvider>(
        builder: (context, cart, child) => FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CartScreen()));
          },
          backgroundColor: Colors.deepOrange,
          child: Stack(
            children: [
              const Icon(Icons.shopping_cart, color: Colors.white),
              Positioned(
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                  child: Text(
                    cart.itemCount.toString(),
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
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
    );
  }
}
