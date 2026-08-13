import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_finance/data/travel_data.dart';
import 'package:my_finance/config/firebase_env_options.dart';
import 'package:my_finance/pages/homepage.dart';
import 'package:my_finance/pages/trips_page.dart';
import 'package:my_finance/utils/exceptions/exceptions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    FirebaseEnvOptions.validateOrThrow();
    await Firebase.initializeApp(options: FirebaseEnvOptions.currentPlatform);
    await FirebaseAuth.instance.signInAnonymously();
    await TravelData().init();

    runApp(const MyApp());
  } catch (e) {
    final error = AppException.from(e, origin: 'main');
    debugPrint('Erro na inicialização: $error');
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
      home: const Homepage(),
      routes: {'/trips': (context) => const TripsPage()},
    );
  }
}
