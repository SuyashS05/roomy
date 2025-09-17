import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:romy/splash.dart';

class VerifyEmailPage extends StatefulWidget {
  final String selectedRole;
  const VerifyEmailPage({required this.selectedRole, super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final auth = FirebaseAuth.instance;
  String? _status;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _resend() async {
    final user = auth.currentUser;
    if (user == null) return;
    try {
      setState(() => _busy = true);
      await user.sendEmailVerification();
      setState(() => _status = 'Verification email resent. Check spam too.');
    } catch (e) {
      setState(() => _status = 'Failed to resend: $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _checkVerifiedAndProceed() async {
    final user = auth.currentUser;
    if (user == null) {
      setState(() => _status = 'No user found.');
      return;
    }
    setState(() => _busy = true);
    await user.reload();
    final reloadedUser = auth.currentUser;
    if (reloadedUser != null && reloadedUser.emailVerified) {
      await _createUserDocAndGotoHome(reloadedUser);
    } else {
      setState(() => _status =
          'Email not yet verified. Please click the link in your email and then press "I have verified".');
    }
    setState(() => _busy = false);
  }

  /// 🔹 This handles Firestore transaction to generate continuous userId
  Future<int> _generateUserId() async {
    final counterRef =
        FirebaseFirestore.instance.collection("counters").doc("userId");

    return FirebaseFirestore.instance.runTransaction<int>((transaction) async {
      final snapshot = await transaction.get(counterRef);

      int currentId = snapshot.exists ? snapshot["lastUserId"] : 100000;
      int newId = currentId + 1;

      transaction.set(counterRef, {"lastUserId": newId}, SetOptions(merge: true));

      return newId;
    });
  }

  Future<void> _createUserDocAndGotoHome(User user) async {
    // ✅ Generate sequential userId
    final newUserId = await _generateUserId();

    // ✅ Get device token for push notifications
    String? deviceToken;
    try {
      deviceToken = await FirebaseMessaging.instance.getToken();
    } catch (_) {
      deviceToken = null;
    }

    // ✅ Store user in Firestore
    final doc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    await doc.set({
      'userId': newUserId, // 🔹 Sequential custom user ID
      'email': user.email,
      'role': widget.selectedRole,
      'createdAt': FieldValue.serverTimestamp(),
      'deviceToken': deviceToken,
      'displayName': user.displayName ?? '',
      'profileComplete': false, // later when profile page filled
    });

    // ✅ Go to home
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SplashScreen()),
      (route) => false,
    );
  }

  Future<void> _cancelAndDeleteAccount() async {
    final user = auth.currentUser;
    if (user == null) {
      Navigator.pop(context);
      return;
    }
    try {
      setState(() => _busy = true);
      // Delete auth user (this will remove email so user can re-register again)
      await user.delete();
      // Also remove any partial Firestore doc if created
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .delete()
          .catchError((_) {});
      setState(() =>
          _status = 'Signup canceled and temporary account deleted.');
      Navigator.popUntil(context, (route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      setState(() => _status =
          'Failed to delete account: ${e.message}. Please try again.');
    } finally {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = auth.currentUser?.email ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('Verify your email')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Text('Verification sent to: $email'),
          const SizedBox(height: 12),
          const Text(
              'Open email and click the verification link. Then come back and press "I have verified".'),
          const SizedBox(height: 12),
          if (_status != null)
            Text(_status!, style: const TextStyle(color: Colors.green)),
          const SizedBox(height: 12),
          Row(children: [
            ElevatedButton(
              onPressed: _busy ? null : _resend,
              child: _busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(),
                    )
                  : const Text('Resend'),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _busy ? null : _checkVerifiedAndProceed,
              child: const Text("I've verified"),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: _busy ? null : _cancelAndDeleteAccount,
              child: const Text('Cancel & delete account',
                  style: TextStyle(color: Colors.red)),
            ),
          ])
        ]),
      ),
    );
  }
}
