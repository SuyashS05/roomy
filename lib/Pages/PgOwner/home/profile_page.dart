import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:romy/Auth/profile_page.dart';
import 'package:romy/Helpers/LogOut_confim.dart';
import 'package:romy/Helpers/Notifi_Snackbar.dart';
import 'package:romy/Pages/PgOwner/Pages/ProfileVerificationPage.dart';

class OnerProfilePage extends StatelessWidget {
  final User user;
  const OnerProfilePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
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
          final profileUrl = data["profileUrl"] as String? ?? user.photoURL;
          final isComplete = data["profileComplete"] as bool? ?? false;
          final name = data["displayName"] as String? ?? "Owner";
          final phone = data["phone"] as String? ?? "Not provided";
          final joinedAt =
              data["createdAt"] != null
                  ? (data["createdAt"] as Timestamp).toDate()
                  : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ---------------- Avatar + Edit ----------------
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundImage: NetworkImage(
                        (profileUrl?.isNotEmpty ?? false)
                            ? profileUrl!
                            : "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ4YreOWfDX3kK-QLAbAL4ufCPc84ol2MA8Xg&s",
                      ),
                    ),

                    // Edit Button with Completion Ring
                    Positioned(
                      right: -6,
                      bottom: -6,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isComplete ? Colors.green : Colors.orange,
                            width: 3,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 20,
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
                                  builder: (_) => ProfilePage(),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ---------------- Name & Role ----------------
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user.email ?? "",
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Room Owner",
                  style: TextStyle(color: Colors.blueGrey),
                ),

                const Divider(height: 40, thickness: 1.5),

                ListTile(
                  leading: const Icon(Icons.verified_user, color: Colors.blue),
                  title: const Text("Profile Verification"),
                  trailing: FutureBuilder<DocumentSnapshot>(
                    future:
                        FirebaseFirestore.instance
                            .collection("RoomOwners")
                            .doc(user.uid)
                            .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      }

                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        // Not Submitted
                        return _buildStatusChip("Get Verified", Colors.grey);
                      }

                      final data =
                          snapshot.data!.data() as Map<String, dynamic>;
                      final adminCheck = data["adminCheck"] ?? "pending";
                      final adminVerified = data["adminVerified"] ?? false;

                      if (adminVerified == true && adminCheck == "approved") {
                        return _buildStatusChip("Verified", Colors.green);
                      } else if (adminCheck == "pending") {
                        return _buildStatusChip("Pending", Colors.orange);
                      } else if (adminCheck == "no") {
                        return _buildStatusChip("Rejected", Colors.red);
                      } else {
                        return _buildStatusChip("Get Verified", Colors.grey);
                      }
                    },
                  ),
                  onTap: () {
                    if (!isComplete) {
                      AppNotifier.show(
                        context,
                        title: "Incomplete Profile",
                        message:
                            "⚠️ Please complete your profile before verification.",
                        type: NotificationType.warning,
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RoomOwnerVerificationPage(user: user),
                      ),
                    );
                  },
                ),

                Divider(height: 40, thickness: 1.5),
                // ---------------- Profile Details ----------------
                _buildInfoRow(Icons.phone, "Phone", phone),
                if (joinedAt != null)
                  _buildInfoRow(
                    Icons.calendar_today,
                    "Joined On",
                    "${joinedAt.day}/${joinedAt.month}/${joinedAt.year}",
                  ),
                _buildInfoRow(
                  Icons.verified,
                  "Profile Status",
                  isComplete ? "Complete ✅" : "Incomplete ⚠️",
                ),

                const Divider(height: 40, thickness: 1.5),

                // ---------------- Navigation Options ----------------
                ListTile(
                  leading: const Icon(Icons.add_business, color: Colors.blue),
                  title: const Text("My Listings"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Navigate to MyListingsPage
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.analytics, color: Colors.green),
                  title: const Text("Dashboard Insights"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Navigate to OwnerDashboardPage
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.support_agent,
                    color: Colors.orange,
                  ),
                  title: const Text("Support"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.bookmark, color: Colors.purple),
                  title: const Text("Saved Rooms"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),

                const Divider(),

                // ---------------- Logout ----------------
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text("Logout"),
                  onTap: () async {
                    final confirmed = await showConfirmationDialog(
                      context,
                      title: "Logout",
                      message:
                          "Are you sure you want to logout from your account?",
                      confirmText: "Logout",
                      confirmColor: Colors.red,
                    );
                    if (confirmed == true) {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushReplacementNamed("/login");
                      }
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

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  /// Reusable widget for status badge
  Widget _buildStatusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
