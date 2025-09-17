import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:romy/firebase_options.dart';
import 'package:romy/Auth/login_page.dart';
import 'package:romy/Auth/signup_role_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:romy/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const RoomyApp());
}

class RoomyApp extends StatelessWidget {
  const RoomyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roomy',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const Root(),
      routes: {
        '/login': (_) => const LoginPage(),
        '/signup-role': (_) => const SignupRolePage(),
      },
    );
  }
}

class Root extends StatelessWidget {
  const Root({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.emailVerified) {
      return const SplashScreen(); // handles role + splash
    } else {
      return const LoginPage();
    }
  }
}
