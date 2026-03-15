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
      return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.block_rounded, size: 64, color: Colors.red),
        SizedBox(height: 16),
        Text('Access denied', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
      ]));
    }
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          color: const Color(0xFF0F0F13),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _AdminTab(label: 'Dashboard', icon: Icons.dashboard_rounded, selected: _tab == 0, onTap: () => setState(() => _tab = 0)),
              const SizedBox(width: 8),
              _AdminTab(label: 'Products', icon: Icons.inventory_2_rounded, selected: _tab == 1, onTap: () => setState(() => _tab = 1)),
              const SizedBox(width: 8),
              _AdminTab(label: 'Orders', icon: Icons.receipt_long_rounded, selected: _tab == 2, onTap: () => setState(() => _tab = 2)),
              const SizedBox(width: 8),
              _AdminTab(label: 'Users', icon: Icons.people_rounded, selected: _tab == 3, onTap: () => setState(() => _tab = 3)),
            ]),
          ),
        ),
        Expanded(
          child: _tab == 0 ? const _DashboardTab()
              : _tab == 1 ? const _ProductsTab()
              : _tab == 2 ? const _OrdersTab()
              : const _UsersTab(),
        ),
      ],
    );
  }
}

class _AdminTab extends StatelessWidget {
  const _AdminTab({required this.label, required this.icon, required this.selected, required this.onTap});
  final String label; final IconData icon; final bool selected; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2563EB) : const Color(0xFF1A1A24),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? const Color(0xFF2563EB) : const Color(0xFF2A2A3A)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: selected ? Colors.white : const Color(0xFF9CA3AF)),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: selected ? Colors.white : const Color(0xFF9CA3AF),
              fontSize: 13, fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
        ]),
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();
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
            final totalRevenue = (orderSnap.data?.docs)?.fold<double>(0, (acc, d) => acc + ((d.data()['total'] as num?)?.toDouble() ?? 0)) ?? 0;
            final pendingOrders = (orderSnap.data?.docs)?.where((d) => d.data()['status'] == 'pending').length ?? 0;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                GridView.count(
                  shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.4,
                  children: [
                    _StatCard(title: 'Total Orders', value: '$orderCount', icon: Icons.receipt_long_rounded, color: const Color(0xFF2563EB)),
                    _StatCard(title: 'Products', value: '$productCount', icon: Icons.inventory_2_rounded, color: const Color(0xFFD4AF37)),
                    _StatCard(title: 'Revenue', value: '\$${totalRevenue.toStringAsFixed(0)}', icon: Icons.attach_money_rounded, color: Colors.green),
                    _StatCard(title: 'Pending', value: '$pendingOrders', icon: Icons.hourglass_empty_rounded, color: Colors.orange),
                  ],
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
  const _StatCard({required this.title, required this.value, required this.icon, required this.color});
  final String title; final String value; final IconData icon; final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A24), borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A3A)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(width: 36, height: 36,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20)),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
          Text(title, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
        ]),
      ]),
    );
  }
}

class _ProductsTab extends StatelessWidget {
  const _ProductsTab();
  @override
  Widget build(BuildContext context) {
    final repo = ProductRepository();
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));
        final docs = snapshot.data?.docs ?? [];
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: SizedBox(width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => showDialog(context: context, builder: (_) => _EditProductDialog(repo: repo, product: null)),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add product', style: TextStyle(fontWeight: FontWeight.w700)),
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
            ),
            Expanded(
              child: docs.isEmpty
                  ? const Center(child: Text('No products yet', style: TextStyle(color: Color(0xFF9CA3AF))))
                  : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final product = Product.fromMap(docs[index].id, docs[index].data());
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFF1A1A24), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF2A2A3A))),
                      child: Row(children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(imageUrl: product.imageUrl, width: 56, height: 56, fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => Container(width: 56, height: 56, color: const Color(0xFF22222F),
                                    child: const Icon(Icons.image_not_supported_rounded, color: Color(0xFF4B5563), size: 20)))),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(product.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Row(children: [
                            Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF2563EB), fontSize: 13, fontWeight: FontWeight.w700)),
                            const SizedBox(width: 8),
                            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: const Color(0xFF22222F), borderRadius: BorderRadius.circular(20)),
                                child: Text(product.category, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11))),
                          ]),
                          const SizedBox(height: 4),
                          Text('Stock: ${product.stock}', style: TextStyle(color: product.stock > 0 ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.w600)),
                        ])),
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          _IconBtn(icon: Icons.edit_outlined, onTap: () => showDialog(context: context, builder: (_) => _EditProductDialog(repo: repo, product: product))),
                          const SizedBox(width: 4),
                          _IconBtn(icon: Icons.delete_outline_rounded, danger: true, onTap: () async {
                            final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
                              backgroundColor: const Color(0xFF1A1A24),
                              title: const Text('Delete product?', style: TextStyle(color: Colors.white)),
                              content: Text('Remove "${product.name}"?', style: const TextStyle(color: Color(0xFF9CA3AF))),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                FilledButton(onPressed: () => Navigator.pop(ctx, true),
                                    style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('Delete')),
                              ],
                            ));
                            if (confirm == true) await repo.delete(product.id);
                          }),
                        ]),
                      ]),
                    );
                  }),
            ),
          ],
        );
      },
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap, this.danger = false});
  final IconData icon; final VoidCallback onTap; final bool danger;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(width: 36, height: 36,
          decoration: BoxDecoration(
            color: danger ? Colors.red.withValues(alpha: 0.1) : const Color(0xFF22222F),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: danger ? Colors.red.withValues(alpha: 0.3) : const Color(0xFF2A2A3A)),
          ),
          child: Icon(icon, size: 18, color: danger ? Colors.red : const Color(0xFF9CA3AF))),
    );
  }
}

