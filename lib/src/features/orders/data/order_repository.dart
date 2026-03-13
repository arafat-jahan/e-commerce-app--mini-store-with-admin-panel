import 'package:cloud_firestore/cloud_firestore.dart';

import '../../cart/domain/entities/cart_item.dart';

class OrderRepository {
  OrderRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> placeOrder({
    required String userId,
    required List<CartItem> items,
    required double total,
  }) async {
    await _firestore.collection('orders').add({
      'userId': userId,
      'items': items
          .map((e) => {
                'productId': e.product.id,
                'name': e.product.name,
                'price': e.product.price,
                'imageUrl': e.product.imageUrl,
                'quantity': e.quantity,
              })
          .toList(),
      'total': total,
      'status': 'pending',
      'cod': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchUserOrders(
      String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchAllOrders() {
    return _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}

