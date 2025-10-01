import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:romy/splash.dart';
import 'signup_role_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  String? _error;
  bool _loading = false;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _pass.text.trim(),
      );
      final user = cred.user;

      if (user == null) throw Exception('No user');
      if (!user.emailVerified) {
        await user.sendEmailVerification();
        setState(() => _error = 'email_not_verified'.tr() + ' ' + 'check_inbox'.tr());
        await FirebaseAuth.instance.signOut();
      } else {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SplashScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'unexpected_error'.tr());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const FlutterLogo(size: 120),
              const SizedBox(height: 24),
              Text(
                'Roomy',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'login'.tr(),
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _email,
                decoration: InputDecoration(
                  labelText: 'email'.tr(),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _pass,
                decoration: InputDecoration(
                  labelText: 'password'.tr(),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('login'.tr(), style: const TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupRolePage()));
                },
                child: Text('create_account'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:romy/splash.dart';
// import 'signup_role_page.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});
//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final _email = TextEditingController();
//   final _pass = TextEditingController();
//   String? _error;
//   bool _loading = false;

//   Future<void> _login() async {
//     setState(() { _loading = true; _error = null;});
//     try {
//       final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: _email.text.trim(), password: _pass.text.trim());
//       final user = cred.user;
//       if (user == null) throw Exception('No user');
//       if (!user.emailVerified) {
//         await user.sendEmailVerification();
//         setState(() => _error = 'Email not verified. Sent verification mail. Check inbox/spam.');
//         await FirebaseAuth.instance.signOut();
//       } else {
//         // proceed to home
//         if (!mounted) return;
//         Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SplashScreen()));
//       }
//     } on FirebaseAuthException catch (e) {
//       setState(() => _error = e.message);
//     } catch (e) {
//       setState(() => _error = 'Unexpected error');
//     } finally { setState(() => _loading = false); }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Roomy - Login')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(children: [
//           TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
//           TextField(controller: _pass, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
//           const SizedBox(height:12),
//           if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
//           const SizedBox(height:12),
//           ElevatedButton(onPressed: _loading ? null : _login, child: _loading ? const CircularProgressIndicator() : const Text('Login')),
//           TextButton(onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupRolePage())); }, child: const Text('Create account')),
//         ]),
//       ),
//     );
//   }
// }
