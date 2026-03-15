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

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _titles = ['Shop', 'Cart', 'Orders', 'Profile'];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();
    final isAdmin = auth.user?.isAdmin ?? false;
    final cartCount = cart.items.fold<int>(0, (sum, i) => sum + i.quantity);

    final pages = <Widget>[
      const CatalogScreen(),
      const CartScreen(),
      const OrderHistoryScreen(),
      const ProfileScreen(),
      if (isAdmin) const AdminDashboardScreen(),
    ];

    final titles = [..._titles, if (isAdmin) 'Admin'];

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F13),
        title: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)]),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Text(
              _index < titles.length ? titles[_index] : 'Shop',
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.5),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async => context.read<AuthProvider>().signOut(),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A24),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF2A2A3A)),
              ),
              child: const Icon(Icons.logout_rounded, size: 18, color: Color(0xFF9CA3AF)),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: pages[_index],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A24),
          border: Border(top: BorderSide(color: Color(0xFF2A2A3A))),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          height: 64,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.storefront_outlined),
              selectedIcon: Icon(Icons.storefront_rounded),
              label: 'Shop',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: cartCount > 0,
                label: Text('$cartCount'),
                backgroundColor: const Color(0xFF2563EB),
                child: const Icon(Icons.shopping_cart_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: cartCount > 0,
                label: Text('$cartCount'),
                backgroundColor: const Color(0xFF2563EB),
                child: const Icon(Icons.shopping_cart_rounded),
              ),
              label: 'Cart',
            ),
            const NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long_rounded),
              label: 'Orders',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
            if (isAdmin)
              const NavigationDestination(
                icon: Icon(Icons.admin_panel_settings_outlined),
                selectedIcon: Icon(Icons.admin_panel_settings_rounded),
                label: 'Admin',
              ),
          ],
        ),
      ),
    );
  }
}