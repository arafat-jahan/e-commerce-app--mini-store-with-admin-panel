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
      return Center(child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 700), curve: Curves.elasticOut,
        builder: (_, v, child) => Transform.scale(scale: v, child: child),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 110, height: 110,
              decoration: BoxDecoration(color: const Color(0xFF141925), borderRadius: BorderRadius.circular(28), border: Border.all(color: const Color(0xFF1E293B))),
              child: Icon(Icons.shopping_bag_outlined, size: 48, color: Colors.white.withValues(alpha: 0.15))),
          const SizedBox(height: 20),
          const Text('Your cart is empty', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Add items from the shop', style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 14)),
        ]),
      ));
    }

    return Column(children: [
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          itemCount: cart.items.length,
          itemBuilder: (context, index) {
            final item = cart.items[index];
            return TweenAnimationBuilder<double>(
              key: ValueKey(item.product.id),
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic,
              builder: (_, v, child) => Opacity(opacity: v.clamp(0.0, 1.0),
                  child: Transform.translate(offset: Offset((1 - v) * 50, 0), child: child)),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: const Color(0xFF141925),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF1E293B))),
                child: Row(children: [
                  ClipRRect(borderRadius: BorderRadius.circular(12),
                      child: Image.network(item.product.imageUrl, width: 68, height: 68, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(width: 68, height: 68, color: const Color(0xFF1C2235),
                              child: Icon(Icons.image_not_supported_rounded, color: Colors.white.withValues(alpha: 0.15), size: 24)))),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item.product.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 5),
                    Text('\$${item.product.price.toStringAsFixed(2)} each', style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 12)),
                  ])),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('\$${item.lineTotal.toStringAsFixed(2)}',
                        style: const TextStyle(color: Color(0xFF3B82F6), fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 10),
                    Row(children: [
                      _CartBtn(icon: item.quantity == 1 ? Icons.delete_outline_rounded : Icons.remove,
                          onTap: () => cart.decreaseQuantity(item.product), danger: item.quantity == 1),
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: AnimatedSwitcher(duration: const Duration(milliseconds: 200),
                              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                              child: Text('${item.quantity}', key: ValueKey(item.quantity),
                                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)))),
                      _CartBtn(icon: Icons.add, active: true,
                          onTap: item.quantity < item.product.stock ? () => cart.increaseQuantity(item.product) : null),
                    ]),
                  ]),
                ]),
              ),
            );
          },
        ),
      ),

      Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        decoration: BoxDecoration(
            color: const Color(0xFF0F1420),
            border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, -4))]),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Subtotal', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 14)),
            Text('\$${cart.total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Delivery', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 14)),
            const Text('Free 🎉', style: TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 14),
          Divider(color: Colors.white.withValues(alpha: 0.06)),
          const SizedBox(height: 14),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Total', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
            Text('\$${cart.total.toStringAsFixed(2)}',
                style: const TextStyle(color: Color(0xFF3B82F6), fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
          ]),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () {
              final auth = context.read<AuthProvider>();
              if (auth.user == null) return;
              Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (_, anim, __) => SlideTransition(
                      position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
                      child: const CheckoutScreen()),
                  transitionDuration: const Duration(milliseconds: 400)));
            },
            child: Container(
              width: double.infinity, height: 58,
              decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)]),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.4), blurRadius: 24, offset: const Offset(0, 8))]),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.lock_outline_rounded, color: Colors.white, size: 18),
                SizedBox(width: 10),
                Text('Proceed to checkout', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
        ]),
      ),
    ]);
  }
}

class _CartBtn extends StatefulWidget {
  const _CartBtn({required this.icon, this.onTap, this.active = false, this.danger = false});
  final IconData icon; final VoidCallback? onTap; final bool active; final bool danger;
  @override
  State<_CartBtn> createState() => _CartBtnState();
}

class _CartBtnState extends State<_CartBtn> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override
  void initState() { super.initState(); _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100), lowerBound: 0.82, upperBound: 1.0, value: 1.0); }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) { if (widget.onTap != null) _ctrl.reverse(); },
      onTapUp: (_) { _ctrl.forward(); widget.onTap?.call(); },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(scale: _ctrl,
          child: Container(width: 34, height: 34,
              decoration: BoxDecoration(
                  color: widget.danger ? Colors.red.withValues(alpha: 0.12) : widget.active && widget.onTap != null ? const Color(0xFF3B82F6).withValues(alpha: 0.12) : const Color(0xFF1C2235),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: widget.danger ? Colors.red.withValues(alpha: 0.25) : widget.active && widget.onTap != null ? const Color(0xFF3B82F6).withValues(alpha: 0.25) : const Color(0xFF1E293B))),
              child: Icon(widget.icon, size: 17,
                  color: widget.danger ? Colors.red : widget.active && widget.onTap != null ? const Color(0xFF3B82F6) : Colors.white.withValues(alpha: 0.25)))),
    );
  }
}