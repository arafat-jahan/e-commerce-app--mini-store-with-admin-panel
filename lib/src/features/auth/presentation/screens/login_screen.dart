import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  late final AnimationController _ctrl;
  late final List<Animation<double>> _fades;
  late final List<Animation<Offset>> _slides;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    final intervals = [
      [0.0, 0.3], [0.15, 0.45], [0.3, 0.6], [0.45, 0.75], [0.6, 0.9],
    ];
    _fades = intervals.map((i) => Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Interval(i[0], i[1], curve: Curves.easeOut)))).toList();
    _slides = intervals.map((i) => Tween(begin: const Offset(0, 0.4), end: Offset.zero).animate(
        CurvedAnimation(parent: _ctrl, curve: Interval(i[0], i[1], curve: Curves.easeOutCubic)))).toList();
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); _email.dispose(); _password.dispose(); super.dispose(); }

  Widget _animated(int i, Widget child) => FadeTransition(opacity: _fades[i], child: SlideTransition(position: _slides[i], child: child));

  Future<void> _signIn() async {
    final auth = context.read<AuthProvider>();
    await auth.signIn(_email.text.trim(), _password.text);
    if (!mounted) return;
    if (auth.error != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.error!)));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.3, -0.5), radius: 1.2,
            colors: [Color(0xFF0D1B3E), Color(0xFF080B14), Color(0xFF080B14)],
          ),
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(top: -80, right: -80,
                child: Container(width: 280, height: 280,
                    decoration: BoxDecoration(shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [const Color(0xFF3B82F6).withValues(alpha: 0.15), Colors.transparent])))),
            Positioned(bottom: -100, left: -60,
                child: Container(width: 250, height: 250,
                    decoration: BoxDecoration(shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [const Color(0xFF6366F1).withValues(alpha: 0.1), Colors.transparent])))),

            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(28, size.height * 0.06, 28, 28),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Logo
                  _animated(0, Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(width: 60, height: 60,
                        decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.5), blurRadius: 30, offset: const Offset(0, 10)),
                              BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.2), blurRadius: 60, spreadRadius: 10),
                            ]),
                        child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 30)),
                    const SizedBox(height: 10),
                    const Text('MINI STORE',
                        style: TextStyle(color: Color(0xFF3B82F6), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 3)),
                  ])),
                  const SizedBox(height: 36),

                  // Title
                  _animated(1, Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Welcome\nback.', style: TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w800, height: 1.05, letterSpacing: -1.5)),
                    const SizedBox(height: 10),
                    Text('Sign in to your account', style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 16)),
                  ])),
                  const SizedBox(height: 44),

                  // Fields
                  _animated(2, Column(children: [
                    _GlassField(controller: _email, hint: 'Email address', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 14),
                    _GlassField(controller: _password, hint: 'Password', icon: Icons.lock_outline,
                        obscure: _obscure, onToggleObscure: () => setState(() => _obscure = !_obscure),
                        onSubmitted: (_) => _signIn()),
                  ])),
                  const SizedBox(height: 32),

                  // Button
                  _animated(3, _GlowButton(
                    onTap: auth.loading ? null : _signIn,
                    loading: auth.loading,
                    label: 'Sign in',
                    icon: Icons.arrow_forward_rounded,
                  )),
                  const SizedBox(height: 28),

                  // Register link
                  _animated(4, Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('New here?  ', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 15)),
                    GestureDetector(
                        onTap: () => Navigator.of(context).push(PageRouteBuilder(
                            pageBuilder: (_, anim, __) => FadeTransition(opacity: anim, child: const RegisterScreen()),
                            transitionDuration: const Duration(milliseconds: 400))),
                        child: const Text('Create account', style: TextStyle(color: Color(0xFF3B82F6), fontSize: 15, fontWeight: FontWeight.w700))),
                  ]))),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassField extends StatelessWidget {
  const _GlassField({required this.controller, required this.hint, required this.icon,
    this.keyboardType, this.obscure = false, this.onToggleObscure, this.onSubmitted});
  final TextEditingController controller;
  final String hint; final IconData icon;
  final TextInputType? keyboardType;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final void Function(String)? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141925),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscure,
        onSubmitted: onSubmitted,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.25)),
          prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.3), size: 20),
          suffixIcon: onToggleObscure != null ? IconButton(
              icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: Colors.white.withValues(alpha: 0.3), size: 20),
              onPressed: onToggleObscure) : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          filled: false,
        ),
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
              boxShadow: [
                BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.5), blurRadius: 24, offset: const Offset(0, 8)),
                BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.2), blurRadius: 48, spreadRadius: 4),
              ]),
          child: widget.loading
              ? const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)))
              : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(widget.label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
            const SizedBox(width: 8),
            Icon(widget.icon, color: Colors.white, size: 18),
          ]),
        ),
      ),
    );
  }
}