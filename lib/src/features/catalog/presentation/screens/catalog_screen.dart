import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../cart/presentation/providers/cart_provider.dart';
import '../../domain/entities/product.dart';
import '../providers/products_provider.dart';
import 'product_detail_screen.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductsProvider>();
    final list = products.filtered;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 800 ? 4 : 2;
        return Column(
          children: [
            Container(
              color: const Color(0xFF0F0F13),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                children: [
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: products.search.isNotEmpty
                          ? IconButton(icon: const Icon(Icons.close_rounded, size: 18), onPressed: () => products.setSearch(''))
                          : null,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: products.setSearch,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: ['All', 'Electronics', 'Clothing', 'Home', 'Accessories'].map((cat) {
                        final selected = products.category == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => products.setCategory(cat),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: selected ? const Color(0xFF2563EB) : const Color(0xFF1A1A24),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: selected ? const Color(0xFF2563EB) : const Color(0xFF2A2A3A)),
                                boxShadow: selected ? [BoxShadow(color: const Color(0xFF2563EB).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))] : [],
                              ),
                              child: Text(cat,
                                  style: TextStyle(
                                      color: selected ? Colors.white : const Color(0xFF9CA3AF),
                                      fontSize: 13, fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: list.isEmpty
                  ? Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(width: 80, height: 80,
                      decoration: BoxDecoration(color: const Color(0xFF1A1A24), borderRadius: BorderRadius.circular(20)),
                      child: const Icon(Icons.search_off_rounded, size: 36, color: Color(0xFF4B5563))),
                  const SizedBox(height: 16),
                  const Text('No products found', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 16, fontWeight: FontWeight.w600)),
                ]),
              )
                  : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.65),
                itemCount: list.length,
                itemBuilder: (context, index) => _AnimatedProductCard(product: list[index], index: index),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AnimatedProductCard extends StatefulWidget {
  const _AnimatedProductCard({required this.product, required this.index});
  final Product product;
  final int index;

  @override
  State<_AnimatedProductCard> createState() => _AnimatedProductCardState();
}

class _AnimatedProductCardState extends State<_AnimatedProductCard> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    final delay = (widget.index * 0.06).clamp(0.0, 0.6);
    _fade = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Interval(delay, (delay + 0.4).clamp(0.0, 1.0), curve: Curves.easeOut)));
    _slide = Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(
        CurvedAnimation(parent: _ctrl, curve: Interval(delay, (delay + 0.4).clamp(0.0, 1.0), curve: Curves.easeOutCubic)));
    _scale = Tween(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Interval(delay, (delay + 0.4).clamp(0.0, 1.0), curve: Curves.easeOutCubic)));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: ScaleTransition(
          scale: _scale,
          child: _ProductCard(product: widget.product),
        ),
      ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  const _ProductCard({required this.product});
  final Product product;
  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> with SingleTickerProviderStateMixin {
  late final AnimationController _tapCtrl;
  late final Animation<double> _tapScale;

  @override
  void initState() {
    super.initState();
    _tapCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120), lowerBound: 0.95, upperBound: 1.0, value: 1.0);
    _tapScale = _tapCtrl;
  }

  @override
  void dispose() { _tapCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final cartItem = cart.items.where((i) => i.product.id == widget.product.id).firstOrNull;
    final inCart = cartItem != null;

    return GestureDetector(
      onTapDown: (_) => _tapCtrl.reverse(),
      onTapUp: (_) {
        _tapCtrl.forward();
        Navigator.of(context).push(PageRouteBuilder(
          pageBuilder: (_, anim, __) => FadeTransition(opacity: anim, child: ProductDetailScreen(product: widget.product)),
          transitionDuration: const Duration(milliseconds: 300),
        ));
      },
      onTapCancel: () => _tapCtrl.forward(),
      child: ScaleTransition(
        scale: _tapScale,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A24),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2A2A3A)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'product-${widget.product.id}',
                      child: CachedNetworkImage(
                        imageUrl: widget.product.imageUrl, fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: const Color(0xFF22222F),
                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2563EB)))),
                        errorWidget: (_, __, ___) => Container(color: const Color(0xFF22222F),
                            child: const Icon(Icons.image_not_supported_rounded, color: Color(0xFF4B5563), size: 32)),
                      ),
                    ),
                    if (!widget.product.inStock)
                      Container(color: Colors.black.withValues(alpha: 0.6),
                          child: const Center(child: Text('OUT OF\nSTOCK', textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)))),
                    if (inCart)
                      Positioned(top: 8, right: 8,
                          child: AnimatedScale(
                              scale: 1.0, duration: const Duration(milliseconds: 300), curve: Curves.elasticOut,
                              child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(20)),
                                  child: Text('${cartItem.quantity}',
                                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))))),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.product.name,
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600, height: 1.3),
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(child: Text('\$${widget.product.price.toStringAsFixed(2)}',
                              style: const TextStyle(color: Color(0xFF2563EB), fontSize: 15, fontWeight: FontWeight.w800))),
                          if (widget.product.inStock)
                            inCart
                                ? Row(mainAxisSize: MainAxisSize.min, children: [
                              _MiniBtn(icon: Icons.remove, onTap: () => cart.decreaseQuantity(widget.product)),
                              Padding(padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: Text('${cartItem.quantity}',
                                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700))),
                              _MiniBtn(icon: Icons.add, active: true,
                                  onTap: cartItem.quantity < widget.product.stock ? () => cart.increaseQuantity(widget.product) : null),
                            ])
                                : _MiniBtn(icon: Icons.add_shopping_cart_rounded, active: true, onTap: () => cart.add(widget.product)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniBtn extends StatefulWidget {
  const _MiniBtn({required this.icon, this.onTap, this.active = false});
  final IconData icon; final VoidCallback? onTap; final bool active;
  @override
  State<_MiniBtn> createState() => _MiniBtnState();
}

class _MiniBtnState extends State<_MiniBtn> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override
  void initState() { super.initState(); _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100), lowerBound: 0.85, upperBound: 1.0, value: 1.0); }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) { if (widget.onTap != null) _ctrl.reverse(); },
      onTapUp: (_) { _ctrl.forward(); widget.onTap?.call(); },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _ctrl,
        child: Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: widget.active && widget.onTap != null ? const Color(0xFF2563EB) : const Color(0xFF22222F),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(widget.icon, size: 15, color: widget.onTap != null ? Colors.white : const Color(0xFF4B5563)),
        ),
      ),
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}