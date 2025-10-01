import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProvider extends ChangeNotifier {
  User? firebaseUser;
  String? role;
  Stream<User?>? _authStream;

  UserProvider() {
    // Listen to FirebaseAuth changes
    _authStream = FirebaseAuth.instance.authStateChanges();
    _authStream!.listen((user) async {
      firebaseUser = user;
      if (user != null) {
        await _loadUserRole(user);
      } else {
        role = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserRole(User user) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      role = doc.data()?['role'];
    } catch (e) {
      role = null;
    }
  }

  void clearUser() {
    firebaseUser = null;
    role = null;
    notifyListeners();
  }
}
