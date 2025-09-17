import 'package:flutter/material.dart';
import 'signup_form_page.dart';

class SignupRolePage extends StatelessWidget {
  const SignupRolePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Signup - Choose Role')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Choose your role:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            RoleButton(role: 'user', label: 'App User (room seeker)'),
            RoleButton(role: 'roomOwner', label: 'Room / PG Owner'),
            RoleButton(role: 'admin', label: 'Admin (app controller)'),
          ],
        ),
      ),
    );
  }
}

class RoleButton extends StatelessWidget {
  final String role;
  final String label;
  const RoleButton({required this.role, required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical:8.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SignupFormPage(selectedRole: role)),
          );
        },
        child: Text(label),
      ),
    );
  }
}
