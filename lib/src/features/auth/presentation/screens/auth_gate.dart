import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'login_screen.dart';
import '../../../home/presentation/home_shell.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F0F13),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              SizedBox(
                width: 64, height: 64,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)]),
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                  ),
                  child: Icon(Icons.storefront_rounded, color: Colors.white, size: 32),
                ),
              ),
              SizedBox(height: 32),
              SizedBox(
                width: 24, height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Color(0xFF2563EB),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (auth.user == null) {
      return const LoginScreen();
    }

    return const HomeShell();
  }
}