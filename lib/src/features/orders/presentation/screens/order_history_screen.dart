import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import 'order_detail_screen.dart';
import '../providers/orders_provider.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});
  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final userId = context.read<AuthProvider>().user?.uid;
      if (userId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.read<OrdersProvider>().listenForUser(userId);
        });
      }
    }
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'delivered': return Colors.green;
      case 'shipped': return const Color(0xFF2563EB);
      case 'confirmed': return const Color(0xFFD4AF37);
      default: return const Color(0xFF9CA3AF);
    }
  }

  IconData _statusIcon(String s) {
    switch (s) {
      case 'delivered': return Icons.check_circle_rounded;
      case 'shipped': return Icons.local_shipping_rounded;
      case 'confirmed': return Icons.thumb_up_rounded;
      default: return Icons.hourglass_empty_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stream = context.watch<OrdersProvider>().ordersStream;

    if (stream == null) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (_, v, child) => Opacity(opacity: v,
                  child: Transform.translate(offset: Offset(0, (1 - v) * 30), child: child)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(width: 100, height: 100,
                    decoration: BoxDecoration(color: const Color(0xFF1A1A24), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF2A2A3A))),
                    child: const Icon(Icons.receipt_long_rounded, size: 44, color: Color(0xFF4B5563))),
                const SizedBox(height: 20),
                const Text('No orders yet', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const Text('Your order history will appear here', style: TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
              ]),
            ),
          );
        }

        final docs = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data();
            final total = (data['total'] as num?)?.toDouble() ?? 0;
            final status = data['status'] as String? ?? 'pending';
            final ts = data['createdAt'] as Timestamp?;
            final created = ts?.toDate();
            final formatted = created == null ? '' : DateFormat.yMMMd().add_jm().format(created);
            final orderId = docs[index].id;
            final itemCount = (data['items'] as List?)?.length ?? 0;

            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 400 + (index * 80)),
              curve: Curves.easeOutCubic,
              builder: (_, v, child) => Opacity(opacity: v.clamp(0.0, 1.0),
                  child: Transform.translate(offset: Offset(0, (1 - v) * 30), child: child)),
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (_, anim, __) => SlideTransition(
                      position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(
                          CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
                      child: OrderDetailScreen(orderId: orderId)),
                  transitionDuration: const Duration(milliseconds: 350),
                )),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A24),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF2A2A3A)),
                  ),
                  child: Column(children: [
                    Row(children: [
                      Container(width: 44, height: 44,
                          decoration: BoxDecoration(
                              color: _statusColor(status).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12)),
                          child: Icon(_statusIcon(status), color: _statusColor(status), size: 22)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Order #${orderId.length >= 8 ? orderId.substring(0, 8).toUpperCase() : orderId.toUpperCase()}',
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(formatted, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                      ])),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('\$${total.toStringAsFixed(2)}',
                            style: const TextStyle(color: Color(0xFF2563EB), fontSize: 16, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                                color: _statusColor(status).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20)),
                            child: Text(status.toUpperCase(),
                                style: TextStyle(color: _statusColor(status), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8))),
                      ]),
                    ]),
                    if (itemCount > 0) ...[
                      const SizedBox(height: 12),
                      const Divider(color: Color(0xFF2A2A3A), height: 1),
                      const SizedBox(height: 12),
                      Row(children: [
                        const Icon(Icons.inventory_2_outlined, size: 14, color: Color(0xFF6B7280)),
                        const SizedBox(width: 6),
                        Text('$itemCount item${itemCount > 1 ? 's' : ''}',
                            style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
                        const Spacer(),
                        const Text('View details', style: TextStyle(color: Color(0xFF2563EB), fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF2563EB)),
                      ]),
                    ],
                  ]),
                ),
              ),
            );
          },
        );
      },
    );
  }
}