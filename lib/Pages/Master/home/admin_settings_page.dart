import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:romy/Pages/Master/Manage/AppImageManager.dart';
import 'package:romy/Pages/Master/Manage/admin_profile_manager.dart';
import 'package:romy/provoiders/user_details_provider.dart';

class AdminSettingsPage extends StatelessWidget {
  const AdminSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
      final user = context.watch<UserDetailsProvider>().user;
    return Scaffold(
      appBar: AppBar(title: const Text("Manage App")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // 🔹 Profile management
          ListTile(
            leading: const Icon(Icons.person, color: Colors.blue),
            title: const Text("Profile image Management"),
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

          ListTile(
            leading: const Icon(Icons.image_outlined, color:Colors.orange),
            title: const Text("App Image Management"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminAppImageManager(),
                ),
              );
            },
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
        ]
      ),
    );
  }
}
