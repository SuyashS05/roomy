import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:romy/Auth/profile_page.dart';
import 'package:romy/Pages/Master/settings_page.dart';

class AdminHome extends StatefulWidget {
  final User user;
  const AdminHome({super.key, required this.user});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _currentIndex = 0;

  late final List<Widget> _bottomPages;

  @override
  void initState() {
    super.initState();
    _bottomPages = [
      _buildDashboard(),
      const Center(child: Text("👥 Manage Users")),
      const Center(child: Text("💼 Clients Management")),
      SettingsPage(user: widget.user),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("No new notifications")),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfilePage(uid: widget.user.uid),
                ),
              );
            },
          ),
        ],
      ),

      // ✅ Sidebar (Drawer) separate from bottom navigation
      drawer: _buildSidebar(),

      // ✅ BottomNavigation controlled pages
      body: _bottomPages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // ✅ makes all tabs visible
        backgroundColor: Colors.white, // ✅ bar background
        selectedItemColor: Colors.blue, // ✅ active icon/text
        unselectedItemColor: Colors.grey, // ✅ inactive icons/text
        showUnselectedLabels: true, // ✅ show labels for all tabs
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Users"),
          BottomNavigationBarItem(
            icon: Icon(Icons.business_center),
            label: "Clients",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }

  // 🔹 Sidebar Drawer
  Widget _buildSidebar() {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(widget.user.email ?? "Admin"),
            accountEmail: const Text("admin@roomy.com"),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.admin_panel_settings,
                size: 40,
                color: Colors.blue,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text("Analytics"),
            onTap: () {
              Navigator.pop(context);
              _showSnack("Analytics Page (Coming Soon)");
            },
          ),
          ListTile(
            leading: const Icon(Icons.report),
            title: const Text("Reports"),
            onTap: () {
              Navigator.pop(context);
              _showSnack("Reports Page (Coming Soon)");
            },
          ),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text("Billing & Payments"),
            onTap: () {
              Navigator.pop(context);
              _showSnack("Billing Page (Coming Soon)");
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text("Help & Support"),
            onTap: () {
              Navigator.pop(context);
              _showSnack("Help Page (Coming Soon)");
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
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
  }

  // 🔹 Example dashboard layout
  Widget _buildDashboard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        children: [
          _buildStatCard("Total Users", "1200", Icons.people, Colors.blue),
          _buildStatCard("Room Owners", "350", Icons.house, Colors.green),
          _buildStatCard("Active Seekers", "850", Icons.search, Colors.orange),
          _buildStatCard("Pending Reports", "12", Icons.report, Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
