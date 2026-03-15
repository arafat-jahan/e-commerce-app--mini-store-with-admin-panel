import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayName;
  late TextEditingController _phone;
  late TextEditingController _address;
  late TextEditingController _city;
  bool _saving = false;

  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _displayName = TextEditingController(text: user?.displayName ?? '');
    _phone = TextEditingController(text: user?.phone ?? '');
    _address = TextEditingController(text: user?.defaultAddress ?? '');
    _city = TextEditingController(text: user?.city ?? '');

    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fade = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _slide = Tween(begin: const Offset(0, 0.2), end: Offset.zero).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
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
          city: _city.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Profile saved successfully')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) return const Center(child: Text('Not signed in', style: TextStyle(color: Colors.white)));

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Profile header
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              builder: (_, v, child) => Transform.scale(scale: v, child: child),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF1A1A24), Color(0xFF0D1B2A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF2A2A3A)),
                ),
                child: Row(children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.elasticOut,
                    builder: (_, v, child) => Transform.scale(scale: v, child: child),
                    child: Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)]),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: const Color(0xFF2563EB).withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6))]),
                      child: Center(child: Text(
                          user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : user.email[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800))),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(user.displayName.isNotEmpty ? user.displayName : 'No name set',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(user.email, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
                    const SizedBox(height: 6),
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: user.isAdmin ? const Color(0xFFD4AF37).withValues(alpha: 0.15) : const Color(0xFF2563EB).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: user.isAdmin ? const Color(0xFFD4AF37).withValues(alpha: 0.4) : const Color(0xFF2563EB).withValues(alpha: 0.4))),
                        child: Text(user.isAdmin ? '👑 Admin' : '👤 Customer',
                            style: TextStyle(color: user.isAdmin ? const Color(0xFFD4AF37) : const Color(0xFF2563EB), fontSize: 12, fontWeight: FontWeight.w700))),
                  ])),
                ]),
              ),
            ),
            const SizedBox(height: 28),

            const Text('PERSONAL INFO',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
            const SizedBox(height: 12),

            Form(
              key: _formKey,
              child: Column(children: [
                ...[
                  (_displayName, 'Display name', Icons.person_outline_rounded, TextInputType.text),
                  (_phone, 'Phone number', Icons.phone_outlined, TextInputType.phone),
                  (_address, 'Default address', Icons.location_on_outlined, TextInputType.text),
                  (_city, 'City', Icons.location_city_outlined, TextInputType.text),
                ].asMap().entries.map((entry) {
                  final i = entry.key;
                  final (ctrl, label, icon, type) = entry.value;
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 400 + (i * 80)),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, child) => Opacity(opacity: v.clamp(0.0, 1.0),
                        child: Transform.translate(offset: Offset((1 - v) * 30, 0), child: child)),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: TextFormField(
                        controller: ctrl,
                        keyboardType: type,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, size: 20)),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity, height: 56,
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    child: _saving
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                        : const Text('Save profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}