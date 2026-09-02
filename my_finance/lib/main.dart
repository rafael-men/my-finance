import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_finance/config/firebase_env_options.dart';
import 'package:my_finance/pages/trips_page.dart';
import 'package:my_finance/widgets/auth_wrapper.dart';

const bool _kUseEmulators = bool.fromEnvironment('USE_FIREBASE_EMULATORS');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    FirebaseEnvOptions.validateOrThrow();
    await Firebase.initializeApp(options: FirebaseEnvOptions.currentPlatform);

    if (_kUseEmulators) {
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
      FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
      debugPrint('Usando Firebase Emulators (auth:9099, firestore:8080).');
    }

    runApp(const MyApp());
  } catch (e, stackTrace) {
    debugPrint('Erro na inicialização: $e');
    debugPrint('Stack trace: $stackTrace');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'Erro ao inicializar o aplicativo.\nVerifique sua conexão e tente novamente.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
      routes: {'/trips': (context) => const TripsPage()},
    );
  }
}
