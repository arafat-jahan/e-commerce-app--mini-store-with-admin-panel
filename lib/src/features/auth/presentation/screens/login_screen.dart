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

  late final AnimationController _masterCtrl;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _field1Slide;
  late final Animation<double> _field1Fade;
  late final Animation<Offset> _field2Slide;
  late final Animation<double> _field2Fade;
  late final Animation<Offset> _btnSlide;
  late final Animation<double> _btnFade;

  @override
  void initState() {
    super.initState();
    _masterCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

    _logoScale = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _masterCtrl, curve: const Interval(0.0, 0.35, curve: Curves.elasticOut)));
    _logoFade = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _masterCtrl, curve: const Interval(0.0, 0.25, curve: Curves.easeOut)));

    _titleSlide = Tween(begin: const Offset(0, 0.5), end: Offset.zero).animate(
        CurvedAnimation(parent: _masterCtrl, curve: const Interval(0.2, 0.5, curve: Curves.easeOutCubic)));
    _titleFade = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _masterCtrl, curve: const Interval(0.2, 0.5, curve: Curves.easeOut)));

    _field1Slide = Tween(begin: const Offset(0, 0.4), end: Offset.zero).animate(
        CurvedAnimation(parent: _masterCtrl, curve: const Interval(0.35, 0.65, curve: Curves.easeOutCubic)));
    _field1Fade = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _masterCtrl, curve: const Interval(0.35, 0.65, curve: Curves.easeOut)));

    _field2Slide = Tween(begin: const Offset(0, 0.4), end: Offset.zero).animate(
        CurvedAnimation(parent: _masterCtrl, curve: const Interval(0.45, 0.75, curve: Curves.easeOutCubic)));
    _field2Fade = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _masterCtrl, curve: const Interval(0.45, 0.75, curve: Curves.easeOut)));

    _btnSlide = Tween(begin: const Offset(0, 0.5), end: Offset.zero).animate(
        CurvedAnimation(parent: _masterCtrl, curve: const Interval(0.6, 0.9, curve: Curves.easeOutCubic)));
    _btnFade = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _masterCtrl, curve: const Interval(0.6, 0.9, curve: Curves.easeOut)));

    _masterCtrl.forward();
  }

  @override
  void dispose() {
    _masterCtrl.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final auth = context.read<AuthProvider>();
    await auth.signIn(_email.text.trim(), _password.text);
    if (!mounted) return;
    if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF0F0F13), Color(0xFF0D1B2A), Color(0xFF0F0F13)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),

                // Animated logo
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)]),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [BoxShadow(color: const Color(0xFF2563EB).withValues(alpha: 0.5), blurRadius: 24, offset: const Offset(0, 8))],
                      ),
                      child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 32),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Animated title
                FadeTransition(
                  opacity: _titleFade,
                  child: SlideTransition(
                    position: _titleSlide,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Welcome\nback',
                            style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800, height: 1.1, letterSpacing: -1)),
                        const SizedBox(height: 8),
                        Text('Sign in to continue shopping',
                            style: TextStyle(color: Colors.grey[500], fontSize: 15)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // Email field
                FadeTransition(
                  opacity: _field1Fade,
                  child: SlideTransition(
                    position: _field1Slide,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Label('EMAIL ADDRESS'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(hintText: 'you@example.com', prefixIcon: Icon(Icons.email_outlined)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Password field
                FadeTransition(
                  opacity: _field2Fade,
                  child: SlideTransition(
                    position: _field2Slide,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Label('PASSWORD'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _password,
                          obscureText: _obscure,
                          style: const TextStyle(color: Colors.white),
                          onSubmitted: (_) => _signIn(),
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey[600]),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // Button
                FadeTransition(
                  opacity: _btnFade,
                  child: SlideTransition(
                    position: _btnSlide,
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity, height: 56,
                          child: FilledButton(
                            onPressed: auth.loading ? null : _signIn,
                            style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                            child: auth.loading
                                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                                : const Text('Sign in', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text('New here? ', style: TextStyle(color: Colors.grey[500], fontSize: 15)),
                          GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder: (_, anim, __) => FadeTransition(opacity: anim, child: const RegisterScreen()),
                                transitionDuration: const Duration(milliseconds: 400),
                              ),
                            ),
                            child: const Text('Create an account',
                                style: TextStyle(color: Color(0xFF2563EB), fontSize: 15, fontWeight: FontWeight.w700)),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5));
  }
}