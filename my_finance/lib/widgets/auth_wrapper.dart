import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_finance/data/travel_data.dart';
import 'package:my_finance/pages/homepage.dart';
import 'package:my_finance/pages/login_page.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  String? _initializedUid;

  Future<void> _initSessionData(User user) async {
    if (_initializedUid == user.uid) return;

    await TravelData().init();
    _initializedUid = user.uid;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final user = snapshot.data;
        if (user != null) {
          _initSessionData(user);
          return const Homepage();
        }

        _initializedUid = null;
        return const LoginPage();
      },
    );
  }
}
