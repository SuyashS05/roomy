import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:romy/Models/Users.dart';

class UserDetailsProvider extends ChangeNotifier {
  UserModel? user;
  StreamSubscription<DocumentSnapshot>? _subscription;

  Future<void> listenToUser(User firebaseUser) async {
    _subscription?.cancel(); // stop old listener if any

    _subscription = FirebaseFirestore.instance
        .collection("users")
        .doc(firebaseUser.uid)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        user = UserModel.fromMap(doc.data()!, firebaseUser.uid, firebaseUser.email ?? '');
        notifyListeners();
      }
    });
  }

  void updateUser(UserModel newUser) {
    user = newUser;
    notifyListeners();
  }

  void clearUser() {
    user = null;
    _subscription?.cancel();
    _subscription = null;
    notifyListeners();
  }
}

