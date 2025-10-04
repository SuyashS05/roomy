import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:romy/Helpers/ContactHelper.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final _firestore = FirebaseFirestore.instance;

  Future<void> _confirmDeleteUser(String uid, String displayName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Delete User"),
            content: Text("Are you sure you want to delete '$displayName'?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        await _firestore.collection('users').doc(uid).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ User deleted successfully")),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ Failed to delete user: $e")));
      }
    }
  }

  Future<void> _showUserDetails(
    Map<String, dynamic> userData,
    String uid,
  ) async {
    final roomFinderDoc =
        await _firestore.collection('roomFinders').doc(uid).get();
    final roomFinderData =
        roomFinderDoc.exists
            ? roomFinderDoc.data() as Map<String, dynamic>
            : null;

    // Bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.85,
            maxChildSize: 0.95,
            builder:
                (_, controller) => SingleChildScrollView(
                  controller: controller,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // 🔹 User Info
                          Column(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: NetworkImage(
                                  userData['profileUrl'] ?? "",
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                userData['displayName'] ?? "Unnamed User",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                userData['email'] ?? "",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),

                          // 🔹 Action Buttons
                          Column(
                            children: [
                              ElevatedButton.icon(
                                onPressed:
                                    () => ContactUtils.callNumber("9322572179"),
                                icon: const Icon(
                                  Icons.call,
                                  color: Colors.white,
                                ),
                                label: const Text("Call"),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(140, 40),
                                  backgroundColor: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed:
                                    () => ContactUtils.sendSMS(
                                      "9322572179",
                                      message: "Hello there!",
                                    ),
                                icon: const Icon(
                                  Icons.message,
                                  color: Colors.white,
                                ),
                                label: const Text("SMS"),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(140, 40),
                                  backgroundColor: Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed:
                                    () => ContactUtils.sendWhatsApp(
                                      "9322572179",
                                      message: "Hi from the app 👋",
                                    ),
                                icon: const Icon(
                                  Icons.chat,
                                  color: Colors.white,
                                ),
                                label: const Text("WhatsApp"),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(140, 40),
                                  backgroundColor: Colors.teal,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const Divider(height: 30),
                      _infoRow("📱 Phone", userData['phone']),
                      _infoRow("🎂 Age", userData['age']?.toString()),
                      _infoRow("📍 Address", userData['address']),
                      _infoRow("🌆 City", userData['city']),
                      _infoRow("🌐 Language", userData['language']),
                      _infoRow("👤 Role", userData['role']),
                      _infoRow(
                        "🕒 Created At",
                        userData['createdAt']?.toDate().toString(),
                      ),
                      const SizedBox(height: 12),

                      if (roomFinderData != null) ...[
                        const Divider(),
                        const Text(
                          "🏠 Room Preferences",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _infoRow(
                          "💰 Budget",
                          "${roomFinderData['budgetMin']} - ${roomFinderData['budgetMax']}",
                        ),
                        _infoRow(
                          "🧹 Cleanliness",
                          "${roomFinderData['cleanliness']}/5",
                        ),
                        _infoRow("🍴 Food Type", roomFinderData['foodType']),
                        _infoRow("💤 Sleep Time", roomFinderData['sleepTime']),
                        _infoRow("🚫 Smoking", roomFinderData['smoking']),
                        _infoRow("🐾 Pets", roomFinderData['pets']),
                        _infoRow(
                          "🎓 Occupation",
                          roomFinderData['occupationDetail'],
                        ),
                        if (roomFinderData['hobbies'] != null)
                          _infoRow(
                            "🎯 Hobbies",
                            (roomFinderData['hobbies'] as List).join(', '),
                          ),
                        if (roomFinderData['languages'] != null)
                          _infoRow(
                            "🗣️ Languages",
                            (roomFinderData['languages'] as List).join(', '),
                          ),
                        const SizedBox(height: 12),
                      ],

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade100,
                              foregroundColor: Colors.red.shade800,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              _confirmDeleteUser(
                                uid,
                                userData['displayName'] ?? 'User',
                              );
                            },
                            icon: const Icon(Icons.delete),
                            label: const Text("Delete User"),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                            label: const Text("Close"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _infoRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        "$title: ${value ?? 'N/A'}",
        style: const TextStyle(fontSize: 15),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: const Text("👥 Manage Users"))),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            _firestore
                .collection('users')
                .orderBy('createdAt', descending: true)
                // .where('role', isEqualTo: 'user')
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No users found"));
          }

          final users = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: users.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final doc = users[index];
              final data = doc.data() as Map<String, dynamic>;
              final uid = doc.id;

              return ListTile(
                onTap: () => _showUserDetails(data, uid),
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                    data['profileUrl'] ??
                        "https://via.placeholder.com/150/000000/FFFFFF/?text=User",
                  ),
                ),
                title: Text(data['displayName'] ?? "Unknown User"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['email'] ?? ""),
                    Text("Role: ${data['role'] ?? 'N/A'}"),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 18),
                  onPressed: () => _showUserDetails(data, uid),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
