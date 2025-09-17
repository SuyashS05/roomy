import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminSettingsPage extends StatelessWidget {
  final User user;
  const AdminSettingsPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Center(
        child: Text("⚙️ Settings for ${user.email ?? "Admin"}"),
      ),
    );
  }
}