class _EditProductDialog extends StatefulWidget {
  const _EditProductDialog({required this.repo, required this.product});
  final ProductRepository repo; final Product? product;
  @override
  State<_EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<_EditProductDialog> {
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _description = TextEditingController();
  final _stock = TextEditingController(text: '0');
  String _category = 'Electronics';
  String? _imageUrl; XFile? _picked; bool _saving = false; bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    if (p != null) {
      _name.text = p.name; _price.text = p.price.toStringAsFixed(2);
      _description.text = p.description; _stock.text = '${p.stock}';
      _category = p.category; _imageUrl = p.imageUrl; _isActive = p.isActive;
    }
  }
  @override void dispose() { _name.dispose(); _price.dispose(); _description.dispose(); _stock.dispose(); super.dispose(); }

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => _picked = file);
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    final price = double.tryParse(_price.text);
    if (price == null || price < 0) return;
    String imageUrl = _imageUrl ?? '';
    if (imageUrl.isEmpty && _picked == null && widget.product == null) return;
    setState(() => _saving = true);
    try {
      if (_picked != null) {
        final ref = FirebaseStorage.instance.ref('product_images/${const Uuid().v4()}.jpg');
        if (kIsWeb) { await ref.putData(await _picked!.readAsBytes()); } else { await ref.putFile(io.File(_picked!.path)); }
        imageUrl = await ref.getDownloadURL();
      }
      await widget.repo.addOrUpdate(Product(
          id: widget.product?.id ?? const Uuid().v4(), name: name, price: price,
          imageUrl: imageUrl, description: _description.text, category: _category,
          stock: int.tryParse(_stock.text) ?? 0, isActive: _isActive));
      if (!mounted) return;
      Navigator.of(context).pop();
    } finally { if (mounted) setState(() => _saving = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A1A24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(widget.product == null ? 'Add product' : 'Edit product',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          _DialogField(controller: _name, label: 'Name *'),
          const SizedBox(height: 12),
          _DialogField(controller: _price, label: 'Price *', keyboardType: const TextInputType.numberWithOptions(decimal: true)),
          const SizedBox(height: 12),
          _DialogField(controller: _stock, label: 'Stock', keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          _DialogField(controller: _description, label: 'Description', maxLines: 3),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _category, dropdownColor: const Color(0xFF1A1A24),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(labelText: 'Category', labelStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                filled: true, fillColor: const Color(0xFF22222F),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2A2A3A))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2A2A3A)))),
            items: ['Electronics', 'Clothing', 'Home', 'Accessories']
                .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) { if (v != null) setState(() => _category = v); },
          ),
          const SizedBox(height: 12),
          Row(children: [
            Switch(value: _isActive, onChanged: (v) => setState(() => _isActive = v), activeColor: const Color(0xFF2563EB)),
            const SizedBox(width: 8),
            const Text('Active', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
          ]),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickImage,
            child: Container(width: double.infinity, height: 90,
                decoration: BoxDecoration(color: const Color(0xFF22222F), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2A2A3A))),
                child: _picked != null || (_imageUrl != null && _imageUrl!.isNotEmpty)
                    ? ClipRRect(borderRadius: BorderRadius.circular(12),
                    child: _picked != null
                        ? (kIsWeb ? const Icon(Icons.image, color: Color(0xFF9CA3AF), size: 40)
                        : Image.file(io.File(_picked!.path), fit: BoxFit.cover, width: double.infinity))
                        : CachedNetworkImage(imageUrl: _imageUrl!, fit: BoxFit.cover))
                    : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.upload_rounded, color: Color(0xFF4B5563), size: 28),
                  SizedBox(height: 8),
                  Text('Tap to upload', style: TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
                ])),
          ),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: OutlinedButton(
                onPressed: _saving ? null : () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF2A2A3A)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('Cancel', style: TextStyle(color: Color(0xFF9CA3AF))))),
            const SizedBox(width: 12),
            Expanded(child: FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
                child: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Save', style: TextStyle(fontWeight: FontWeight.w700)))),
          ]),
        ]),
      ),
    );
  }
}

