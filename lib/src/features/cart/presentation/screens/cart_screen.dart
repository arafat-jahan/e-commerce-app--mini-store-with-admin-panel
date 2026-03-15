import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../../../checkout/presentation/screens/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    if (cart.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A24),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF2A2A3A)),
              ),
              child: const Icon(Icons.shopping_cart_outlined, size: 44, color: Color(0xFF4B5563)),
            ),
            const SizedBox(height: 20),
            const Text('Your cart is empty', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Add items from the shop to get started', style: TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: cart.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A24),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2A2A3A)),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(item.product.imageUrl,
                          width: 64, height: 64, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                              width: 64, height: 64, color: const Color(0xFF22222F),
                              child: const Icon(Icons.image_not_supported_rounded, color: Color(0xFF4B5563), size: 24))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.product.name,
                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text('\$${item.product.price.toStringAsFixed(2)} each',
                              style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('\$${item.lineTotal.toStringAsFixed(2)}',
                            style: const TextStyle(color: Color(0xFF2563EB), fontSize: 16, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _CartBtn(
                                icon: item.quantity == 1 ? Icons.delete_outline_rounded : Icons.remove,
                                onTap: () => cart.decreaseQuantity(item.product),
                                danger: item.quantity == 1),
                            Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text('${item.quantity}',
                                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700))),
                            _CartBtn(
                                icon: Icons.add, active: true,
                                onTap: item.quantity < item.product.stock ? () => cart.increaseQuantity(item.product) : null),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A24),
            border: Border(top: BorderSide(color: Color(0xFF2A2A3A))),
          ),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Subtotal', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)),
                Text('\$${cart.total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 4),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Delivery', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)),
                const Text('Free', style: TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 12),
              const Divider(color: Color(0xFF2A2A3A)),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Total', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                Text('\$${cart.total.toStringAsFixed(2)}',
                    style: const TextStyle(color: Color(0xFF2563EB), fontSize: 22, fontWeight: FontWeight.w800)),
              ]),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity, height: 56,
                child: FilledButton(
                  onPressed: () {
                    final auth = context.read<AuthProvider>();
                    if (auth.user == null) return;
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CheckoutScreen()));
                  },
                  style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.lock_outline_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Proceed to checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CartBtn extends StatelessWidget {
  const _CartBtn({required this.icon, this.onTap, this.active = false, this.danger = false});
  final IconData icon;
  final VoidCallback? onTap;
  final bool active;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: danger ? Colors.red.withValues(alpha: 0.15)
              : active && onTap != null ? const Color(0xFF2563EB).withValues(alpha: 0.15)
              : const Color(0xFF22222F),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: danger ? Colors.red.withValues(alpha: 0.3)
                  : active && onTap != null ? const Color(0xFF2563EB).withValues(alpha: 0.3)
                  : const Color(0xFF2A2A3A)),
        ),
        child: Icon(icon, size: 16,
            color: danger ? Colors.red
                : active && onTap != null ? const Color(0xFF2563EB)
                : const Color(0xFF4B5563)),
      ),
    );
  }
}