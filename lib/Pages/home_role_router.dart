import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:romy/pages/user/home/seeker_home.dart';
import 'package:romy/pages/PgOwner/home/owner_home.dart';
import 'package:romy/pages/Master/home/admin_home.dart';
import 'package:romy/provoiders/user_provider.dart';

class HomeRoleRouter extends StatelessWidget {
  const HomeRoleRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.firebaseUser;
    final role = userProvider.role;

    // 1️⃣ Ensure user is logged in
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("No user logged in")),
      );
    }

    // 2️⃣ Ensure role is loaded
    if (role == null || role.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 3️⃣ Route based on role safely
    switch (role) {
      case "user":
        return SeekerHome(user: user);
      case "roomOwner":
        return OwnerHome(user: user);
      case "admin":
      case "master":
        return AdminHome(user: user);
      default:
        return const Scaffold(
          body: Center(child: Text("No valid role assigned")),
        );
    }
  }
}
