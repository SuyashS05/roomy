import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:romy/Pages/Master/home/admin_settings_page.dart';
import 'package:romy/provoiders/locale_provider.dart';
import 'package:romy/provoiders/user_details_provider.dart';
import 'package:romy/Auth/profile_page.dart';

class AdminProfilePage extends StatelessWidget {
  const AdminProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userDetailsProvider = context.watch<UserDetailsProvider>();
    final userModel = userDetailsProvider.user;
    final localeProvider = context.watch<LocaleProvider>();
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (userModel == null || firebaseUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final profileUrl =
        (userModel.profileUrl?.isNotEmpty == true)
            ? userModel.profileUrl!
            : (firebaseUser.photoURL ??
                "https://cdn-icons-png.flaticon.com/512/149/149071.png");

    void _logout() async {
      await FirebaseAuth.instance.signOut();
      context.read<UserDetailsProvider>().clearUser();
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed("/login");
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text('admin_profile'.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 👤 Profile Image + Edit Button
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(profileUrl),
                ),
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blueAccent, width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.edit,
                          size: 18,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProfilePage(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Text(
              userModel.displayName ?? "Admin",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              userModel.email ?? firebaseUser.email ?? "",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "system_administrator".tr(),
                style: const TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const Divider(height: 40, thickness: 1.5),

            // ⚙️ Admin Settings
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.blue),
              title: Text("manage_app".tr()),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminSettingsPage()),
                );
              },
            ),

            // 👥 Manage Users
            ListTile(
              leading: const Icon(Icons.people, color: Colors.green),
              title: Text("manage_users".tr()),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pushNamed(context, "/admin/users");
              },
            ),

            // 🏢 Manage Clients
            ListTile(
              leading: const Icon(Icons.business_center, color: Colors.orange),
              title: Text("manage_clients".tr()),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pushNamed(context, "/admin/clients");
              },
            ),

            // 📊 Dashboard Access
            ListTile(
              leading: const Icon(Icons.dashboard, color: Colors.indigo),
              title: Text("view_dashboard".tr()),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pushNamed(context, "/admin/dashboard");
              },
            ),

            const Divider(height: 40, thickness: 1.2),

            // 🚪 Logout
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text("logout".tr()),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }
}