class _DialogField extends StatelessWidget {
  const _DialogField({required this.controller, required this.label, this.keyboardType, this.maxLines = 1});
  final TextEditingController controller; final String label; final TextInputType? keyboardType; final int maxLines;
  @override
  Widget build(BuildContext context) {
    return TextField(controller: controller, keyboardType: keyboardType, maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Color(0xFF9CA3AF)),
            filled: true, fillColor: const Color(0xFF22222F),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2A2A3A))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2A2A3A))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2563EB)))));
  }
}

class _OrdersTab extends StatelessWidget {
  const _OrdersTab();
  Color _statusColor(String s) {
    switch (s) {
      case 'delivered': return Colors.green;
      case 'shipped': return const Color(0xFF2563EB);
      case 'confirmed': return const Color(0xFFD4AF37);
      default: return const Color(0xFF9CA3AF);
    }
  }
  @override
  Widget build(BuildContext context) {
    final stream = context.watch<OrdersProvider>().ordersStream;
    if (stream == null) return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return const Center(child: Text('No orders yet', style: TextStyle(color: Color(0xFF9CA3AF))));
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final data = docs[index].data();
            final total = (data['total'] as num?)?.toDouble() ?? 0;
            final userId = data['userId'] as String? ?? '';
            final status = data['status'] as String? ?? 'pending';
            final orderId = docs[index].id;
            return GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: orderId, isAdmin: true))),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFF1A1A24), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF2A2A3A))),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Order #${orderId.length >= 8 ? orderId.substring(0, 8).toUpperCase() : orderId.toUpperCase()}',
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('User: ${userId.length > 12 ? '${userId.substring(0, 12)}...' : userId}',
                        style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
                  ])),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF2563EB), fontSize: 15, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: _statusColor(status).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                        child: Text(status.toUpperCase(), style: TextStyle(color: _statusColor(status), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8))),
                  ]),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF4B5563)),
                ]),
              ),
            );
          },
        );
      },
    );
  }
}

class _UsersTab extends StatelessWidget {
  const _UsersTab();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return const Center(child: Text('No users', style: TextStyle(color: Color(0xFF9CA3AF))));
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final data = docs[index].data();
            final email = data['email'] as String? ?? '';
            final rawRole = data['role'] as String? ?? 'user';
            final safeRole = ['user', 'admin'].contains(rawRole.trim()) ? rawRole.trim() : 'user';
            final uid = docs[index].id;
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFF1A1A24), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF2A2A3A))),
              child: Row(children: [
                Container(width: 44, height: 44,
                    decoration: BoxDecoration(
                        color: safeRole == 'admin' ? const Color(0xFFD4AF37).withValues(alpha: 0.15) : const Color(0xFF2563EB).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12)),
                    child: Icon(safeRole == 'admin' ? Icons.admin_panel_settings_rounded : Icons.person_rounded,
                        color: safeRole == 'admin' ? const Color(0xFFD4AF37) : const Color(0xFF2563EB), size: 22)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(email, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('Role: $safeRole', style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
                ])),
                DropdownButton<String>(
                    value: safeRole, dropdownColor: const Color(0xFF1A1A24),
                    underline: const SizedBox(), style: const TextStyle(color: Colors.white, fontSize: 13),
                    items: const [
                      DropdownMenuItem(value: 'user', child: Text('User', style: TextStyle(color: Color(0xFF9CA3AF)))),
                      DropdownMenuItem(value: 'admin', child: Text('Admin', style: TextStyle(color: Color(0xFFD4AF37)))),
                    ],
                    onChanged: (newRole) async {
                      if (newRole == null) return;
                      await FirebaseFirestore.instance.collection('users').doc(uid).update({'role': newRole});
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Role updated to $newRole')));
                    }),
              ]),
            );
          },
        );
      },
    );
  }
}