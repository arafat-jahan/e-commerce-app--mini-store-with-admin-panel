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

class _AuthGateState extends State<AuthGate> with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);

    _logoScale = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoFade = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _logoCtrl, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)));
    _pulse = Tween(begin: 0.95, end: 1.05).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _logoCtrl.forward();
  }

  @override
  void dispose() { _logoCtrl.dispose(); _pulseCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.loading) {
      return Scaffold(
        backgroundColor: const Color(0xFF080B14),
        body: Container(
          decoration: const BoxDecoration(
              gradient: RadialGradient(center: Alignment.center, radius: 1.0,
                  colors: [Color(0xFF0D1B3E), Color(0xFF080B14)])),
          child: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              FadeTransition(opacity: _logoFade,
                  child: ScaleTransition(scale: _logoScale,
                      child: ScaleTransition(scale: _pulse,
                          child: Container(width: 90, height: 90,
                              decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.6), blurRadius: 40, offset: const Offset(0, 12)),
                                    BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.2), blurRadius: 80, spreadRadius: 20),
                                  ]),
                              child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 44))))),
              const SizedBox(height: 16),
              FadeTransition(opacity: _logoFade,
                  child: const Text('MINI STORE',
                      style: TextStyle(color: Color(0xFF3B82F6), fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 4))),
              const SizedBox(height: 48),
              SizedBox(width: 28, height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: const Color(0xFF3B82F6).withValues(alpha: 0.6))),
            ]),
          ),
        ),
      );
    }

    if (auth.user == null) return const LoginScreen();
    return const HomeShell();
  }
}