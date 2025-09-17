import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:romy/Pages/Master/pages/clientRequest.dart';

class AdminClientsPage extends StatelessWidget {
  final User user;
  const AdminClientsPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Clients Management"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Welcome card
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.deepPurple.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.admin_panel_settings,
                      size: 40, color: Colors.deepPurple),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "Hello Admin!\nManage Room Owners and Client Requests easily.",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple.shade900),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Room Owners Requests Card
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              onTap: () {
                // Navigate to Client Requests Page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClientRequestsPage(user: user),
                  ),
                );
              },
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.business, color: Colors.deepPurple),
              ),
              title: const Text(
                "Room Owners Requests",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                  "View and manage all Room Owners verification requests"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            ),
          ),
          const SizedBox(height: 16),

          // Another example card (expandable later)
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              onTap: () {
                // Navigate to all clients list page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllRoomOwnersPage(user: user),
                  ),
                );
              },
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.group, color: Colors.orange),
              ),
              title: const Text(
                "All Room Owners",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text("Manage, edit or view all Room Owners"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class AllRoomOwnersPage extends StatelessWidget {
  final User user;
  const AllRoomOwnersPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Room Owners")),
      body: const Center(child: Text("All Room Owners List")),
    );
  }
}
