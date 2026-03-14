import 'package:cloud_firestore/cloud_firestore.dart';

import '../../cart/domain/entities/cart_item.dart';
import '../domain/entities/order.dart' as order_entity;
import '../domain/entities/shipping_address.dart';

class OrderRepository {
  OrderRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<String> placeOrder({
    required String userId,
    required List<CartItem> items,
    required double total,
    required ShippingAddress shippingAddress,
  }) async {
    final ref = await _firestore.collection('orders').add({
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
      'shippingAddress': shippingAddress.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchUserOrders(String userId) {
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

  Future<order_entity.Order?> getOrder(String orderId) async {
    final doc = await _firestore.collection('orders').doc(orderId).get();
    if (!doc.exists || doc.data() == null) return null;
    return _orderFromDoc(doc.id, doc.data()!);
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static order_entity.Order orderFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final id = doc.id;
    final items = (data['items'] as List<dynamic>?)
            ?.map((e) => order_entity.OrderItem.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        <order_entity.OrderItem>[];
    final ts = data['createdAt'] as Timestamp?;
    return order_entity.Order(
      id: id,
      userId: data['userId'] as String? ?? '',
      items: items,
      total: (data['total'] as num?)?.toDouble() ?? 0,
      createdAt: ts?.toDate() ?? DateTime.now(),
      status: data['status'] as String? ?? 'pending',
      shippingAddress: ShippingAddress.fromMap(
        data['shippingAddress'] as Map<String, dynamic>?,
      ),
    );
  }

  order_entity.Order _orderFromDoc(String id, Map<String, dynamic> data) {
    final items = (data['items'] as List<dynamic>?)
            ?.map((e) => order_entity.OrderItem.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        <order_entity.OrderItem>[];
    final ts = data['createdAt'] as Timestamp?;
    return order_entity.Order(
      id: id,
      userId: data['userId'] as String? ?? '',
      items: items,
      total: (data['total'] as num?)?.toDouble() ?? 0,
      createdAt: ts?.toDate() ?? DateTime.now(),
      status: data['status'] as String? ?? 'pending',
      shippingAddress: ShippingAddress.fromMap(
        data['shippingAddress'] as Map<String, dynamic>?,
      ),
    );
  }
}
