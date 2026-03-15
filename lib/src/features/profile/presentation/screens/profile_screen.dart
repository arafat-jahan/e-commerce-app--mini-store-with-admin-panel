import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayName;
  late TextEditingController _phone;
  late TextEditingController _address;
  late TextEditingController _city;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _displayName = TextEditingController(text: user?.displayName ?? '');
    _phone = TextEditingController(text: user?.phone ?? '');
    _address = TextEditingController(text: user?.defaultAddress ?? '');
    _city = TextEditingController(text: user?.city ?? '');
  }

  @override
  void dispose() {
    _displayName.dispose();
    _phone.dispose();
    _address.dispose();
    _city.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await context.read<AuthProvider>().updateProfile(
        displayName: _displayName.text.trim(),
        phone: _phone.text.trim(),
        defaultAddress: _address.text.trim(),
        city: _city.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) return const Center(child: Text('Not signed in', style: TextStyle(color: Colors.white)));

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Profile header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF1A1A24), Color(0xFF0D1B2A)],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF2A2A3A)),
          ),
          child: Row(
            children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                      user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : user.email[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        user.displayName.isNotEmpty ? user.displayName : 'No name set',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(user.email, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: user.isAdmin
                            ? const Color(0xFFD4AF37).withValues(alpha: 0.15)
                            : const Color(0xFF2563EB).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: user.isAdmin
                                ? const Color(0xFFD4AF37).withValues(alpha: 0.4)
                                : const Color(0xFF2563EB).withValues(alpha: 0.4)),
                      ),
                      child: Text(
                          user.isAdmin ? '👑 Admin' : '👤 Customer',
                          style: TextStyle(
                              color: user.isAdmin ? const Color(0xFFD4AF37) : const Color(0xFF2563EB),
                              fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        const _SectionHeader('PERSONAL INFO'),
        const SizedBox(height: 12),

        Form(
          key: _formKey,
          child: Column(
            children: [
              _ProfileField(controller: _displayName, label: 'Display name', icon: Icons.person_outline_rounded),
              const SizedBox(height: 14),
              _ProfileField(controller: _phone, label: 'Phone number', icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 14),
              _ProfileField(controller: _address, label: 'Default address', icon: Icons.location_on_outlined),
              const SizedBox(height: 14),
              _ProfileField(controller: _city, label: 'City', icon: Icons.location_city_outlined),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 56,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: _saving
                      ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : const Text('Save profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5));
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({required this.controller, required this.label, required this.icon, this.keyboardType});
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, size: 20)),
    );
  }
}