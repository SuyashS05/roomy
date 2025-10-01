import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:romy/Auth/profile_page.dart';
import 'package:romy/Pages/Master/home/admin_sidebar.dart';

class AdminDashboardPage extends StatelessWidget {
  final User user;
  const AdminDashboardPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
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
      drawer: AdminSidebar(user: user),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          children: const [
            _StatCard("Total Users", "1200", Icons.people, Colors.blue),
            _StatCard("Room Owners", "350", Icons.house, Colors.green),
            _StatCard("Active Seekers", "850", Icons.search, Colors.orange),
            _StatCard("Pending Reports", "12", Icons.report, Colors.red),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard(this.title, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
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
            Text(value,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
