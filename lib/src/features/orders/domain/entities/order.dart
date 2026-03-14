import 'shipping_address.dart';

class OrderItem {
  const OrderItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.quantity,
  });

  final String productId;
  final String name;
  final double price;
  final String imageUrl;
  final int quantity;

  double get lineTotal => price * quantity;

  factory OrderItem.fromMap(Map<String, dynamic> data) {
    return OrderItem(
      productId: data['productId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      imageUrl: data['imageUrl'] as String? ?? '',
      quantity: (data['quantity'] as int?) ?? 0,
    );
  }
}

class Order {
  const Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.createdAt,
    required this.status,
    this.shippingAddress = const ShippingAddress(fullName: '', phone: '', address: '', city: ''),
  });

  final String id;
  final String userId;
  final List<OrderItem> items;
  final double total;
  final DateTime createdAt;
  final String status;
  final ShippingAddress shippingAddress;
}

