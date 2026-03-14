import 'dart:io' if (dart.library.html) 'package:mini_store/src/features/admin/io_stub.dart' as io;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../catalog/data/product_repository.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../orders/presentation/providers/orders_provider.dart';
import '../../../orders/presentation/screens/order_detail_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    context.read<OrdersProvider>().listenForAll();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().user?.isAdmin ?? false;
    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('Access denied. Admin only.'),
            ],
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Admin',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Dashboard, catalog, orders & users',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Dashboard')),
              ButtonSegment(value: 1, label: Text('Products')),
              ButtonSegment(value: 2, label: Text('Orders')),
              ButtonSegment(value: 3, label: Text('Users')),
            ],
            selected: {_tab},
            onSelectionChanged: (v) {
              setState(() => _tab = v.first);
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _tab == 0
                ? const _AdminDashboardTab()
                : _tab == 1
                    ? const _AdminProductsTab()
                    : _tab == 2
                        ? const _AdminOrdersTab()
                        : const _AdminUsersTab(),
          ),
        ],
      ),
    );
  }
}

class _AdminDashboardTab extends StatelessWidget {
  const _AdminDashboardTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('orders').snapshots(),
      builder: (context, orderSnap) {
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('products').snapshots(),
          builder: (context, productSnap) {
            final orderCount = orderSnap.data?.docs.length ?? 0;
            final productCount = productSnap.data?.docs.length ?? 0;
            final totalRevenue = (orderSnap.data?.docs)
                    ?.fold<double>(
                        0,
                        (acc, d) =>
                            acc +
                            ((d.data()['total'] as num?)?.toDouble() ?? 0)) ??
                0;

            return GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
              padding: const EdgeInsets.only(top: 8),
              children: [
                _StatCard(
                  title: 'Orders',
                  value: '$orderCount',
                  icon: Icons.receipt_long,
                ),
                _StatCard(
                  title: 'Products',
                  value: '$productCount',
                  icon: Icons.inventory_2,
                ),
                _StatCard(
                  title: 'Revenue',
                  value: '\$${totalRevenue.toStringAsFixed(0)}',
                  icon: Icons.attach_money,
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminProductsTab extends StatelessWidget {
  const _AdminProductsTab();

  @override
  Widget build(BuildContext context) {
    final repo = ProductRepository();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data?.docs ?? [];

        return Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (_) => _EditProductDialog(
                      repo: repo,
                      product: null,
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Add product'),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: docs.isEmpty
                  ? const Center(child: Text('No products yet'))
                  : ListView.separated(
                      itemCount: docs.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final d = docs[index];
                        final product =
                            Product.fromMap(d.id, d.data());
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  CachedNetworkImageProvider(
                                      product.imageUrl),
                            ),
                            title: Text(product.name),
                            subtitle: Text(
                              '\$${product.price.toStringAsFixed(2)} • ${product.category}',
                            ),
                            trailing: Wrap(
                              spacing: 8,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                      Icons.edit_outlined),
                                  onPressed: () async {
                                    await showDialog(
                                      context: context,
                                      builder: (_) =>
                                          _EditProductDialog(
                                        repo: repo,
                                        product: product,
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                      Icons.delete_outline),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Delete product?'),
                                        content: Text(
                                          'Remove "${product.name}" from the catalog?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: const Text('Cancel'),
                                          ),
                                          FilledButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            style: FilledButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await repo.delete(product.id);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text('Product deleted'),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _EditProductDialog extends StatefulWidget {
  const _EditProductDialog({
    required this.repo,
    required this.product,
  });

  final ProductRepository repo;
  final Product? product;

  @override
  State<_EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<_EditProductDialog> {
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _description = TextEditingController();
  final _stock = TextEditingController(text: '0');
  String _category = 'Electronics';
  String? _imageUrl;
  XFile? _picked;
  bool _saving = false;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    if (p != null) {
      _name.text = p.name;
      _price.text = p.price.toStringAsFixed(2);
      _description.text = p.description;
      _stock.text = '${p.stock}';
      _category = p.category;
      _imageUrl = p.imageUrl;
      _isActive = p.isActive;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _description.dispose();
    _stock.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _picked = file;
      });
    }
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name is required')),
      );
      return;
    }
    final price = double.tryParse(_price.text);
    if (price == null || price < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid price')),
      );
      return;
    }
    String imageUrl = _imageUrl ?? '';
    if (imageUrl.isEmpty && _picked == null && widget.product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick an image for new product')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      if (_picked != null) {
        final uid = const Uuid().v4();
        final ref =
            FirebaseStorage.instance.ref('product_images/$uid.jpg');
        if (kIsWeb) {
          final bytes = await _picked!.readAsBytes();
          await ref.putData(bytes);
        } else {
          await ref.putFile(io.File(_picked!.path));
        }
        imageUrl = await ref.getDownloadURL();
      }

      final stock = int.tryParse(_stock.text) ?? 0;
      final id = widget.product?.id ?? const Uuid().v4();

      final product = Product(
        id: id,
        name: name,
        price: price,
        imageUrl: imageUrl,
        description: _description.text,
        category: _category,
        stock: stock,
        isActive: _isActive,
      );
      await widget.repo.addOrUpdate(product);
      if (!mounted) return;
      Navigator.of(context).pop();
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product == null ? 'Add product' : 'Edit product'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Name *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _price,
              decoration: const InputDecoration(
                labelText: 'Price *',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _stock,
              decoration: const InputDecoration(
                labelText: 'Stock',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _description,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _category,
              items: const [
                DropdownMenuItem(value: 'Electronics', child: Text('Electronics')),
                DropdownMenuItem(value: 'Clothing', child: Text('Clothing')),
                DropdownMenuItem(value: 'Home', child: Text('Home')),
                DropdownMenuItem(value: 'Accessories', child: Text('Accessories')),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _category = v);
              },
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              title: const Text('Active (visible in catalog)'),
              value: _isActive,
              onChanged: (v) => setState(() => _isActive = v ?? true),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 8),
            Text(
              'Product image',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_picked != null || (_imageUrl != null && _imageUrl!.isNotEmpty)) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: _picked != null
                          ? (kIsWeb
                              ? const Icon(Icons.image, size: 48)
                              : Image.file(
                                  io.File(_picked!.path),
                                  fit: BoxFit.cover,
                                ))
                          : CachedNetworkImage(
                              imageUrl: _imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (_, __) =>
                                  const Center(
                                      child: CircularProgressIndicator()),
                              errorWidget: (_, __, ___) =>
                                  const Icon(Icons.broken_image),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.upload_file),
                    label: Text(
                      (_picked != null || (_imageUrl != null && _imageUrl!.isNotEmpty))
                          ? 'Change image'
                          : 'Upload image',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}

class _AdminOrdersTab extends StatelessWidget {
  const _AdminOrdersTab();

  @override
  Widget build(BuildContext context) {
    final stream = context.watch<OrdersProvider>().ordersStream;
    if (stream == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('No orders yet'));
        }
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data();
            final total = (data['total'] as num?)?.toDouble() ?? 0;
            final userId = data['userId'] as String? ?? '';
            final status = data['status'] as String? ?? 'pending';
            final orderId = doc.id;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text('Order #${orderId.length >= 6 ? orderId.substring(0, 6) : orderId}'),
                subtitle: Text('User: $userId • \$${total.toStringAsFixed(2)}'),
                trailing: Text(status),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => OrderDetailScreen(
                        orderId: orderId,
                        isAdmin: true,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _AdminUsersTab extends StatelessWidget {
  const _AdminUsersTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('No users'));
        }
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data();
            final email = data['email'] as String? ?? '';
            final role = data['role'] as String? ?? 'user';
            final uid = doc.id;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(email),
                subtitle: Text('Role: $role'),
                trailing: DropdownButton<String>(
                  value: role,
                  items: const [
                    DropdownMenuItem(value: 'user', child: Text('User')),
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  ],
                  onChanged: (newRole) async {
                    if (newRole == null) return;
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .update({'role': newRole});
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Role set to $newRole')),
                      );
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

