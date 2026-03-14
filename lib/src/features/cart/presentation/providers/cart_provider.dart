import 'package:flutter/foundation.dart';

import '../../domain/entities/cart_item.dart';
import '../../../catalog/domain/entities/product.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  double get total =>
      _items.fold(0, (sum, item) => sum + item.lineTotal);

  void add(Product product) {
    final existing =
        _items.where((e) => e.product.id == product.id).firstOrNull;
    if (existing != null) {
      if (product.inStock && existing.quantity >= product.stock) return;
      existing.quantity += 1;
    } else {
      _items.add(CartItem(product: product, quantity: 1));
    }
    notifyListeners();
  }

  void increaseQuantity(Product product) {
    final existing =
        _items.where((e) => e.product.id == product.id).firstOrNull;
    if (existing == null) return;
    if (product.inStock && existing.quantity >= product.stock) return;
    existing.quantity += 1;
    notifyListeners();
  }

  void decreaseQuantity(Product product) {
    final existing =
        _items.where((e) => e.product.id == product.id).firstOrNull;
    if (existing == null) return;
    if (existing.quantity <= 1) {
      _items.removeWhere((e) => e.product.id == product.id);
    } else {
      existing.quantity -= 1;
    }
    notifyListeners();
  }

  void remove(Product product) {
    _items.removeWhere((e) => e.product.id == product.id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}

