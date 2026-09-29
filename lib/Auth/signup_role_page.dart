import 'package:flutter/material.dart';
import 'signup_form_page.dart';

class SignupRolePage extends StatelessWidget {
  const SignupRolePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF74ABE2), Color(0xFF5563DE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              color: Colors.white.withOpacity(0.95),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Hero(
                      tag: 'app_logo',
                      child: Image.asset(
                        'assets/Logo.png',
                        height: 100,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Signup - Choose Role',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3C4F9A),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Choose your role to continue:',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 28),
                    const RoleButton(
                      role: 'user',
                      label: 'App User (Room Seeker)',
                      icon: Icons.person_outline,
                      color: Color(0xFF4A90E2),
                    ),
                    const RoleButton(
                      role: 'roomOwner',
                      label: 'Room / PG Owner',
                      icon: Icons.home_outlined,
                      color: Color(0xFF5563DE),
                    ),
                    // const RoleButton(
                    //   role: 'admin',
                    //   label: 'Admin (App Controller)',
                    //   icon: Icons.admin_panel_settings_outlined,
                    //   color: Colors.deepPurple,
                    // ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        '← Back to Login',
                        style: TextStyle(
                          color: Color(0xFF3C4F9A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RoleButton extends StatelessWidget {
  final String role;
  final String label;
  final IconData icon;
  final Color color;

  const RoleButton({
    required this.role,
    required this.label,
    required this.icon,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SignupFormPage(selectedRole: role),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: Icon(icon, size: 22, color: Colors.white),
          label: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
