import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_finance/models/user.dart';

abstract class UserStore {
  Future<AppUser?> getUser(String uid);

  Future<void> saveUser(AppUser user);
}

class FirestoreUserStore implements UserStore {
  final FirebaseFirestore _firestore;

  FirestoreUserStore([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<AppUser?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.data()!);
  }

  @override
  Future<void> saveUser(AppUser user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }
}

class AuthService extends ChangeNotifier {
  static AuthService? _shared;

  static AuthService getShared() {
    _shared ??= AuthService();
    return _shared!;
  }

  final FirebaseAuth _auth;
  final UserStore _userStore;

  User? get firebaseUser => _auth.currentUser;
  AppUser? _appUser;

  AppUser? get appUser => _appUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  AuthService({FirebaseAuth? auth, UserStore? userStore})
      : _auth = auth ?? FirebaseAuth.instance,
        _userStore = userStore ?? FirestoreUserStore() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    if (user != null) {
      final dbUser = await _userStore.getUser(user.uid);
      if (dbUser != null) {
        _appUser = dbUser;
      } else {
        _appUser = AppUser.fromFirebase(user);
      }
    } else {
      _appUser = null;
    }
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user?.updateDisplayName(name);

    final appUser = AppUser(
      uid: credential.user!.uid,
      name: name,
      email: email,
    );

    await _userStore.saveUser(appUser);
  }

  Future<void> updateProfile({required String name}) async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return;

    await firebaseUser.updateDisplayName(name);

    final current = _appUser ?? AppUser.fromFirebase(firebaseUser);
    final updated = AppUser(
      uid: current.uid,
      name: name,
      email: current.email,
    );

    await _userStore.saveUser(updated);
    _appUser = updated;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _appUser = null;
    notifyListeners();
  }
}
