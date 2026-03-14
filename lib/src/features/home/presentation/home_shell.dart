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

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();
    final isAdmin = auth.user?.isAdmin ?? false;

    // Total item count for the badge
    final cartCount = cart.items.fold<int>(0, (sum, i) => sum + i.quantity);

    final pages = <Widget>[
      const CatalogScreen(),
      const CartScreen(),
      const OrderHistoryScreen(),
      const ProfileScreen(),
      if (isAdmin) const AdminDashboardScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Store'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async => context.read<AuthProvider>().signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: pages[_index],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.storefront),
            label: 'Shop',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              child: const Icon(Icons.shopping_cart),
            ),
            label: 'Cart',
          ),
          const NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          if (isAdmin)
            const NavigationDestination(
              icon: Icon(Icons.admin_panel_settings),
              label: 'Admin',
            ),
        ],
      ),
    );
  }
}