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
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;
  bool _addedToCart = false;

  @override
  void initState() {
    super.initState();
    _contentCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _contentFade = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut));
    _contentSlide = Tween(begin: const Offset(0, 0.12), end: Offset.zero).animate(CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic));
    Future.delayed(const Duration(milliseconds: 180), () { if (mounted) _contentCtrl.forward(); });
  }

  @override
  void dispose() { _contentCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final cartItem = cart.items.where((i) => i.product.id == widget.product.id).firstOrNull;
    final cartQty = cartItem?.quantity ?? 0;
    final canAdd = widget.product.inStock && cartQty < widget.product.stock;

    return Scaffold(
      backgroundColor: const Color(0xFF080B14),
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 380,
          pinned: true,
          backgroundColor: const Color(0xFF080B14),
          leading: Padding(padding: const EdgeInsets.all(10),
              child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                      decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18)))),
          flexibleSpace: FlexibleSpaceBar(
              background: Stack(fit: StackFit.expand, children: [
                Hero(tag: 'product-${widget.product.id}',
                    child: CachedNetworkImage(imageUrl: widget.product.imageUrl, fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: const Color(0xFF141925),
                            child: const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)))),
                        errorWidget: (_, __, ___) => Container(color: const Color(0xFF141925),
                            child: Icon(Icons.broken_image_rounded, size: 64, color: Colors.white.withValues(alpha: 0.15))))),
                // Bottom gradient
                Positioned(bottom: 0, left: 0, right: 0,
                    child: Container(height: 120,
                        decoration: BoxDecoration(gradient: LinearGradient(
                            begin: Alignment.topCenter, end: Alignment.bottomCenter,
                            colors: [Colors.transparent, const Color(0xFF080B14).withValues(alpha: 0.9)])))),
              ])),
        ),

        SliverToBoxAdapter(
          child: FadeTransition(opacity: _contentFade,
            child: SlideTransition(position: _contentSlide,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // Category
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [const Color(0xFF3B82F6).withValues(alpha: 0.15), const Color(0xFF2563EB).withValues(alpha: 0.08)]),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.25))),
                        child: Text(widget.product.category.toUpperCase(),
                            style: const TextStyle(color: Color(0xFF3B82F6), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5))),
                    const SizedBox(height: 14),

                    Text(widget.product.name,
                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, height: 1.15, letterSpacing: -0.8)),
                    const SizedBox(height: 18),

                    Row(children: [
                      TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: widget.product.price),
                          duration: const Duration(milliseconds: 900), curve: Curves.easeOutCubic,
                          builder: (_, v, __) => Text('\$${v.toStringAsFixed(2)}',
                              style: const TextStyle(color: Color(0xFF3B82F6), fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -1.5))),
                      const Spacer(),
                      Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                              color: widget.product.inStock ? Colors.green.withValues(alpha: 0.12) : Colors.red.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: widget.product.inStock ? Colors.green.withValues(alpha: 0.25) : Colors.red.withValues(alpha: 0.25))),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(widget.product.inStock ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                size: 13, color: widget.product.inStock ? Colors.green : Colors.red),
                            const SizedBox(width: 6),
                            Text(widget.product.inStock ? '${widget.product.stock} in stock' : 'Out of stock',
                                style: TextStyle(color: widget.product.inStock ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.w600)),
                          ])),
                    ]),
                    const SizedBox(height: 24),
                    Divider(color: Colors.white.withValues(alpha: 0.06)),
                    const SizedBox(height: 20),

                    if (widget.product.description.isNotEmpty) ...[
                      Text('DESCRIPTION', style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                      const SizedBox(height: 10),
                      Text(widget.product.description,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 15, height: 1.75)),
                      const SizedBox(height: 28),
                    ],

                    if (cartQty > 0) ...[
                      Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: const Color(0xFF141925),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.2))),
                          child: Row(children: [
                            Text('In cart', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14)),
                            const Spacer(),
                            _QtyBtn(icon: Icons.remove, onTap: () => context.read<CartProvider>().decreaseQuantity(widget.product)),
                            Padding(padding: const EdgeInsets.symmetric(horizontal: 18),
                                child: AnimatedSwitcher(duration: const Duration(milliseconds: 200),
                                    transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                                    child: Text('$cartQty', key: ValueKey(cartQty),
                                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)))),
                            _QtyBtn(icon: Icons.add, active: canAdd,
                                onTap: canAdd ? () => context.read<CartProvider>().increaseQuantity(widget.product) : null),
                          ])),
                      const SizedBox(height: 16),
                    ],

                    // Add to cart
                    GestureDetector(
                      onTap: canAdd ? () {
                        context.read<CartProvider>().add(widget.product);
                        setState(() => _addedToCart = true);
                        Future.delayed(const Duration(milliseconds: 1800), () { if (mounted) setState(() => _addedToCart = false); });
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${widget.product.name} added to cart'), duration: const Duration(seconds: 1)));
                      } : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic,
                        width: double.infinity, height: 58,
                        decoration: BoxDecoration(
                            gradient: canAdd ? LinearGradient(colors: _addedToCart ? [Colors.green, const Color(0xFF16A34A)] : [const Color(0xFF3B82F6), const Color(0xFF2563EB)]) : null,
                            color: canAdd ? null : const Color(0xFF141925),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: canAdd ? [
                              BoxShadow(color: (_addedToCart ? Colors.green : const Color(0xFF3B82F6)).withValues(alpha: 0.45), blurRadius: 24, offset: const Offset(0, 8)),
                              BoxShadow(color: (_addedToCart ? Colors.green : const Color(0xFF3B82F6)).withValues(alpha: 0.15), blurRadius: 48, spreadRadius: 4),
                            ] : []),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          AnimatedSwitcher(duration: const Duration(milliseconds: 300),
                              child: Icon(_addedToCart ? Icons.check_rounded : Icons.shopping_bag_rounded,
                                  key: ValueKey(_addedToCart), size: 22,
                                  color: canAdd ? Colors.white : Colors.white.withValues(alpha: 0.2))),
                          const SizedBox(width: 10),
                          AnimatedSwitcher(duration: const Duration(milliseconds: 300),
                              child: Text(_addedToCart ? 'Added to cart!' : (canAdd ? 'Add to cart' : (widget.product.inStock ? 'Max qty reached' : 'Out of stock')),
                                  key: ValueKey(_addedToCart),
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                                      color: canAdd ? Colors.white : Colors.white.withValues(alpha: 0.2)))),
                        ]),
                      ),
                    ),
                  ]),
                )),
          ),
        ),
      ]),
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
      child: AnimatedContainer(duration: const Duration(milliseconds: 200),
          width: 38, height: 38,
          decoration: BoxDecoration(
              gradient: active ? const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)]) : null,
              color: active ? null : const Color(0xFF1C2235),
              borderRadius: BorderRadius.circular(11),
              boxShadow: active ? [BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.3), blurRadius: 10)] : []),
          child: Icon(icon, size: 18, color: active ? Colors.white : Colors.white.withValues(alpha: 0.25))),
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}