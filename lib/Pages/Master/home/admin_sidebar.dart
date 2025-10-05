import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:romy/provoiders/user_details_provider.dart';

class AdminSidebar extends StatelessWidget {
  final User user;
  const AdminSidebar({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero, // ✅ ensures header fits correctly
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user.displayName ?? "Admin"),
            accountEmail: Text(user.email ?? "admin@roomy.com"),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.admin_panel_settings,
                size: 40,
                color: Colors.blue,
              ),
            ),
          ),

          // ====== MENU ITEMS ======
          _buildTile(
            context,
            Icons.analytics,
            "Analytics",
            "Analytics Page (Coming Soon)",
          ),
          _buildTile(
            context,
            Icons.report,
            "Reports",
            "Reports Page (Coming Soon)",
          ),
          _buildTile(
            context,
            Icons.payment,
            "Billing & Payments",
            "Billing Page (Coming Soon)",
          ),
          _buildTile(
            context,
            Icons.help_outline,
            "Help & Support",
            "Help Page (Coming Soon)",
          ),
          const Divider(),

          // ====== LOGOUT ======
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
            ),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              context.read<UserDetailsProvider>().clearUser();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed("/login");
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTile(
    BuildContext context,
    IconData icon,
    String title,
    String msg,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // ✅ close drawer
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar() // ✅ avoid stacking snackbars
          ..showSnackBar(SnackBar(content: Text(msg)));
      },
    );
  }
}
