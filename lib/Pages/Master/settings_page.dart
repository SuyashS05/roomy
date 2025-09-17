import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:romy/Pages/Master/admin_profile_manager.dart';

class SettingsPage extends StatelessWidget {
  final User user;
  const SettingsPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Settings",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // 🔹 Profile management
          ListTile(
            leading: const Icon(Icons.person, color: Colors.blue),
            title: const Text("Profile Management"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminProfileManager(),
                ),
              );
            },
          ),

          const Divider(),

          // 🔹 Theme (dark/light)
          ListTile(
            leading: const Icon(Icons.brightness_6, color: Colors.orange),
            title: const Text("Theme"),
            subtitle: const Text("Light / Dark"),
            trailing: Switch(
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: (val) {
                // TODO: Add theme toggle logic
              },
            ),
          ),

          const Divider(),

          // 🔹 Notifications
          ListTile(
            leading: const Icon(Icons.notifications, color: Colors.red),
            title: const Text("Notifications"),
            subtitle: const Text("Enable/Disable alerts"),
            trailing: Switch(
              value: true,
              onChanged: (val) {
                // TODO: Save notification preference
              },
            ),
          ),

          const Divider(),

          // 🔹 About App
          ListTile(
            leading: const Icon(Icons.info, color: Colors.teal),
            title: const Text("About Roomy"),
            subtitle: const Text("Version 1.0.0"),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "Roomy",
                applicationVersion: "1.0.0",
                applicationIcon: const Icon(Icons.home, size: 40),
                children: [
                  const Text(
                      "Roomy is a platform for connecting room seekers and owners. "
                      "Admins can manage users, reports, and platform-wide settings."),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
