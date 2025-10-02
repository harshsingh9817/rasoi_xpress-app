import 'package:flutter/material.dart';
import 'package:rasoi_app/widgets/food_item_card.dart';
import 'package:rasoi_app/screens/food_item_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:rasoi_app/providers/cart_provider.dart';
import 'package:rasoi_app/screens/cart_screen.dart';
import 'package:rasoi_app/services/firestore_service.dart'; // Import FirestoreService
import 'package:rasoi_app/models/slider_item.dart'; // Import SliderItem
import 'package:carousel_slider/carousel_slider.dart'; // Import CarouselSlider

class FoodItem {
  final String id;
  final String imageUrl;
  final String title;
  final String description;
  final String price;
  final bool isPopular;
  final bool isVegetarian;
  final String? ingredients;
  final String? category; // Add category field

  FoodItem({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.price,
    this.isPopular = false,
    this.isVegetarian = false,
    this.ingredients,
    this.category, // Initialize category
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
      category: data['category'] as String?, // Parse category field
    );
  }
}

class MenuScreen extends StatefulWidget {
  final String? initialCategoryName; // Change parameter name to reflect it's a name
  final String? searchQuery; // Add searchQuery parameter

  const MenuScreen({super.key, this.initialCategoryName, this.searchQuery}); // Update constructor

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final FirestoreService _firestoreService = FirestoreService(); // Instance of FirestoreService
  String? _selectedCategory; // Add state variable for selected category
  // final TextEditingController _searchController = TextEditingController(); // Removed: Search handled by CustomAppBar
  // String? _searchQuery; // State variable for search query - will be set by CustomAppBar

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategoryName; // Initialize selected category with name
  }

  @override
  void dispose() {
    // _searchController.dispose(); // Removed: Search handled by CustomAppBar
    super.dispose();
  }

  // Helper method to parse hex color strings to Color objects
  Color? _parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) {
      return null;
    }
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "${hexColor}FF";
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
    return null;
  }

  // Search and Filter Section
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar removed, search functionality moved to CustomAppBar
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _firestoreService.getFoodItems(
          searchQuery: widget.searchQuery, // Use widget.searchQuery here
          categoryName: _selectedCategory, // Pass selected category name
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No food items found.'));
          }

          final List<FoodItem> foodItems = snapshot.data!
              .map((itemData) => FoodItem.fromFirestore(itemData, itemData['id']))
              .toList();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Slider Prototype (Keep if needed, otherwise remove)
                  StreamBuilder<List<SliderItem>>(
                    stream: _firestoreService.getHeroSliderItems(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const SizedBox.shrink(); // No slider items, so hide the slider
                      }

                      final List<SliderItem> sliderItems = snapshot.data!;

                      return CarouselSlider.builder(
                        itemCount: sliderItems.length,
                        itemBuilder: (context, index, realIndex) {
                          final item = sliderItems[index];
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              image: DecorationImage(
                                image: NetworkImage(item.imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (item.headline != null)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      item.headline!,
                                      style: TextStyle(
                                        color: _parseColor(item.subheadlineColor) ?? Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                if (item.subheadline != null)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      item.subheadline!,
                                      style: TextStyle(
                                        color: _parseColor(item.subheadlineColor) ?? Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                        options: CarouselOptions(
                          height: MediaQuery.of(context).size.width * 0.5,
                          enlargeCenterPage: false, // Set to false to remove center page enlargement
                          autoPlay: true,
                          aspectRatio: 16 / 9,
                          autoPlayCurve: Curves.fastOutSlowIn,
                          enableInfiniteScroll: true,
                          autoPlayAnimationDuration: const Duration(milliseconds: 800),
                          viewportFraction: 1.0, // Set to 1.0 for full width
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  if (foodItems.isEmpty) // Display message if no food items
                    const Center(child: Text('No food available in this category.'))
                  else
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
