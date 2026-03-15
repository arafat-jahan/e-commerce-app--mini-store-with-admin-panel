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
  late TextEditingController _displayName, _phone, _address, _city;
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
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fade = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _slide = Tween(begin: const Offset(0, 0.15), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); _displayName.dispose(); _phone.dispose(); _address.dispose(); _city.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await context.read<AuthProvider>().updateProfile(
          displayName: _displayName.text.trim(), phone: _phone.text.trim(),
          defaultAddress: _address.text.trim(), city: _city.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Profile saved!')));
    } finally { if (mounted) setState(() => _saving = false); }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) return const Center(child: Text('Not signed in', style: TextStyle(color: Colors.white)));

    return FadeTransition(opacity: _fade, child: SlideTransition(position: _slide,
        child: ListView(padding: const EdgeInsets.all(20), children: [
          // Profile card
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.85, end: 1.0),
            duration: const Duration(milliseconds: 600), curve: Curves.easeOutCubic,
            builder: (_, v, child) => Transform.scale(scale: v, child: child),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [const Color(0xFF141925), const Color(0xFF0D1B3E).withValues(alpha: 0.8)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFF1E293B)),
                  boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.08), blurRadius: 30, offset: const Offset(0, 8))]),
              child: Row(children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 700), curve: Curves.elasticOut,
                  builder: (_, v, child) => Transform.scale(scale: v, child: child),
                  child: Container(width: 64, height: 64,
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)]),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.5), blurRadius: 20, offset: const Offset(0, 6))]),
                      child: Center(child: Text(
                          user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : user.email[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)))),
                ),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(user.displayName.isNotEmpty ? user.displayName : 'No name set',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(user.email, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13)),
                  const SizedBox(height: 8),
                  Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          gradient: user.isAdmin
                              ? LinearGradient(colors: [const Color(0xFFD4AF37).withValues(alpha: 0.2), const Color(0xFFD4AF37).withValues(alpha: 0.05)])
                              : LinearGradient(colors: [const Color(0xFF3B82F6).withValues(alpha: 0.2), const Color(0xFF3B82F6).withValues(alpha: 0.05)]),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: user.isAdmin ? const Color(0xFFD4AF37).withValues(alpha: 0.3) : const Color(0xFF3B82F6).withValues(alpha: 0.3))),
                      child: Text(user.isAdmin ? '👑 Admin' : '👤 Customer',
                          style: TextStyle(color: user.isAdmin ? const Color(0xFFD4AF37) : const Color(0xFF3B82F6), fontSize: 12, fontWeight: FontWeight.w700))),
                ])),
              ]),
            ),
          ),
          const SizedBox(height: 28),
          Text('PERSONAL INFO', style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
          const SizedBox(height: 14),
          Form(key: _formKey, child: Column(children: [
            ...[
              (_displayName, 'Display name', Icons.person_outline_rounded, TextInputType.text),
              (_phone, 'Phone number', Icons.phone_outlined, TextInputType.phone),
              (_address, 'Default address', Icons.location_on_outlined, TextInputType.text),
              (_city, 'City', Icons.location_city_outlined, TextInputType.text),
            ].asMap().entries.map((e) {
              final i = e.key; final (ctrl, label, icon, type) = e.value;
              return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 350 + (i * 70)), curve: Curves.easeOutCubic,
                  builder: (_, v, child) => Opacity(opacity: v.clamp(0.0, 1.0),
                      child: Transform.translate(offset: Offset((1-v)*30, 0), child: child)),
                  child: Padding(padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                          decoration: BoxDecoration(color: const Color(0xFF141925), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF1E293B))),
                          child: TextFormField(controller: ctrl, keyboardType: type,
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                              decoration: InputDecoration(
                                  labelText: label, labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                                  prefixIcon: Icon(icon, size: 20, color: Colors.white.withValues(alpha: 0.25)),
                                  border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), filled: false)))));
            }),
            const SizedBox(height: 8),
            GestureDetector(
                onTap: _saving ? null : _save,
                child: Container(width: double.infinity, height: 58,
                    decoration: BoxDecoration(
                        gradient: _saving ? null : const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)]),
                        color: _saving ? const Color(0xFF141925) : null,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: _saving ? [] : [BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.4), blurRadius: 24, offset: const Offset(0, 8))]),
                    child: _saving
                        ? const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)))
                        : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.save_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      Text('Save profile', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                    ]))),
          ])),
        ])));
  }
}