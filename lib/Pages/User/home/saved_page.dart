import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:romy/Helpers/ListignsSaveRatingHelper.dart';
import 'package:romy/Models/Users.dart';

class SavedPage extends StatefulWidget {
  final UserModel user;
  const SavedPage({super.key, required this.user});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> savedListings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedListings();
  }

  Future<void> _loadSavedListings() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(widget.user.uid)
        .collection('saved')
        .orderBy('savedAt', descending: true)
        .get();

    final List<Map<String, dynamic>> temp = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final listingId = data['listingId'];
      if (listingId != null) {
        final listingDoc =
            await _firestore.collection('listings').doc(listingId).get();
        if (listingDoc.exists) {
          final listingData = listingDoc.data()!;
          listingData['id'] = listingId;
          listingData['isSaved'] = true; // mark as saved
          temp.add(listingData);
        }
      }
    }

    setState(() {
      savedListings = temp;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Saved Rooms")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : savedListings.isEmpty
              ? const Center(child: Text("No saved rooms"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: savedListings.length,
                  itemBuilder: (context, index) {
                    final listing = savedListings[index];
                    return _buildRoomCard(listing);
                  },
                ),
    );
  }

  Widget _buildRoomCard(Map<String, dynamic> listing) {
    final id = listing['id'];
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      child: Row(
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(16)),
            child: Image.network(
              (listing['images'] != null && listing['images'].isNotEmpty)
                  ? listing['images'][0]
                  : "https://picsum.photos/200",
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
                    listing['title'] ?? "Unknown Room",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "₹${listing['basePrice'] ?? 'N/A'}/month",
                    style: const TextStyle(fontSize: 14, color: Colors.green),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    listing['amenities'] != null
                        ? (listing['amenities'] as Map).keys.join(" • ")
                        : "",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),

                  // ⭐ Rating & 💾 Save buttons
                  Row(
                    children: [
                      // Rating stars
                      StatefulBuilder(
                        builder: (context, setStateStar) {
                          double currentRating =
                              listing['userRating'] ?? 0.0;
                          return Row(
                            children: List.generate(5, (index) {
                              return GestureDetector(
                                onTap: () async {
                                  double newRating = index + 1.0;
                                  await rateListing(
                                    listingId: id,
                                    userId: widget.user.uid!,
                                    rating: newRating,
                                  );
                                  setStateStar(() {
                                    currentRating = newRating;
                                    listing['userRating'] = newRating;
                                  });
                                },
                                child: Icon(
                                  index < currentRating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                              );
                            }).map((widget) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 2.0),
                                  child: widget,
                                )).toList(),
                          );
                        },
                      ),

                      const SizedBox(width: 12),

                      // Save / unsave
                      StatefulBuilder(
                        builder: (context, setStateSave) {
                          bool isSaved = listing['isSaved'] ?? false;
                          return GestureDetector(
                            onTap: () async {
                              if (!isSaved) {
                                await saveListing(
                                  userId: widget.user.uid!,
                                  listingId: id,
                                  listingData: {
                                    'title': listing['title'],
                                    'image': (listing['images'] != null &&
                                            listing['images'].isNotEmpty)
                                        ? listing['images'][0]
                                        : null,
                                  },
                                );
                              } else {
                                await unsaveListing(
                                    userId: widget.user.uid!, listingId: id);
                              }

                              setStateSave(() {
                                isSaved = !isSaved;
                                listing['isSaved'] = isSaved;
                              });
                            },
                            child: Icon(
                              isSaved ? Icons.bookmark : Icons.bookmark_border,
                              color: isSaved ? Colors.green : Colors.grey,
                              size: 24,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
