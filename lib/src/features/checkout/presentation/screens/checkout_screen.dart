import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../orders/domain/entities/shipping_address.dart';
import '../../../orders/presentation/providers/orders_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  bool _placing = false;

  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fade = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _slide = Tween(begin: const Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_fullName.text.isEmpty) {
      final profile = context.read<AuthProvider>().user;
      if (profile != null) {
        _fullName.text = profile.displayName;
        _phone.text = profile.phone;
        _address.text = profile.defaultAddress;
        _city.text = profile.city;
      }
    }
  }

  @override
  void dispose() { _ctrl.dispose(); _fullName.dispose(); _phone.dispose(); _address.dispose(); _city.dispose(); super.dispose(); }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final userId = auth.user?.uid;
    if (userId == null) return;
    final cart = context.read<CartProvider>();
    if (cart.items.isEmpty) return;
    setState(() => _placing = true);
    try {
      await context.read<OrdersProvider>().placeOrder(
          userId: userId, items: cart.items, total: cart.total,
          shippingAddress: ShippingAddress(fullName: _fullName.text.trim(), phone: _phone.text.trim(), address: _address.text.trim(), city: _city.text.trim()));
      cart.clear();
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🎉 Order placed! Pay on delivery.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally { if (mounted) setState(() => _placing = false); }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFF080B14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080B14),
        title: const Text('Checkout'),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => Navigator.of(context).pop()),
      ),
      body: cart.items.isEmpty
          ? const Center(child: Text('Cart is empty', style: TextStyle(color: Colors.white)))
          : FadeTransition(opacity: _fade, child: SlideTransition(position: _slide,
          child: Form(key: _formKey,
            child: ListView(padding: const EdgeInsets.all(20), children: [
              _SectionLabel('SHIPPING ADDRESS'),
              const SizedBox(height: 12),
              _GlassField(controller: _fullName, label: 'Full name', icon: Icons.person_outline_rounded,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null),
              const SizedBox(height: 12),
              _GlassField(controller: _phone, label: 'Phone number', icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone, validator: (v) => v == null || v.isEmpty ? 'Required' : null),
              const SizedBox(height: 12),
              _GlassField(controller: _address, label: 'Street address', icon: Icons.location_on_outlined,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null),
              const SizedBox(height: 12),
              _GlassField(controller: _city, label: 'City', icon: Icons.location_city_outlined,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null),
              const SizedBox(height: 28),

              _SectionLabel('ORDER SUMMARY'),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(color: const Color(0xFF141925), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF1E293B))),
                child: Column(children: [
                  ...cart.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(item.product.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 3),
                          Text('${item.quantity} × \$${item.product.price.toStringAsFixed(2)}', style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 13)),
                        ])),
                        Text('\$${item.lineTotal.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                      ]))),
                  Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
                  Padding(padding: const EdgeInsets.all(16),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('Total', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                        Text('\$${cart.total.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF3B82F6), fontSize: 22, fontWeight: FontWeight.w800)),
                      ])),
                ]),
              ),
              const SizedBox(height: 16),

              Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.2))),
                  child: Row(children: [
                    const Icon(Icons.payments_outlined, color: Color(0xFF3B82F6), size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Cash on delivery — pay when your order arrives.',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13))),
                  ])),
              const SizedBox(height: 28),

              GestureDetector(
                onTap: _placing ? null : _placeOrder,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity, height: 58,
                  decoration: BoxDecoration(
                      gradient: _placing ? null : const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)]),
                      color: _placing ? const Color(0xFF141925) : null,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: _placing ? [] : [BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.4), blurRadius: 24, offset: const Offset(0, 8))]),
                  child: _placing
                      ? const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)))
                      : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text('Place order (COD)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
              const SizedBox(height: 32),
            ]),
          )),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5));
  }
}

class _GlassField extends StatelessWidget {
  const _GlassField({required this.controller, required this.label, required this.icon, this.keyboardType, this.validator});
  final TextEditingController controller; final String label; final IconData icon;
  final TextInputType? keyboardType; final String? Function(String?)? validator;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF141925), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF1E293B))),
      child: TextFormField(
        controller: controller, keyboardType: keyboardType, validator: validator,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
            labelText: label, labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
            prefixIcon: Icon(icon, size: 20, color: Colors.white.withValues(alpha: 0.25)),
            border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), filled: false),
      ),
    );
  }
}