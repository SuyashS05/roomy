import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:romy/Helpers/roomOwnerVerifi.dart';
import 'package:romy/Models/Users.dart';
import 'package:romy/Pages/PgOwner/Pages/hostel_add_page.dart';
import 'package:romy/Pages/PgOwner/Pages/house_add_page.dart';
import 'package:romy/Pages/PgOwner/Pages/pg_add_page.dart';
import 'package:romy/Pages/User/Manage/NotificationPage.dart';
import 'package:romy/pages/PgOwner/home/my_listings_page.dart';
import 'package:romy/pages/PgOwner/home/owner_dashboard_page.dart';
import 'package:romy/pages/PgOwner/home/profile_page.dart';
import 'package:romy/pages/user/settings_page.dart';
import 'package:romy/provoiders/locale_provider.dart';
import 'package:romy/provoiders/user_details_provider.dart';
import 'package:romy/provoiders/user_provider.dart';

class OwnerHome extends StatefulWidget {
  const OwnerHome({super.key});

  @override
  State<OwnerHome> createState() => _OwnerHomeState();
}

class _OwnerHomeState extends State<OwnerHome> {
  int _index = 0;
  late List<Widget> pages;

  void _logout() async {
    final userProvider = context.read<UserProvider>();
    await FirebaseAuth.instance.signOut();
    userProvider.clearUser();
    if (mounted) {
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final UserModel? userDetails = context.watch<UserDetailsProvider>().user;

    // 🔹 Handle null user safely
    if (userDetails == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 🔹 Pages list depends on userDetails
    pages = [
      OwnerDashboardPage(user: userDetails),
      MyListingsPage(user: userDetails),
      Container(), // Placeholder for Add sheet
      OwnerProfilePage(user: userDetails),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Roomy".tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationPage()),
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
              accountName: Text(
                userDetails.displayName?.isNotEmpty == true
                    ? userDetails.displayName!
                    : "guest_user".tr(),
              ),
              accountEmail: Text(userDetails.email),
              currentAccountPicture: CircleAvatar(
                radius: 30,
                backgroundImage:
                    userDetails.profileUrl != null
                        ? NetworkImage(userDetails.profileUrl!)
                        : const AssetImage('assets/admin.png') as ImageProvider,
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
              leading: const Icon(Icons.list_alt),
              title: Text("my_listings".tr()),
              onTap: () {
                setState(() => _index = 1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_box),
              title: Text("add_room".tr()),
              onTap: () {
                Navigator.pop(context);
                _showAddListingSheet(userDetails);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text("profile".tr()),
              onTap: () {
                setState(() => _index = 3);
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
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: Text(
                "logout".tr(),
                style: const TextStyle(color: Colors.red),
              ),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          if (i == 2) {
            _showAddListingSheet(userDetails);
          } else {
            setState(() => _index = i);
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: "dashboard".tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.list_alt),
            label: "my_listings".tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.add_box),
            label: "add_room".tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: "profile".tr(),
          ),
        ],
      ),
    );
  }

  String _getInitial(String? name) {
    if (name == null || name.isEmpty) return "U";
    return name[0].toUpperCase();
  }

  void _showAddListingSheet(UserModel userDetails) async {
    // ✅ Check verification before showing the sheet
    final isVerified = await checkVerified(context, userDetails.uid);
    if (!isVerified) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (_) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "add_new_listing".tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildAddCard(
                      title: "hostel".tr(),
                      icon: Icons.apartment,
                      color: Colors.blue,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HostelAddPage(owner: userDetails),
                          ),
                        );
                      },
                    ),
                    _buildAddCard(
                      title: "pg".tr(),
                      icon: Icons.people,
                      color: Colors.orange,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PgAddPage(owner: userDetails),
                          ),
                        );
                      },
                    ),
                    _buildAddCard(
                      title: "house".tr(),
                      icon: Icons.house,
                      color: Colors.green,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HomeAddPage(owner: userDetails),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }

  Widget _buildAddCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              offset: const Offset(0, 3),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: color,
              radius: 24,
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
