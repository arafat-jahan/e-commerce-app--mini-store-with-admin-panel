import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/entities/product.dart';

class ProductRepository {
  ProductRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<Product>> watchProducts() {
    return _firestore.collection('products').snapshots().map(
          (snap) => snap.docs
              .map((d) => Product.fromMap(d.id, d.data()))
              .toList(growable: false),
        );
  }

  Future<List<Product>> fetchOnce() async {
    final snap = await _firestore.collection('products').get();
    return snap.docs
        .map((d) => Product.fromMap(d.id, d.data()))
        .toList(growable: false);
  }

  Future<void> addOrUpdate(Product product) async {
    final ref = _firestore.collection('products').doc(product.id);
    await ref.set(product.toMap(), SetOptions(merge: true));
  }

  Future<void> delete(String id) {
    return _firestore.collection('products').doc(id).delete();
  }
}

