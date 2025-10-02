import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:romy/Auth/profile_page.dart';
import 'package:romy/provoiders/locale_provider.dart';
import 'package:romy/provoiders/user_details_provider.dart';
import 'package:romy/provoiders/user_provider.dart';

import 'dashboard_page.dart';
import 'saved_page.dart';
import 'seeker_profile_page.dart';
import '../settings_page.dart';

class SeekerHome extends StatefulWidget {
  const SeekerHome({super.key});

  @override
  State<SeekerHome> createState() => _SeekerHomeState();
}

class _SeekerHomeState extends State<SeekerHome> {
  int _index = 0;
  late List<Widget> pages;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userDetails =
        context.watch<UserDetailsProvider>().user; // ✅ get Firestore user

    // Initialize pages once userDetails is available
    pages = [
      if (userDetails != null) DashboardPage(user: userDetails),
      const SavedPage(),
      const SeekerProfilePage(),
    ];
  }

  void _logout() async {
    final userProvider = context.read<UserProvider>();
    await FirebaseAuth.instance.signOut();
    userProvider.clearUser(); // clear global user state
    if (mounted) {
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final userDetails = context.watch<UserDetailsProvider>().user;

    if (userDetails == null) {
      // Show loading until userDetails is fetched
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Roomy".tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("no_new_notifications".tr())),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfilePage()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName:
                  Text(userDetails.displayName ?? "guest_user".tr()),
              accountEmail: Text(userDetails.email ?? ""),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  (userDetails.displayName?.substring(0, 1) ?? "U")
                      .toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: Text("dashboard".tr()),
              onTap: () {
                setState(() => _index = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: Text("saved".tr()),
              onTap: () {
                setState(() => _index = 1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text("profile".tr()),
              onTap: () {
                setState(() => _index = 2);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text("settings".tr()),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: Text("logout".tr()),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: "dashboard".tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bookmark),
            label: "saved".tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: "profile".tr(),
          ),
        ],
      ),
    );
  }
}
