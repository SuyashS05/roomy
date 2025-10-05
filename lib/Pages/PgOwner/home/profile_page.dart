import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:romy/Auth/profile_page.dart';
import 'package:romy/Helpers/LogOut_confim.dart';
import 'package:romy/Helpers/Notifi_Snackbar.dart';
import 'package:romy/Models/Users.dart';
import 'package:romy/Pages/PgOwner/Pages/ProfileVerificationPage.dart';
import 'package:romy/provoiders/user_details_provider.dart';

class OwnerProfilePage extends StatelessWidget {
  final UserModel user;
  const OwnerProfilePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text("profile".tr())),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection("users").doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final profileUrl = data["profileUrl"] as String? ?? user.profileUrl;
          final isComplete = data["profileComplete"] as bool? ?? false;
          final name = data["displayName"] as String? ?? "owner".tr();
          final phone = data["phone"] as String? ?? "not_provided".tr();
          final joinedAt = data["createdAt"] != null
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
                                MaterialPageRoute(builder: (_) => ProfilePage()),
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
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(user.email ?? "", style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 4),
                Text("room_owner".tr(), style: const TextStyle(color: Colors.blueGrey)),

                const Divider(height: 40, thickness: 1.5),

                // ---------------- Profile Verification ----------------
                ListTile(
                  leading: const Icon(Icons.verified_user, color: Colors.blue),
                  title: Text("profile_verification".tr()),
                  trailing: FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
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
                        return _buildStatusChip("get_verified".tr(), Colors.grey);
                      }

                      final data = snapshot.data!.data() as Map<String, dynamic>;
                      final adminCheck = data["adminCheck"] ?? "pending";
                      final adminVerified = data["adminVerified"] ?? false;

                      if (adminVerified && adminCheck == "approved") {
                        return _buildStatusChip("verified".tr(), Colors.green);
                      } else if (adminCheck == "pending") {
                        return _buildStatusChip("pending".tr(), Colors.orange);
                      } else if (adminCheck == "no") {
                        return _buildStatusChip("rejected".tr(), Colors.red);
                      } else {
                        return _buildStatusChip("get_verified".tr(), Colors.grey);
                      }
                    },
                  ),
                  onTap: () {
                    if (!isComplete) {
                      AppNotifier.show(
                        context,
                        title: "incomplete_profile".tr(),
                        message: "please_complete_profile".tr(),
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

                const Divider(height: 40, thickness: 1.5),

                // ---------------- Profile Details ----------------
                _buildInfoRow(Icons.phone, "phone".tr(), phone),
                if (joinedAt != null)
                  _buildInfoRow(
                    Icons.calendar_today,
                    "joined_on".tr(),
                    "${joinedAt.day}/${joinedAt.month}/${joinedAt.year}",
                  ),
                _buildInfoRow(
                  Icons.verified,
                  "profile_status".tr(),
                  isComplete ? "${"complete".tr()} ✅" : "${"incomplete".tr()} ⚠️",
                ),

                const Divider(),

                // ---------------- Logout ----------------
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: Text("logout".tr()),
                  onTap: () async {
                    final confirmed = await showConfirmationDialog(
                      context,
                      title: "logout".tr(),
                      message: "logout_confirmation".tr(),
                      confirmText: "logout".tr(),
                      confirmColor: Colors.red,
                    );
                    if (confirmed == true) {
                      await FirebaseAuth.instance.signOut();
                      context.read<UserDetailsProvider>().clearUser();
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
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
