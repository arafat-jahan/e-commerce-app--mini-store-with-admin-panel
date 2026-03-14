import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/orders_provider.dart';
import '../../domain/entities/order.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({
    super.key,
    required this.orderId,
    this.isAdmin = false,
  });

  final String orderId;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Order?>(
      future: context.read<OrdersProvider>().getOrder(orderId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final order = snapshot.data;
        if (order == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Order')),
            body: const Center(child: Text('Order not found')),
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

  Future<void> _updateStatus() async {
    await context.read<OrdersProvider>().updateOrderStatus(widget.order.id, _status);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Status updated')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${order.id.substring(0, order.id.length.clamp(0, 8))}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Status',
                        style: theme.textTheme.titleSmall,
                      ),
                      if (widget.isAdmin)
                        DropdownButton<String>(
                          value: _status,
                          items: const [
                            DropdownMenuItem(value: 'pending', child: Text('Pending')),
                            DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
                            DropdownMenuItem(value: 'shipped', child: Text('Shipped')),
                            DropdownMenuItem(value: 'delivered', child: Text('Delivered')),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _status = v);
                          },
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _statusColor(_status).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _status.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _statusColor(_status),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (widget.isAdmin) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _updateStatus,
                        child: const Text('Update status'),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    'Date: ${DateFormat.yMMMd().add_jm().format(order.createdAt)}',
                    style: theme.textTheme.bodySmall,
                  ),
                  if (order.shippingAddress.address.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text('Shipping', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(
                      order.shippingAddress.displayText,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Items', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ...order.items.map((item) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: item.imageUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => const Icon(Icons.image),
                    ),
                  ),
                  title: Text(item.name),
                  subtitle: Text('${item.quantity} × \$${item.price.toStringAsFixed(2)}'),
                  trailing: Text(
                    '\$${item.lineTotal.toStringAsFixed(2)}',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              )),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: theme.textTheme.titleMedium),
              Text(
                '\$${order.total.toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'delivered':
        return Colors.green;
      case 'shipped':
        return Colors.blue;
      case 'confirmed':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
