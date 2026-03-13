import '../../../catalog/domain/entities/product.dart';

class CartItem {
  CartItem({
    required this.product,
    required this.quantity,
  });

  final Product product;
  int quantity;

  double get lineTotal => product.price * quantity;
}

