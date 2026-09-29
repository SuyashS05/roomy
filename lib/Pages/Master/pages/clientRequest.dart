import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:romy/Pages/Master/pages/RoomOwnerDetails.dart';
import 'package:romy/provoiders/user_details_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:romy/Pages/Master/pages/ClientRequestCard.dart';
import 'package:romy/Helpers/private_storage_image.dart';

class ClientRequestsPage extends StatefulWidget {
  const ClientRequestsPage({super.key});

  @override
  State<ClientRequestsPage> createState() => _ClientRequestsPageState();
}

class _ClientRequestsPageState extends State<ClientRequestsPage> {
  final _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _launchContact(String phone) async {
    if (phone.isEmpty) return;
    final url = Uri.parse("tel:$phone");
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  Future<void> _launchWhatsApp(String phone) async {
    if (phone.isEmpty) return;
    final url = Uri.parse("https://wa.me/$phone");
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  Future<void> _updateVerification(
    String uid,
    bool approve, {
    String reason = "",
  }) async {
    await FirebaseFirestore.instance.collection("RoomOwners").doc(uid).update({
      "adminVerified": approve,
      "adminCheck": approve ? "approved" : "rejected",
      "unverifiedReason": reason,
    });
  }

  void _showDocument(String path, String title) {
    if (path.isEmpty) return;
    showPrivateStorageImageDialog(context, path, title);
  }

  bool _matchesSearch(Map<String, dynamic> owner, Map<String, dynamic>? user) {
    final query = _searchQuery.toLowerCase();
    final aadhaarName = (owner["aadhaarName"] ?? "").toLowerCase();
    final phone = (user?["phone"] ?? "").toLowerCase();
    final email = (user?["email"] ?? "").toLowerCase();
    final displayName = (user?["displayName"] ?? "").toLowerCase();

    return aadhaarName.contains(query) ||
        phone.contains(query) ||
        email.contains(query) ||
        displayName.contains(query);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserDetailsProvider>().user;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Room Owners Management"),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search by name, phone, or email...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = "";
                            });
                          },
                        )
                        : null,
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection("RoomOwners")
                .orderBy("submittedAt", descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Room Owners found"));
          }

          final roomOwnerDocs = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: roomOwnerDocs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final owner = roomOwnerDocs[index].data() as Map<String, dynamic>;
              final uid = owner["uid"] ?? "";
              final status = owner["adminCheck"] ?? "pending";
              final submittedAt = owner["submittedAt"] as Timestamp?;

              return FutureBuilder<DocumentSnapshot>(
                future:
                    FirebaseFirestore.instance
                        .collection("users")
                        .doc(uid)
                        .get(),
                builder: (context, userSnap) {
                  if (!userSnap.hasData) {
                    return const SizedBox.shrink();
                  }

                  final user = userSnap.data?.data() as Map<String, dynamic>?;

                  if (!_matchesSearch(owner, user)) {
                    return const SizedBox.shrink();
                  }

                  final aadhaarName = owner["aadhaarName"] ?? "N/A";

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => RoomOwnerDetailsPage(
                                owner: owner,
                                user: user,
                              ),
                        ),
                      );
                    },
                    child: buildRoomOwnerCard(
                      context,
                      owner,
                      uid,
                      status,
                      aadhaarName, // ✅ fixed name
                      submittedAt,
                      _showDocument, // ✅ fixed function reference
                      _updateVerification,
                      _launchWhatsApp,
                      _launchContact,
                      user: user,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
