import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../cart/domain/entities/cart_item.dart';
import '../../data/order_repository.dart';

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

  Future<void> placeOrder({
    required String userId,
    required List<CartItem> items,
    required double total,
  }) {
    return _repo.placeOrder(userId: userId, items: items, total: total);
  }
}

