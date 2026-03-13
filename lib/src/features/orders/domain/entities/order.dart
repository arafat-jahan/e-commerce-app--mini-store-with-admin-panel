import '../../../cart/domain/entities/cart_item.dart';

class Order {
  const Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.createdAt,
    required this.status,
  });

  final String id;
  final String userId;
  final List<CartItem> items;
  final double total;
  final DateTime createdAt;
  final String status; // e.g. 'pending', 'delivered'
}

