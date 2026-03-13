import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../catalog/data/product_repository.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../orders/presentation/providers/orders_provider.dart';

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
            'Manage catalog and monitor orders',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Products')),
              ButtonSegment(value: 1, label: Text('Orders')),
            ],
            selected: {_tab},
            onSelectionChanged: (v) {
              setState(() => _tab = v.first);
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _tab == 0
                ? const _AdminProductsTab()
                : const _AdminOrdersTab(),
          ),
        ],
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
                                    await repo.delete(product.id);
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
  String _category = 'Electronics';
  String? _imageUrl;
  XFile? _picked;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    if (p != null) {
      _name.text = p.name;
      _price.text = p.price.toStringAsFixed(2);
      _description.text = p.description;
      _category = p.category;
      _imageUrl = p.imageUrl;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _description.dispose();
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
    setState(() => _saving = true);
    try {
      String imageUrl = _imageUrl ?? '';
      if (_picked != null) {
        final uid = const Uuid().v4();
        final ref =
            FirebaseStorage.instance.ref('product_images/$uid.jpg');
        if (kIsWeb) {
          final bytes = await _picked!.readAsBytes();
          await ref.putData(bytes);
        } else {
          await ref.putFile(File(_picked!.path));
        }
        imageUrl = await ref.getDownloadURL();
      }

      final price = double.tryParse(_price.text) ?? 0;
      final id = widget.product?.id ?? const Uuid().v4();

      final product = Product(
        id: id,
        name: _name.text,
        price: price,
        imageUrl: imageUrl,
        description: _description.text,
        category: _category,
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
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _price,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            TextField(
              controller: _description,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _category,
              items: const [
                DropdownMenuItem(
                  value: 'Electronics',
                  child: Text('Electronics'),
                ),
                DropdownMenuItem(
                  value: 'Clothing',
                  child: Text('Clothing'),
                ),
                DropdownMenuItem(
                  value: 'Home',
                  child: Text('Home'),
                ),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _category = v);
              },
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text('Pick image'),
                ),
                const SizedBox(width: 8),
                if (_picked != null || _imageUrl != null)
                  const Icon(Icons.check_circle, color: Colors.green),
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
    final stream =
        context.watch<OrdersProvider>().ordersStream;
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
            final data = docs[index].data();
            final total = (data['total'] as num?)?.toDouble() ?? 0;
            final userId = data['userId'] as String? ?? '';
            final status = data['status'] as String? ?? 'pending';

            return ListTile(
              title: Text('User: $userId'),
              subtitle: Text('Total: \$${total.toStringAsFixed(2)}'),
              trailing: Text(status),
            );
          },
        );
      },
    );
  }
}

