import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/product.dart';
import '../../../cart/presentation/providers/cart_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final theme = Theme.of(context);

    // Check how many of this product are already in the cart
    final cartItem = cart.items
        .where((i) => i.product.id == product.id)
        .firstOrNull;
    final cartQty = cartItem?.quantity ?? 0;
    final canAdd = product.inStock && cartQty < product.stock;

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero image
            Hero(
              tag: 'product-${product.id}',
              child: CachedNetworkImage(
                imageUrl: product.imageUrl,
                height: 300,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  height: 300,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 300,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, size: 64),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category chip
                  Chip(
                    label: Text(product.category),
                    labelStyle: theme.textTheme.labelSmall,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(height: 8),

                  // Name
                  Text(
                    product.name,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Price row
                  Row(
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // Stock indicator
                      _StockBadge(product: product),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  if (product.description.isNotEmpty) ...[
                    Text(
                      'Description',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Cart quantity controls (if already in cart)
                  if (cartQty > 0) ...[
                    Row(
                      children: [
                        Text(
                          'In cart: $cartQty',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const Spacer(),
                        _QtyButton(
                          icon: Icons.remove,
                          onPressed: () =>
                              context.read<CartProvider>().decreaseQuantity(product),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '$cartQty',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        _QtyButton(
                          icon: Icons.add,
                          onPressed: canAdd
                              ? () => context
                              .read<CartProvider>()
                              .increaseQuantity(product)
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Add to cart button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: canAdd
                          ? () {
                        context.read<CartProvider>().add(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                            Text('${product.name} added to cart'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                          : null,
                      icon: const Icon(Icons.shopping_cart_outlined),
                      label: Text(
                        product.inStock
                            ? (canAdd ? 'Add to cart' : 'Max quantity reached')
                            : 'Out of stock',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  const _StockBadge({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    if (!product.inStock) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          'Out of stock',
          style: TextStyle(
              color: Colors.red[700],
              fontWeight: FontWeight.w600,
              fontSize: 12),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '${product.stock} in stock',
        style: TextStyle(
            color: Colors.green[700],
            fontWeight: FontWeight.w600,
            fontSize: 12),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 20,
            color: onPressed == null ? Colors.grey : null,
          ),
        ),
      ),
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}