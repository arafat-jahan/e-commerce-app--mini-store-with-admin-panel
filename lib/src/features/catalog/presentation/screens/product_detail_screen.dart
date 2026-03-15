import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/product.dart';
import '../../../cart/presentation/providers/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});
  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> with TickerProviderStateMixin {
  late final AnimationController _contentCtrl;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _contentFade;

  late final AnimationController _btnCtrl;
  late final Animation<double> _btnScale;

  bool _addedToCart = false;

  @override
  void initState() {
    super.initState();

    _contentCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _contentSlide = Tween(begin: const Offset(0, 0.15), end: Offset.zero).animate(
        CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic));
    _contentFade = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut));

    _btnCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120),
        lowerBound: 0.95, upperBound: 1.0, value: 1.0);
    _btnScale = _btnCtrl;

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _contentCtrl.forward();
    });
  }

  @override
  void dispose() {
    _contentCtrl.dispose();
    _btnCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final cartItem = cart.items.where((i) => i.product.id == widget.product.id).firstOrNull;
    final cartQty = cartItem?.quantity ?? 0;
    final canAdd = widget.product.inStock && cartQty < widget.product.stock;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      body: CustomScrollView(
        slivers: [
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
                        border: Border.all(color: const Color(0xFF2A2A3A))),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18)),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product-${widget.product.id}',
                child: CachedNetworkImage(
                  imageUrl: widget.product.imageUrl, fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: const Color(0xFF1A1A24),
                      child: const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))),
                  errorWidget: (_, __, ___) => Container(color: const Color(0xFF1A1A24),
                      child: const Icon(Icons.broken_image_rounded, size: 64, color: Color(0xFF4B5563))),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _contentFade,
              child: SlideTransition(
                position: _contentSlide,
                child: Container(
                  decoration: const BoxDecoration(color: Color(0xFF0F0F13)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                          builder: (_, v, child) => Transform.scale(scale: v, alignment: Alignment.centerLeft, child: child),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                                color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.3))),
                            child: Text(widget.product.category.toUpperCase(),
                                style: const TextStyle(color: Color(0xFF2563EB), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Name
                        Text(widget.product.name,
                            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, height: 1.2, letterSpacing: -0.5)),
                        const SizedBox(height: 16),

                        // Price & stock
                        Row(children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: widget.product.price),
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeOutCubic,
                            builder: (_, v, __) => Text('\$${v.toStringAsFixed(2)}',
                                style: const TextStyle(color: Color(0xFF2563EB), fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1)),
                          ),
                          const Spacer(),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                                color: widget.product.inStock ? Colors.green.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: widget.product.inStock ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3))),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(widget.product.inStock ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                  size: 14, color: widget.product.inStock ? Colors.green : Colors.red),
                              const SizedBox(width: 6),
                              Text(widget.product.inStock ? '${widget.product.stock} in stock' : 'Out of stock',
                                  style: TextStyle(color: widget.product.inStock ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.w600)),
                            ]),
                          ),
                        ]),
                        const SizedBox(height: 24),
                        const Divider(color: Color(0xFF2A2A3A)),
                        const SizedBox(height: 20),

                        // Description
                        if (widget.product.description.isNotEmpty) ...[
                          const Text('DESCRIPTION',
                              style: TextStyle(color: Color(0xFF6B7280), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                          const SizedBox(height: 10),
                          Text(widget.product.description,
                              style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 15, height: 1.7)),
                          const SizedBox(height: 28),
                        ],

                        // Cart qty controls
                        if (cartQty > 0) ...[
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: const Color(0xFF1A1A24),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.3))),
                            child: Row(children: [
                              const Text('In cart', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)),
                              const Spacer(),
                              _QtyBtn(icon: Icons.remove, onTap: () => context.read<CartProvider>().decreaseQuantity(widget.product)),
                              Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 200),
                                      transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                                      child: Text('$cartQty', key: ValueKey(cartQty),
                                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)))),
                              _QtyBtn(icon: Icons.add, active: canAdd,
                                  onTap: canAdd ? () => context.read<CartProvider>().increaseQuantity(widget.product) : null),
                            ]),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Add to cart button
                        ScaleTransition(
                          scale: _btnScale,
                          child: GestureDetector(
                            onTapDown: (_) { if (canAdd) _btnCtrl.reverse(); },
                            onTapUp: (_) {
                              _btnCtrl.forward();
                              if (canAdd) {
                                context.read<CartProvider>().add(widget.product);
                                setState(() => _addedToCart = true);
                                Future.delayed(const Duration(milliseconds: 1500), () {
                                  if (mounted) setState(() => _addedToCart = false);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${widget.product.name} added to cart'),
                                        duration: const Duration(seconds: 1)));
                              }
                            },
                            onTapCancel: () => _btnCtrl.forward(),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: double.infinity, height: 56,
                              decoration: BoxDecoration(
                                color: canAdd
                                    ? (_addedToCart ? Colors.green : const Color(0xFF2563EB))
                                    : const Color(0xFF1A1A24),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: canAdd ? [BoxShadow(
                                    color: (_addedToCart ? Colors.green : const Color(0xFF2563EB)).withValues(alpha: 0.4),
                                    blurRadius: 20, offset: const Offset(0, 8))] : [],
                              ),
                              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: Icon(
                                        _addedToCart ? Icons.check_rounded : (widget.product.inStock ? Icons.shopping_cart_rounded : Icons.block_rounded),
                                        key: ValueKey(_addedToCart),
                                        size: 20,
                                        color: canAdd ? Colors.white : const Color(0xFF4B5563))),
                                const SizedBox(width: 10),
                                AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: Text(
                                        _addedToCart ? 'Added!' : (widget.product.inStock ? (canAdd ? 'Add to cart' : 'Max qty reached') : 'Out of stock'),
                                        key: ValueKey(_addedToCart),
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                                            color: canAdd ? Colors.white : const Color(0xFF4B5563)))),
                              ]),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
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
  final IconData icon; final VoidCallback? onTap; final bool active;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36, height: 36,
        decoration: BoxDecoration(
            color: active ? const Color(0xFF2563EB).withValues(alpha: 0.2) : const Color(0xFF22222F),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: active ? const Color(0xFF2563EB).withValues(alpha: 0.4) : const Color(0xFF2A2A3A))),
        child: Icon(icon, size: 18, color: active ? const Color(0xFF2563EB) : const Color(0xFF4B5563)),
      ),
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}