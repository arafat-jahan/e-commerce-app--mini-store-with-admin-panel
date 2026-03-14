import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../cart/domain/entities/cart_item.dart';
import '../../data/order_repository.dart';
import '../../domain/entities/order.dart' as order_entity;
import '../../domain/entities/shipping_address.dart';

class OrdersProvider extends ChangeNotifier {
  OrdersProvider({OrderRepository? repo})
      : _repo = repo ?? OrderRepository();

  final OrderRepository _repo;

  Stream<QuerySnapshot<Map<String, dynamic>>>? _ordersStream;
  Stream<QuerySnapshot<Map<String, dynamic>>>? get ordersStream =>
      _ordersStream;

  void listenForUser(String userId) {
    _ordersStream = _repo.watchUserOrders(userId);
    notifyListeners();
  }

  void listenForAll() {
    _ordersStream = _repo.watchAllOrders();
    notifyListeners();
  }

  Future<String> placeOrder({
    required String userId,
    required List<CartItem> items,
    required double total,
    required ShippingAddress shippingAddress,
  }) {
    return _repo.placeOrder(
      userId: userId,
      items: items,
      total: total,
      shippingAddress: shippingAddress,
    );
  }

  Future<order_entity.Order?> getOrder(String orderId) => _repo.getOrder(orderId);

  Future<void> updateOrderStatus(String orderId, String status) =>
      _repo.updateOrderStatus(orderId, status);
}

