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
    final cartItem = cart.items.where((i) => i.product.id == product.id).firstOrNull;
    final cartQty = cartItem?.quantity ?? 0;
    final canAdd = product.inStock && cartQty < product.stock;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      body: CustomScrollView(
        slivers: [
          // Image with back button
          SliverAppBar(
            expandedHeight: 360,
            pinned: true,
            backgroundColor: const Color(0xFF0F0F13),
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2A2A3A)),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product-${product.id}',
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: const Color(0xFF1A1A24),
                    child: const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB))),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: const Color(0xFF1A1A24),
                    child: const Icon(Icons.broken_image_rounded, size: 64, color: Color(0xFF4B5563)),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0F0F13),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        product.category.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF2563EB),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Name
                    Text(
                      product.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Price & stock row
                    Row(
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFF2563EB),
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: product.inStock
                                ? Colors.green.withValues(alpha: 0.15)
                                : Colors.red.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: product.inStock
                                  ? Colors.green.withValues(alpha: 0.3)
                                  : Colors.red.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                product.inStock ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                size: 14,
                                color: product.inStock ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                product.inStock ? '${product.stock} in stock' : 'Out of stock',
                                style: TextStyle(
                                  color: product.inStock ? Colors.green : Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Divider
                    const Divider(color: Color(0xFF2A2A3A)),
                    const SizedBox(height: 20),

                    // Description
                    if (product.description.isNotEmpty) ...[
                      const Text(
                        'DESCRIPTION',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        product.description,
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 15,
                          height: 1.7,
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],

                    // Cart quantity controls
                    if (cartQty > 0) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A24),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF2A2A3A)),
                        ),
                        child: Row(
                          children: [
                            const Text('In cart', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)),
                            const Spacer(),
                            _QtyBtn(
                              icon: Icons.remove,
                              onTap: () => context.read<CartProvider>().decreaseQuantity(product),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                '$cartQty',
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                              ),
                            ),
                            _QtyBtn(
                              icon: Icons.add,
                              onTap: canAdd ? () => context.read<CartProvider>().increaseQuantity(product) : null,
                              active: canAdd,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Add to cart button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: canAdd
                            ? () {
                          context.read<CartProvider>().add(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.name} added to cart'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                            : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          disabledBackgroundColor: const Color(0xFF1A1A24),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              product.inStock ? Icons.shopping_cart_rounded : Icons.block_rounded,
                              size: 20,
                              color: canAdd ? Colors.white : const Color(0xFF4B5563),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              product.inStock
                                  ? (canAdd ? 'Add to cart' : 'Max quantity reached')
                                  : 'Out of stock',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: canAdd ? Colors.white : const Color(0xFF4B5563),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  const _QtyBtn({required this.icon, this.onTap, this.active = false});
  final IconData icon;
  final VoidCallback? onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: active ? const Color(0xFF2563EB).withValues(alpha: 0.2) : const Color(0xFF22222F),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? const Color(0xFF2563EB).withValues(alpha: 0.4) : const Color(0xFF2A2A3A),
          ),
        ),
        child: Icon(icon, size: 18, color: active ? const Color(0xFF2563EB) : const Color(0xFF4B5563)),
      ),
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}