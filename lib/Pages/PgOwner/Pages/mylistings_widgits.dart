import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:romy/Models/Users.dart';

class MyListingsWidget extends StatelessWidget {
  final UserModel user;
  final int limit; // number of listings to show

  const MyListingsWidget({super.key, required this.user, this.limit = 3});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("listings")
          .where("ownerUid", isEqualTo: user.uid)
          .orderBy("createdAt", descending: true)
          .limit(limit)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Text("no_listings_yet".tr());
        }

        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final title = data["title"] ?? "Untitled";
            final price = "₹${data["basePrice"] ?? 0}/month";
            final city = data["address"]?["city"] ?? "";
            final type = data["type"] ?? "";
            final imageUrl = (data["images"] != null &&
                    (data["images"] as List).isNotEmpty)
                ? data["images"][0]
                : "https://via.placeholder.com/150";

            return ListingCardWidget(
              listingId: doc.id,
              type: type,
              title: title,
              price: price,
              details: "$city • $type",
              imageUrl: imageUrl,
              canEdit: false, // minimal dashboard view, no edit/delete
              onTap: () {
                // Navigate to details page based on type
              },
            );
          }).toList(),
        );
      },
    );
  }
}


class ListingCardWidget extends StatelessWidget {
  final String listingId;
  final String type;
  final String title;
  final String price;
  final String details;
  final String imageUrl;
  final bool canEdit;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const ListingCardWidget({
    super.key,
    required this.listingId,
    required this.type,
    required this.title,
    required this.price,
    required this.details,
    required this.imageUrl,
    this.canEdit = false,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 5,
        child: Row(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(16)),
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
                    Text(title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(price,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.green)),
                    const SizedBox(height: 4),
                    Text(details,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 8),
                    if (canEdit)
                      Row(
                        children: [
                          if (onEdit != null)
                            TextButton.icon(
                              onPressed: onEdit,
                              icon: const Icon(Icons.edit, size: 16),
                              label: Text("edit".tr()),
                            ),
                          if (onDelete != null)
                            TextButton.icon(
                              onPressed: onDelete,
                              icon: const Icon(Icons.delete,
                                  size: 16, color: Colors.red),
                              label: Text("delete".tr(),
                                  style: const TextStyle(color: Colors.red)),
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
