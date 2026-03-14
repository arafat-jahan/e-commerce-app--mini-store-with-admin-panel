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

    // Show a splash/loader while Firebase is still resolving the auth state.
    // Without this the user sees LoginScreen for a brief flash on every cold
    // start even when they are already signed in.
    if (auth.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (auth.user == null) {
      return const LoginScreen();
    }

    return const HomeShell();
  }
}