import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:romy/Pages/User/pages/PreferencesPage.dart';
import 'package:romy/Auth/profile_page.dart';
import 'package:romy/provoiders/locale_provider.dart';
import 'package:romy/provoiders/user_details_provider.dart';
import '../settings_page.dart';

class SeekerProfilePage extends StatelessWidget {
  const SeekerProfilePage({super.key});

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
            : (firebaseUser.photoURL ?? "");
    final isComplete = userModel.profileComplete;
    final preferencesGiven = userModel.preferencesGiven;

    void _logout() async {
      await FirebaseAuth.instance.signOut();
      context.read<UserDetailsProvider>().clearUser();
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed("/login");
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text('profile'.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                    profileUrl.isNotEmpty
                        ? profileUrl
                        : "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ4YreOWfDX3kK-QLAbAL4ufCPc84ol2MA8Xg&s",
                  ),
                ),
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isComplete ? Colors.green : Colors.orange,
                        width: 3,
                      ),
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
                            MaterialPageRoute(builder: (_) => ProfilePage()),
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
              userModel.email,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              userModel.role == "roomOwner" ? "Room Owner" : "Room Seeker",
              style: const TextStyle(color: Colors.grey),
            ),
            const Divider(height: 40, thickness: 1.5),

            // 🔹 Preferences
            ListTile(
              leading: Icon(
                Icons.tune,
                color: preferencesGiven ? Colors.green : Colors.orange,
              ),
              title: Text("preferences".tr()),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PreferencesPage(uid: userModel.uid),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // 🔹 Settings
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.blue),
              title: Text("settings".tr()),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
            ),

            // 🔹 Saved
            ListTile(
              leading: const Icon(Icons.bookmark, color: Colors.orange),
              title: Text("saved".tr()),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),

            // 🔹 Logout
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


/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:romy/Auth/profile_page.dart';
import 'package:romy/Pages/User/pages/PreferencesPage.dart';

class SeekerProfilePage extends StatelessWidget {
  final User user;
  const SeekerProfilePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection("users")
                .doc(user.uid)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final profileUrl =
              (data["profileUrl"] as String?) ?? user.photoURL ?? "";
          final isComplete = data["profileComplete"] as bool? ?? false;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                        profileUrl.isNotEmpty
                            ? profileUrl
                            : "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ4YreOWfDX3kK-QLAbAL4ufCPc84ol2MA8Xg&s",
                      ),
                    ),
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isComplete ? Colors.green : Colors.orange,
                            width: 3,
                          ),
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
                                  builder: (_) => ProfilePage(uid: user.uid),
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
                  user.email ?? "User",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text("Room Seeker", style: TextStyle(color: Colors.grey)),
                const Divider(height: 40, thickness: 1.5),
                ListTile(
                  leading: Icon(
                    Icons.tune,
                    color:
                        (data["preferencesGiven"] == true)
                            ? Colors.green
                            : Colors.orange,
                  ),
                  title: const Text("Preferences"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PreferencesPage(uid: user.uid),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.blue),
                  title: const Text("Account Settings"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.bookmark, color: Colors.orange),
                  title: const Text("Saved Rooms"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text("Logout"),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed("/login");
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
 */