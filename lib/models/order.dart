import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rasoi_app/models/order_item.dart';

class Order {
  final String id;
  final String userId;
  final String userEmail;
  final String customerName;
  final String customerPhone;
  final String shippingAddress;
  final double shippingLat;
  final double shippingLng;
  final String paymentMethod;
  final String status;
  final double total;
  final double totalTax;
  final double deliveryFee;
  final List<OrderItem> items;
  final DateTime createdAt;
  final String? razorpayOrderId;
  final String? supabaseOrderUuid;

  Order({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.customerName,
    required this.customerPhone,
    required this.shippingAddress,
    required this.shippingLat,
    required this.shippingLng,
    required this.paymentMethod,
    required this.status,
    required this.total,
    required this.totalTax,
    required this.deliveryFee,
    required this.items,
    required this.createdAt,
    this.razorpayOrderId,
    this.supabaseOrderUuid,
  });

  factory Order.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Order(
      id: doc.id,
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      customerName: data['customerName'] ?? '',
      customerPhone: data['customerPhone'] ?? '',
      shippingAddress: data['shippingAddress'] ?? '',
      shippingLat: (data['shippingLat'] as num?)?.toDouble() ?? 0.0,
      shippingLng: (data['shippingLng'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: data['paymentMethod'] ?? '',
      status: data['status'] ?? '',
      total: (data['total'] as num?)?.toDouble() ?? 0.0,
      totalTax: (data['totalTax'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (data['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      items: (data['items'] as List?)
            ?.map((item) {
              final itemMap = item as Map<String, dynamic>;
              return OrderItem.fromFirestore(itemMap, itemMap['id'] as String? ?? '');
            })
            .toList() ??
        [],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(), // Handle potential null for createdAt
      razorpayOrderId: data['razorpayOrderId'] as String?,
      supabaseOrderUuid: data['supabase_order_uuid'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'shippingAddress': shippingAddress,
      'shippingLat': shippingLat,
      'shippingLng': shippingLng,
      'paymentMethod': paymentMethod,
      'status': status,
      'total': total,
      'totalTax': totalTax,
      'deliveryFee': deliveryFee,
      'items': items.map((item) => item.toFirestore()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'razorpayOrderId': razorpayOrderId,
      'supabase_order_uuid': supabaseOrderUuid,
    };
  }
}
