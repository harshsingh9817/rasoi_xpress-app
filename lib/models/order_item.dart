class OrderItem {
  final String id;
  final String category;
  final String description;
  final String imageUrl;
  final String ingredients;
  final bool isPopular;
  final bool isVegetarian;
  final bool isVisible;
  final String name;
  final double price;
  final int quantity;
  final double taxRate;

  OrderItem({
    required this.id,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.ingredients,
    required this.isPopular,
    required this.isVegetarian,
    required this.isVisible,
    required this.name,
    required this.price,
    required this.quantity,
    required this.taxRate,
  });

  factory OrderItem.fromFirestore(Map<String, dynamic> data, String id) {
    return OrderItem(
      id: id,
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      ingredients: data['ingredients'] ?? '',
      isPopular: data['isPopular'] ?? false,
      isVegetarian: data['isVegetarian'] ?? false,
      isVisible: data['isVisible'] ?? false,
      name: data['name'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      taxRate: (data['taxRate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'category': category,
      'description': description,
      'imageUrl': imageUrl,
      'ingredients': ingredients,
      'isPopular': isPopular,
      'isVegetarian': isVegetarian,
      'isVisible': isVisible,
      'name': name,
      'price': price,
      'quantity': quantity,
      'taxRate': taxRate,
    };
  }
}
