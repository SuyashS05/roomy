import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:romy/Helpers/LogOut_confim.dart';
import 'package:romy/Helpers/Notifi_Snackbar.dart';
import 'package:romy/Pages/PgOwner/Pages/HostelDetails.dart';

import '../Pages/hostel_add_page.dart';
import '../Pages/pg_add_page.dart';
import '../Pages/house_add_page.dart';

class MyListingsPage extends StatelessWidget {
  final User user;
  const MyListingsPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Listings"),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              AppNotifier.show(
                context,
                message: "No new notifications",
                type: NotificationType.info,
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Add New Listing",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // --- Add Cards ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAddCard(
                context,
                title: "Hostel",
                icon: Icons.apartment,
                color: Colors.blue,
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HostelAddPage(owner: user),
                      ),
                    ),
              ),
              _buildAddCard(
                context,
                title: "PG",
                icon: Icons.people,
                color: Colors.orange,
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PgAddPage(owner: user)),
                    ),
              ),
              _buildAddCard(
                context,
                title: "House",
                icon: Icons.house,
                color: Colors.green,
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HouseAddPage(owner: user),
                      ),
                    ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Text(
            "Your Listings",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // 🔹 Firestore Stream of Listings
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection("listings")
                    .where("ownerUid", isEqualTo: user.uid)
                    .orderBy("createdAt", descending: true)
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Text("You have no listings yet.");
              }

              final listings = snapshot.data!.docs;

              return Column(
                children:
                    listings.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final listingId = doc.id;
                      final title = data["title"] ?? "Untitled";
                      final price = "₹${data["basePrice"] ?? 0}/month";
                      final city = data["address"]?["city"] ?? "";
                      final type = data["type"] ?? "";
                      final imageUrl =
                          (data["images"] != null &&
                                  (data["images"] as List).isNotEmpty)
                              ? data["images"][0]
                              : "https://via.placeholder.com/150";

                      return _buildListingCard(
                        context,
                        listingId: listingId,
                        type: type,
                        title: title,
                        price: price,
                        details: "$city • $type",
                        imageUrl: imageUrl,
                      );
                    }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Card for Adding new listing type
  Widget _buildAddCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: color.withOpacity(0.2),
                  child: Icon(icon, size: 28, color: color),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Card for displaying existing listings
  Widget _buildListingCard(
    BuildContext context, {
    required String listingId,
    required String type,
    required String title,
    required String price,
    required String details,
    required String imageUrl,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HostelDetailsPage(listingId: listingId, user: user.uid),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 5,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: Image.network(
                imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      price,
                      style: const TextStyle(fontSize: 14, color: Colors.green),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      details,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            // Navigate to correct edit page based on type
                            if (type == "hostel") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => HostelAddPage(
                                        owner:
                                            FirebaseAuth.instance.currentUser!,
                                        editListingId: listingId,
                                      ),
                                ),
                              );
                            } else if (type == "pg") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => PgAddPage(
                                        owner:
                                            FirebaseAuth.instance.currentUser!,
                                        editListingId: listingId,
                                      ),
                                ),
                              );
                            } else if (type == "house") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => HouseAddPage(
                                        owner:
                                            FirebaseAuth.instance.currentUser!,
                                        editListingId: listingId,
                                      ),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text("Edit"),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            final confirm = await showConfirmationDialog(
                              context,
                              title: "Delete Listing",
                              message:
                                  "Are you sure you want to delete this listing?",
                              confirmText: "Delete",
                            );

                            if (confirm == true) {
                              AppNotifier.show(
                                context,
                                message: "Deleting listing...",
                                type: NotificationType.warning,
                                duration: const Duration(seconds: 2),
                              );

                              try {
                                await FirebaseFirestore.instance
                                    .collection("listings")
                                    .doc(listingId)
                                    .delete();
                                await FirebaseFirestore.instance
                                    .collection("${type}s")
                                    .doc(listingId)
                                    .delete();

                                AppNotifier.show(
                                  context,
                                  message: "Listing deleted successfully",
                                  type: NotificationType.success,
                                );
                              } catch (e) {
                                AppNotifier.show(
                                  context,
                                  message: "Error deleting listing: $e",
                                  type: NotificationType.error,
                                );
                              }
                            }
                          },
                          icon: const Icon(
                            Icons.delete,
                            size: 16,
                            color: Colors.red,
                          ),
                          label: const Text(
                            "Delete",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
