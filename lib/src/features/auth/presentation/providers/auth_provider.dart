import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/auth_repository.dart';
import '../../domain/entities/app_user.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthRepository? repo}) : _repo = repo ?? AuthRepository() {
    _sub = _repo.authStateChanges().listen((_) async {
      await refreshProfile();
    });
    refreshProfile();
  }

  final AuthRepository _repo;
  late final Stream<User?> _authStream = _repo.authStateChanges();
  Stream<User?> get authStream => _authStream;

  AppUser? _user;
  AppUser? get user => _user;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  late final StreamSubscription<User?> _sub;

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
    _sub.cancel();
    super.dispose();
  }
}

