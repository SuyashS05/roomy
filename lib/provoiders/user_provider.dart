import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProvider extends ChangeNotifier {
  User? firebaseUser;
  String? role;

  Future<void> loadUser() async {
    firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(firebaseUser!.uid)
          .get();
      role = doc.data()?['role'];
    }
    notifyListeners();
  }

  void clearUser() {
    firebaseUser = null;
    role = null;
    notifyListeners();
  }
}
