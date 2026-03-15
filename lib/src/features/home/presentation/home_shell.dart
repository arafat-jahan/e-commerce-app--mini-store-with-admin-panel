import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/presentation/providers/auth_provider.dart';
import '../../admin/presentation/screens/admin_dashboard_screen.dart';
import '../../catalog/presentation/screens/catalog_screen.dart';
import '../../cart/presentation/providers/cart_provider.dart';
import '../../cart/presentation/screens/cart_screen.dart';
import '../../orders/presentation/screens/order_history_screen.dart';
import '../../profile/presentation/screens/profile_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with TickerProviderStateMixin {
  int _index = 0;
  static const _titles = ['Shop', 'Cart', 'Orders', 'Profile'];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();
    final isAdmin = auth.user?.isAdmin ?? false;
    final cartCount = cart.items.fold<int>(0, (sum, i) => sum + i.quantity);
    final titles = [..._titles, if (isAdmin) 'Admin'];

    final pages = <Widget>[
      const CatalogScreen(),
      const CartScreen(),
      const OrderHistoryScreen(),
      const ProfileScreen(),
      if (isAdmin) const AdminDashboardScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF080B14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080B14),
        elevation: 0,
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) => FadeTransition(opacity: anim,
              child: SlideTransition(position: Tween(begin: const Offset(0, 0.3), end: Offset.zero)
                  .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)), child: child)),
          child: Row(key: ValueKey(_index), mainAxisSize: MainAxisSize.min, children: [
            Container(width: 34, height: 34,
                decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)]),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))]),
                child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 18)),
            const SizedBox(width: 10),
            Text(_index < titles.length ? titles[_index] : 'Shop',
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
          ]),
        ),
        actions: [
          GestureDetector(
            onTap: () async => context.read<AuthProvider>().signOut(),
            child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                    color: const Color(0xFF141925),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: const Color(0xFF1E293B))),
                child: const Icon(Icons.logout_rounded, size: 18, color: Color(0xFF64748B))),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeOutCubic,
        transitionBuilder: (child, anim) => FadeTransition(opacity: anim,
            child: SlideTransition(
                position: Tween(begin: const Offset(0.04, 0), end: Offset.zero)
                    .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
                child: child)),
        child: KeyedSubtree(key: ValueKey(_index), child: pages[_index]),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F1420),
          border: const Border(top: BorderSide(color: Color(0xFF1E293B))),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, -4))],
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          height: 66,
          destinations: [
            const NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront_rounded), label: 'Shop'),
            NavigationDestination(
                icon: Badge(isLabelVisible: cartCount > 0, label: Text('$cartCount'), backgroundColor: const Color(0xFF3B82F6),
                    child: const Icon(Icons.shopping_bag_outlined)),
                selectedIcon: Badge(isLabelVisible: cartCount > 0, label: Text('$cartCount'), backgroundColor: const Color(0xFF3B82F6),
                    child: const Icon(Icons.shopping_bag_rounded)),
                label: 'Cart'),
            const NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long_rounded), label: 'Orders'),
            const NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profile'),
            if (isAdmin) const NavigationDestination(
                icon: Icon(Icons.admin_panel_settings_outlined),
                selectedIcon: Icon(Icons.admin_panel_settings_rounded),
                label: 'Admin'),
          ],
        ),
      ),
    );
  }
}