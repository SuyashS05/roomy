import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:romy/Auth/profile_page.dart';
import 'package:romy/Pages/Master/Manage/AppImageManager.dart';
import 'package:romy/Pages/Master/Manage/admin_profile_manager.dart';
import 'package:romy/Pages/Master/pages/AminProfilePage.dart';
import 'package:romy/Pages/User/settings_page.dart';

import 'admin_dashboard_page.dart';
import 'admin_users_page.dart';
import 'admin_clients_page.dart';
import 'package:romy/provoiders/locale_provider.dart';
import 'package:romy/provoiders/user_details_provider.dart';
import 'package:romy/provoiders/user_provider.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _index = 0;

  late List<Map<String, dynamic>> _menuItems;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _menuItems = [
      {"icon": Icons.dashboard, "label": "dashboard".tr()},
      {"icon": Icons.people, "label": "users".tr()},
      {"icon": Icons.business_center, "label": "clients".tr()},
      {"icon": Icons.settings, "label": "settings".tr()},
    ];

    _pages = const [
      AdminDashboardPage(),
      AdminUsersPage(),
      AdminClientsPage(),
      AdminProfilePage(),
    ];
  }

  Future<void> _logout(BuildContext context) async {
    final userProvider = context.read<UserProvider>();
    await FirebaseAuth.instance.signOut();
    userProvider.clearUser(); // Clear global user state
    if (mounted) {
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final userDetails = context.watch<UserDetailsProvider>().user;

    if (userDetails == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("admin_panel".tr()),
        actions: [
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
      drawer: _buildAdminDrawer(
        context,
        userDetails,
        () => _logout(context),
        (index) => setState(() => _index = index),
      ),
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: "dashboard".tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people),
            label: "users".tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.business_center),
            label: "clients".tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: "profile".tr(),
          ),
        ],
      ),
    );
  }

  /// 🧭 Drawer Builder for Admin Panel
  Drawer _buildAdminDrawer(
    BuildContext context,
    dynamic userDetails,
    void Function() logoutCallback,
    void Function(int) onSelectPage,
  ) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              userDetails.displayName ?? "admin_user".tr(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(userDetails.email ?? ""),
            currentAccountPicture: CircleAvatar(
              radius: 30,
              backgroundImage:
                  userDetails.profileUrl != null
                      ? NetworkImage(userDetails.profileUrl!)
                      : const AssetImage('assets/admin.png') as ImageProvider,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard, color: Colors.blue),
            title: Text("dashboard".tr()),
            onTap: () {
              onSelectPage(0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people, color: Colors.teal),
            title: Text("users".tr()),
            onTap: () {
              onSelectPage(1);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.business_center, color: Colors.orange),
            title: Text("clients".tr()),
            onTap: () {
              onSelectPage(2);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.grey),
            title: Text("settings".tr()),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.supervised_user_circle_rounded, color: Colors.indigo),
            title: Text("profile_images".tr()),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminProfileManager()),
                );
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo, color: Colors.indigo),
            title: Text("app_images".tr()),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminAppImageManager()),
                );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: Text(
              "logout".tr(),
              style: const TextStyle(color: Colors.red),
            ),
            onTap: logoutCallback,
          ),
        ],
      ),
    );
  }
}



/*
Widget _buildDrawer(BuildContext context, dynamic userDetails) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userDetails.displayName ?? "admin_user".tr()),
            accountEmail: Text(userDetails.email ?? ""),
            currentAccountPicture: CircleAvatar(
              radius: 30,
              backgroundImage: userDetails.profileUrl != null
                  ? NetworkImage(userDetails.profileUrl!)
                  : const AssetImage('assets/admin.png') as ImageProvider,
            ),
          ),
          ...List.generate(_menuItems.length, (index) {
            final item = _menuItems[index];
            return ListTile(
              leading: Icon(item["icon"]),
              title: Text(item["label"]),
              selected: index == _index,
              onTap: () {
                setState(() => _index = index);
                Navigator.pop(context);
              },
            );
          }),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: Text("logout".tr(),
                style: const TextStyle(color: Colors.red)),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
   */