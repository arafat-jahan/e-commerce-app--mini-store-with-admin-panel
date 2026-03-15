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

    return LayoutBuilder(builder: (context, constraints) {
      final crossAxisCount = constraints.maxWidth > 800 ? 4 : 2;
      return Column(children: [
        Container(
          color: const Color(0xFF080B14),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(children: [
            Container(
              decoration: BoxDecoration(color: const Color(0xFF141925), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF1E293B))),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    hintText: 'Search products...',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.25)),
                    prefixIcon: Icon(Icons.search_rounded, size: 20, color: Colors.white.withValues(alpha: 0.3)),
                    suffixIcon: products.search.isNotEmpty
                        ? IconButton(icon: Icon(Icons.close_rounded, size: 18, color: Colors.white.withValues(alpha: 0.3)), onPressed: () => products.setSearch(''))
                        : null,
                    border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), filled: false),
                onChanged: products.setSearch,
              ),
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
                        duration: const Duration(milliseconds: 250), curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: selected ? const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)]) : null,
                          color: selected ? null : const Color(0xFF141925),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: selected ? Colors.transparent : const Color(0xFF1E293B)),
                          boxShadow: selected ? [BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 4))] : [],
                        ),
                        child: Text(cat, style: TextStyle(
                            color: selected ? Colors.white : Colors.white.withValues(alpha: 0.4),
                            fontSize: 13, fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ]),
        ),
        Expanded(
          child: list.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 80, height: 80,
                decoration: BoxDecoration(color: const Color(0xFF141925), borderRadius: BorderRadius.circular(20)),
                child: Icon(Icons.search_off_rounded, size: 36, color: Colors.white.withValues(alpha: 0.2))),
            const SizedBox(height: 16),
            Text('No products found', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 16, fontWeight: FontWeight.w600)),
          ]))
              : GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.63),
              itemCount: list.length,
              itemBuilder: (context, index) => _AnimatedCard(product: list[index], index: index)),
        ),
      ]);
    });
  }
}

class _AnimatedCard extends StatefulWidget {
  const _AnimatedCard({required this.product, required this.index});
  final Product product; final int index;
  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    final delay = (widget.index * 0.07).clamp(0.0, 0.65);
    final end = (delay + 0.45).clamp(0.0, 1.0);
    _fade = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Interval(delay, end, curve: Curves.easeOut)));
    _slide = Tween(begin: const Offset(0, 0.25), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Interval(delay, end, curve: Curves.easeOutCubic)));
    _scale = Tween(begin: 0.88, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Interval(delay, end, curve: Curves.easeOutCubic)));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _fade,
        child: SlideTransition(position: _slide,
            child: ScaleTransition(scale: _scale,
                child: _ProductCard(product: widget.product))));
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
  @override
  void initState() { super.initState(); _tapCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 130), lowerBound: 0.94, upperBound: 1.0, value: 1.0); }
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
            transitionDuration: const Duration(milliseconds: 350)));
      },
      onTapCancel: () => _tapCtrl.forward(),
      child: ScaleTransition(scale: _tapCtrl,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF141925),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(flex: 3,
                child: Stack(fit: StackFit.expand, children: [
                  Hero(tag: 'product-${widget.product.id}',
                      child: CachedNetworkImage(imageUrl: widget.product.imageUrl, fit: BoxFit.cover,
                          placeholder: (_, __) => Container(color: const Color(0xFF1C2235),
                              child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: const Color(0xFF3B82F6).withValues(alpha: 0.5)))),
                          errorWidget: (_, __, ___) => Container(color: const Color(0xFF1C2235),
                              child: Icon(Icons.image_not_supported_rounded, color: Colors.white.withValues(alpha: 0.15), size: 32)))),
                  // Gradient overlay at bottom
                  Positioned(bottom: 0, left: 0, right: 0,
                      child: Container(height: 60,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, const Color(0xFF141925).withValues(alpha: 0.8)])))),
                  if (!widget.product.inStock)
                    Container(color: Colors.black.withValues(alpha: 0.65),
                        child: const Center(child: Text('OUT OF STOCK', textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5)))),
                  if (inCart)
                    Positioned(top: 10, right: 10,
                        child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)]),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.4), blurRadius: 10)]),
                            child: Text('${cartItem.quantity}',
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)))),
                ])),
            Expanded(flex: 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(widget.product.name,
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600, height: 1.3),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    const Spacer(),
                    Row(children: [
                      Expanded(child: Text('\$${widget.product.price.toStringAsFixed(2)}',
                          style: const TextStyle(color: Color(0xFF3B82F6), fontSize: 16, fontWeight: FontWeight.w800))),
                      if (widget.product.inStock)
                        inCart
                            ? Row(mainAxisSize: MainAxisSize.min, children: [
                          _MiniBtn(icon: Icons.remove, onTap: () => cart.decreaseQuantity(widget.product)),
                          Padding(padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text('${cartItem.quantity}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700))),
                          _MiniBtn(icon: Icons.add, active: true,
                              onTap: cartItem.quantity < widget.product.stock ? () => cart.increaseQuantity(widget.product) : null),
                        ])
                            : _MiniBtn(icon: Icons.add_rounded, active: true, onTap: () => cart.add(widget.product)),
                    ]),
                  ]),
                )),
          ]),
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
  void initState() { super.initState(); _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100), lowerBound: 0.8, upperBound: 1.0, value: 1.0); }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) { if (widget.onTap != null) _ctrl.reverse(); },
      onTapUp: (_) { _ctrl.forward(); widget.onTap?.call(); },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(scale: _ctrl,
          child: Container(width: 30, height: 30,
              decoration: BoxDecoration(
                gradient: widget.active && widget.onTap != null
                    ? const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)])
                    : null,
                color: widget.active && widget.onTap != null ? null : const Color(0xFF1C2235),
                borderRadius: BorderRadius.circular(9),
                boxShadow: widget.active && widget.onTap != null
                    ? [BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.35), blurRadius: 8)] : [],
              ),
              child: Icon(widget.icon, size: 15, color: widget.onTap != null ? Colors.white : Colors.white.withValues(alpha: 0.2)))),
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}