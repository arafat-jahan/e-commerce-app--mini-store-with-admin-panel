import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/entities/app_user.dart';

class AuthRepository {
  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<AppUser?> getCurrentAppUser() async {
    final current = _auth.currentUser;
    if (current == null) return null;

    final doc = await _firestore.collection('users').doc(current.uid).get();
    final data = doc.data();
    final role = (data?['role'] as String?) ?? 'user';
    return AppUser(
      uid: current.uid,
      email: current.email ?? '',
      role: role,
      displayName: (data?['displayName'] as String?) ?? '',
      phone: (data?['phone'] as String?) ?? '',
      defaultAddress: (data?['defaultAddress'] as String?) ?? '',
      city: (data?['city'] as String?) ?? '',
    );
  }

  Future<void> updateUserProfile({
    required String uid,
    String? displayName,
    String? phone,
    String? defaultAddress,
    String? city,
  }) async {
    final ref = _firestore.collection('users').doc(uid);
    final Map<String, dynamic> updates = {};
    if (displayName != null) updates['displayName'] = displayName;
    if (phone != null) updates['phone'] = phone;
    if (defaultAddress != null) updates['defaultAddress'] = defaultAddress;
    if (city != null) updates['city'] = city;
    if (updates.isNotEmpty) await ref.update(updates);
  }

  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = cred.user!;
    await _ensureUserDoc(user);
    return (await getCurrentAppUser())!;
  }

  Future<AppUser> register({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = cred.user!;
    await _ensureUserDoc(user, role: 'user');
    return (await getCurrentAppUser())!;
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> _ensureUserDoc(User user, {String? role}) async {
    final ref = _firestore.collection('users').doc(user.uid);
    final snap = await ref.get();
    if (snap.exists) return;

    await ref.set({
      'email': user.email ?? '',
      'role': role ?? 'user',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

