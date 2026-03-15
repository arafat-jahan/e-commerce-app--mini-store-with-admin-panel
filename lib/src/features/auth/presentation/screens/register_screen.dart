import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true, _obscureConfirm = true;

  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fade = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _slide = Tween(begin: const Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); _email.dispose(); _password.dispose(); _confirm.dispose(); super.dispose(); }

  Future<void> _register() async {
    if (_password.text != _confirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }
    final auth = context.read<AuthProvider>();
    await auth.register(_email.text.trim(), _password.text);
    if (!mounted) return;
    if (auth.error != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.error!)));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
              center: Alignment(0.3, -0.4), radius: 1.2,
              colors: [Color(0xFF0D1B3E), Color(0xFF080B14), Color(0xFF080B14)]),
        ),
        child: Stack(children: [
          Positioned(top: -60, left: -60,
              child: Container(width: 250, height: 250,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [const Color(0xFF3B82F6).withValues(alpha: 0.12), Colors.transparent])))),
          SafeArea(
            child: FadeTransition(opacity: _fade, child: SlideTransition(position: _slide,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Back
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(width: 42, height: 42,
                        decoration: BoxDecoration(color: const Color(0xFF141925), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF1E293B))),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18)),
                  ),
                  const SizedBox(height: 32),

                  Container(width: 56, height: 56,
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)]),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.4), blurRadius: 24, offset: const Offset(0, 8))]),
                      child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 28)),
                  const SizedBox(height: 24),

                  const Text('Create\naccount.', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800, height: 1.1, letterSpacing: -1.2)),
                  const SizedBox(height: 8),
                  Text('Join Mini Store today', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 15)),
                  const SizedBox(height: 40),

                  _GlassField(controller: _email, hint: 'Email address', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 14),
                  _GlassField(controller: _password, hint: 'Password', icon: Icons.lock_outline, obscure: _obscure, onToggleObscure: () => setState(() => _obscure = !_obscure)),
                  const SizedBox(height: 14),
                  _GlassField(controller: _confirm, hint: 'Confirm password', icon: Icons.lock_outline, obscure: _obscureConfirm,
                      onToggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm), onSubmitted: (_) => _register()),
                  const SizedBox(height: 32),

                  _GlowButton(onTap: auth.loading ? null : _register, loading: auth.loading, label: 'Create account', icon: Icons.arrow_forward_rounded),
                  const SizedBox(height: 24),

                  Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('Already have an account?  ', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 15)),
                    GestureDetector(onTap: () => Navigator.of(context).pop(),
                        child: const Text('Sign in', style: TextStyle(color: Color(0xFF3B82F6), fontSize: 15, fontWeight: FontWeight.w700))),
                  ])),
                ]),
              ),
            )),
          ),
        ]),
      ),
    );
  }
}

class _GlassField extends StatelessWidget {
  const _GlassField({required this.controller, required this.hint, required this.icon,
    this.keyboardType, this.obscure = false, this.onToggleObscure, this.onSubmitted});
  final TextEditingController controller; final String hint; final IconData icon;
  final TextInputType? keyboardType; final bool obscure;
  final VoidCallback? onToggleObscure; final void Function(String)? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF141925), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF1E293B))),
      child: TextField(
        controller: controller, keyboardType: keyboardType, obscureText: obscure, onSubmitted: onSubmitted,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
            hintText: hint, hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.25)),
            prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.3), size: 20),
            suffixIcon: onToggleObscure != null ? IconButton(
                icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white.withValues(alpha: 0.3), size: 20),
                onPressed: onToggleObscure) : null,
            border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18), filled: false),
      ),
    );
  }
}

class _GlowButton extends StatefulWidget {
  const _GlowButton({this.onTap, this.loading = false, required this.label, required this.icon});
  final VoidCallback? onTap; final bool loading; final String label; final IconData icon;
  @override
  State<_GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<_GlowButton> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override
  void initState() { super.initState(); _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120), lowerBound: 0.95, upperBound: 1.0, value: 1.0); }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) { if (widget.onTap != null) _ctrl.reverse(); },
      onTapUp: (_) { _ctrl.forward(); widget.onTap?.call(); },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(scale: _ctrl,
        child: Container(
          width: double.infinity, height: 58,
          decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.5), blurRadius: 24, offset: const Offset(0, 8))]),
          child: widget.loading
              ? const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)))
              : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(widget.label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            Icon(widget.icon, color: Colors.white, size: 18),
          ]),
        ),
      ),
    );
  }
}