import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/auth_repository.dart';
import '../../domain/entities/app_user.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthRepository? repo}) : _repo = repo ?? AuthRepository() {
    // Resolve current user once on startup before listening for changes.
    _initialLoad();
  }

  final AuthRepository _repo;
  StreamSubscription<User?>? _sub;

  AppUser? _user;
  AppUser? get user => _user;

  /// True only during the very first auth-state resolution.
  /// AuthGate uses this to show a splash instead of LoginScreen.
  bool _loading = true;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  Future<void> _initialLoad() async {
    _error = null;
    try {
      _user = await _repo.getCurrentAppUser();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }

    // Now subscribe to ongoing auth-state changes (sign-in / sign-out).
    _sub = _repo.authStateChanges().listen((_) async {
      await refreshProfile();
    });
  }

  Future<void> refreshProfile() async {
    _error = null;
    try {
      _user = await _repo.getCurrentAppUser();
    } catch (e) {
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    await _run(() async {
      _user = await _repo.signIn(email: email, password: password);
    });
  }

  Future<void> register(String email, String password) async {
    await _run(() async {
      _user = await _repo.register(email: email, password: password);
    });
  }

  Future<void> signOut() async {
    await _run(() async {
      await _repo.signOut();
      _user = null;
    });
  }

  Future<void> updateProfile({
    String? displayName,
    String? phone,
    String? defaultAddress,
    String? city,
  }) async {
    final uid = _user?.uid;
    if (uid == null) return;
    await _repo.updateUserProfile(
      uid: uid,
      displayName: displayName,
      phone: phone,
      defaultAddress: defaultAddress,
      city: city,
    );
    await refreshProfile();
  }

  Future<void> _run(Future<void> Function() fn) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await fn();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}