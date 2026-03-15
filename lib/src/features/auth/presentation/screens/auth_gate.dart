import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'login_screen.dart';
import '../../../home/presentation/home_shell.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> with SingleTickerProviderStateMixin {
  late final AnimationController _splashCtrl;
  late final Animation<double> _splashScale;
  late final Animation<double> _splashFade;

  @override
  void initState() {
    super.initState();
    _splashCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _splashScale = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _splashCtrl, curve: Curves.elasticOut));
    _splashFade = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _splashCtrl, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)));
    _splashCtrl.forward();
  }

  @override
  void dispose() { _splashCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.loading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F0F13),
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            FadeTransition(
              opacity: _splashFade,
              child: ScaleTransition(
                scale: _splashScale,
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)]),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [BoxShadow(color: const Color(0xFF2563EB).withValues(alpha: 0.5), blurRadius: 32, offset: const Offset(0, 12))],
                  ),
                  child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 40),
                ),
              ),
            ),
            const SizedBox(height: 40),
            const SizedBox(width: 24, height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF2563EB))),
          ]),
        ),
      );
    }

    if (auth.user == null) return const LoginScreen();
    return const HomeShell();
  }
}