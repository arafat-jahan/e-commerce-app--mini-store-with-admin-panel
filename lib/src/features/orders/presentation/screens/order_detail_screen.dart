import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/orders_provider.dart';
import '../../domain/entities/order.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key, required this.orderId, this.isAdmin = false});
  final String orderId;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Order?>(
      future: context.read<OrdersProvider>().getOrder(orderId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0F0F13),
            body: Center(child: CircularProgressIndicator(color: Color(0xFF2563EB))),
          );
        }
        final order = snapshot.data;
        if (order == null) {
          return Scaffold(
            backgroundColor: const Color(0xFF0F0F13),
            appBar: AppBar(title: const Text('Order')),
            body: const Center(child: Text('Order not found', style: TextStyle(color: Colors.white))),
          );
        }
        return _OrderDetailBody(order: order, isAdmin: isAdmin);
      },
    );
  }
}

class _OrderDetailBody extends StatefulWidget {
  const _OrderDetailBody({required this.order, required this.isAdmin});
  final Order order;
  final bool isAdmin;

  @override
  State<_OrderDetailBody> createState() => _OrderDetailBodyState();
}

class _OrderDetailBodyState extends State<_OrderDetailBody> {
  late String _status;

  @override
  void initState() {
    super.initState();
    _status = widget.order.status;
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'delivered': return Colors.green;
      case 'shipped': return const Color(0xFF2563EB);
      case 'confirmed': return const Color(0xFFD4AF37);
      default: return const Color(0xFF9CA3AF);
    }
  }

  Future<void> _updateStatus() async {
    await context.read<OrdersProvider>().updateOrderStatus(widget.order.id, _status);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status updated successfully')));
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      appBar: AppBar(
        title: Text('Order #${order.id.substring(0, order.id.length.clamp(0, 8)).toUpperCase()}'),
        backgroundColor: const Color(0xFF0F0F13),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Status card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A24),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2A2A3A)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('STATUS', style: TextStyle(color: Color(0xFF6B7280), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                    if (!widget.isAdmin)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: _statusColor(_status).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _statusColor(_status).withValues(alpha: 0.3)),
                        ),
                        child: Text(_status.toUpperCase(),
                            style: TextStyle(color: _statusColor(_status), fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                      ),
                    if (widget.isAdmin)
                      DropdownButton<String>(
                        value: _status,
                        dropdownColor: const Color(0xFF1A1A24),
                        style: const TextStyle(color: Colors.white),
                        underline: const SizedBox(),
                        items: ['pending', 'confirmed', 'shipped', 'delivered'].map((s) =>
                            DropdownMenuItem(value: s, child: Text(s.toUpperCase(),
                                style: TextStyle(color: _statusColor(s), fontSize: 13, fontWeight: FontWeight.w700)))).toList(),
                        onChanged: (v) { if (v != null) setState(() => _status = v); },
                      ),
                  ],
                ),
                if (widget.isAdmin) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity, height: 44,
                    child: FilledButton(
                      onPressed: _updateStatus,
                      style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('Update status', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                const Divider(color: Color(0xFF2A2A3A), height: 1),
                const SizedBox(height: 16),
                Row(children: [
                  const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF6B7280)),
                  const SizedBox(width: 8),
                  Text(DateFormat.yMMMd().add_jm().format(order.createdAt),
                      style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
                ]),
                if (order.shippingAddress.address.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFF2A2A3A), height: 1),
                  const SizedBox(height: 12),
                  const Text('SHIPPING TO', style: TextStyle(color: Color(0xFF6B7280), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF2563EB)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(order.shippingAddress.displayText,
                        style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13, height: 1.5))),
                  ]),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Items
          const Text('ITEMS', style: TextStyle(color: Color(0xFF6B7280), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A24),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2A2A3A)),
            ),
            child: Column(
              children: order.items.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                                imageUrl: item.imageUrl, width: 56, height: 56, fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => Container(
                                    width: 56, height: 56, color: const Color(0xFF22222F),
                                    child: const Icon(Icons.image_not_supported_rounded, color: Color(0xFF4B5563), size: 20))),
                          ),
                          const SizedBox(width: 14),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name,
                                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                                  maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text('${item.quantity} × \$${item.price.toStringAsFixed(2)}',
                                  style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
                            ],
                          )),
                          Text('\$${item.lineTotal.toStringAsFixed(2)}',
                              style: const TextStyle(color: Color(0xFF2563EB), fontSize: 15, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                    if (i < order.items.length - 1)
                      const Divider(color: Color(0xFF2A2A3A), height: 1, indent: 14, endIndent: 14),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Total
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A24),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2A2A3A)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                Text('\$${order.total.toStringAsFixed(2)}',
                    style: const TextStyle(color: Color(0xFF2563EB), fontSize: 22, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}