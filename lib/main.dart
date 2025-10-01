import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:romy/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:romy/provoiders/locale_provider.dart';
import 'package:romy/provoiders/theme_provider.dart';
import 'package:romy/provoiders/user_details_provider.dart';
import 'package:romy/provoiders/user_provider.dart';
import 'Auth/login_page.dart';
import 'Auth/signup_role_page.dart';
import 'splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('hi'), Locale('mr')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ChangeNotifierProvider(create: (_) => UserDetailsProvider()),
          ChangeNotifierProvider(create: (_) => UserProvider()..loadUser()),
        ],
        child: const RoomyApp(),
      ),
    ),
  );
}

class RoomyApp extends StatelessWidget {
  const RoomyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp(
      title: 'Roomy',
      themeMode: themeProvider.themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      locale: localeProvider.locale,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
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
    final userProvider = context.watch<UserProvider>();
    final userDetailsProvider = context.read<UserDetailsProvider>();
    final user = userProvider.firebaseUser;

    if (user == null) {
      return const LoginPage();
    }

    if (!user.emailVerified) {
      return const LoginPage();
    }

    // 🔹 Start listening to Firestore for user details
    userDetailsProvider.listenToUser(user);

    return const SplashScreen(); // Splash handles role + navigation
  }
}

