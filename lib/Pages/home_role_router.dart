import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:romy/pages/user/home/seeker_home.dart';
import 'package:romy/pages/PgOwner/home/owner_home.dart';
import 'package:romy/pages/Master/home/admin_home.dart';

class HomeRoleRouter extends StatefulWidget {
  const HomeRoleRouter({super.key});

  @override
  State<HomeRoleRouter> createState() => _HomeRoleRouterState();
}

class _HomeRoleRouterState extends State<HomeRoleRouter> {
  String? role;
  User? user;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => loading = false);
      return;
    }

    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .get();
      if (doc.exists && doc.data()!.containsKey('role')) {
        role = doc['role'] as String?;
      }
    } catch (e) {
      debugPrint("Error loading role: $e");
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (role == "user") return SeekerHome(user: user!);
    if (role == "roomOwner") return OwnerHome(user: user!);
    if (role == "admin" || role == "master") return AdminHome(user: user!);

    return const Scaffold(body: Center(child: Text("No role assigned")));
  }
}
