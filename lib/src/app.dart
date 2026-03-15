import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/auth_gate.dart';
import 'features/cart/presentation/providers/cart_provider.dart';
import 'features/catalog/presentation/providers/products_provider.dart';
import 'features/orders/presentation/providers/orders_provider.dart';

class MiniStoreApp extends StatelessWidget {
  const MiniStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Force dark status bar icons on light backgrounds
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductsProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Mini Store',
        theme: _buildTheme(),
        home: const AuthGate(),
      ),
    );
  }

  ThemeData _buildTheme() {
    const Color primary = Color(0xFF2563EB);       // Rich blue
    const Color primaryLight = Color(0xFF3B82F6);
    const Color primaryDark = Color(0xFF1D4ED8);
    const Color surface = Color(0xFF0F0F13);       // Near black
    const Color surfaceCard = Color(0xFF1A1A24);   // Dark card
    const Color surfaceElevated = Color(0xFF22222F); // Elevated card
    const Color gold = Color(0xFFD4AF37);           // Gold accent
    const Color textPrimary = Color(0xFFF5F5F7);
    const Color textSecondary = Color(0xFF9CA3AF);
    const Color border = Color(0xFF2A2A3A);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        primaryContainer: primaryDark,
        secondary: gold,
        surface: surface,
        surfaceContainerHighest: surfaceElevated,
        onPrimary: Colors.white,
        onSurface: textPrimary,
        outline: border,
      ),
      scaffoldBackgroundColor: surface,

      // AppBar
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: surface,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: textPrimary),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        hintStyle: const TextStyle(color: textSecondary, fontSize: 15),
        labelStyle: const TextStyle(color: textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        prefixIconColor: textSecondary,
      ),

      // Filled buttons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          elevation: 0,
        ),
      ),

      // Outlined buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Bottom navigation
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceCard,
        elevation: 0,
        indicatorColor: primary.withValues(alpha: 0.2),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primary, size: 24);
          }
          return const IconThemeData(color: textSecondary, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: primary,
            );
          }
          return const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: textSecondary,
          );
        }),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black,
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: surfaceCard,
        selectedColor: primary.withValues(alpha: 0.2),
        side: const BorderSide(color: border),
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
        secondaryLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceElevated,
        contentTextStyle: const TextStyle(color: textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: border),
        ),
        elevation: 8,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),

      // Text theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, letterSpacing: -1.5),
        displayMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, letterSpacing: -1.0),
        headlineLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, letterSpacing: -0.3),
        titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: textSecondary, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: textPrimary, fontSize: 14),
        bodySmall: TextStyle(color: textSecondary, fontSize: 12),
        labelLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        labelSmall: TextStyle(color: textSecondary, fontSize: 11),
      ),

      // Icon theme
      iconTheme: const IconThemeData(color: textSecondary),
      primaryIconTheme: const IconThemeData(color: primary),
    );
  }
}