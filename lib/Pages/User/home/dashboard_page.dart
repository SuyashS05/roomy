import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:romy/Helpers/ListignsSaveRatingHelper.dart';
import 'package:romy/Helpers/nearbyListing.dart';
import 'package:romy/Models/Users.dart';
import 'package:romy/Pages/ListingsMap.dart';
import 'package:romy/Pages/PgOwner/Pages/HomeDetailsPage.dart';
import 'package:romy/Pages/PgOwner/Pages/HostelDetailsPage.dart';
import 'package:romy/Pages/PgOwner/Pages/PgDetailsPage.dart';
import 'package:romy/Pages/User/Manage/MessagesPage.dart';
import 'package:romy/Pages/User/Manage/ProfileSetting.dart';
import 'package:romy/Pages/User/Manage/UserSupportPage.dart';
import 'package:romy/Pages/User/home/mapPreviewUsers.dart';
import 'package:romy/Pages/User/pages/FindRoommetsPage.dart';
import 'package:romy/Pages/User/pages/FindroomPage.dart';
import 'package:romy/Pages/User/pages/SearchBar.dart';

class DashboardPage extends StatefulWidget {
  final UserModel user;
  const DashboardPage({super.key, required this.user});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Map<String, dynamic>> recommendedListings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNearbyListings();
  }

  void _loadNearbyListings() async {
    final lat = widget.user.lat;
    final lng = widget.user.lng;

    if (lat == null || lng == null) {
      debugPrint("User location is not available");
      setState(() => isLoading = false);
      return;
    }

    try {
      final listings = await fetchNearbyListings(
        widget.user.lat!,
        widget.user.lng!,
      );
      if (mounted) {
        setState(() {
          recommendedListings = listings;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
      debugPrint("Error fetching nearby listings: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Map preview container
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ListingsMap()),
                );
              },
              child: const MapPreviewWidget(),
            ),
            const SizedBox(height: 24),

            // 🔹 Search widget
            RoomSearchWidget(),

            const SizedBox(height: 16),

            // 🔹 Action cards
            Row(
              children: [
                _buildCard(
                  tr("find_room"),
                  "assets/img/ViewRoom.png",
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => FindroomPage()),
                  ),
                ),
                const SizedBox(width: 8),
                _buildCard(
                  tr("find_roommates"),
                  "assets/img/ViewRoomate.png",
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CampaignsPage()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              tr("quick_actions"),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              children: [
                _buildActionCard(
                  Icons.person_4_outlined,
                  tr("profile_settings"),
                  Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfileSettingsPage(user: widget.user),
                      ),
                    );
                  },
                ),
                _buildActionCard(
                  Icons.map,
                  tr("nearby"),
                  Colors.green,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ListingsMap()),
                    );
                  },
                ),
                _buildActionCard(
                  Icons.chat,
                  tr("messages"),
                  Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => MessagesPage()),
                    );
                  },
                ),
                _buildActionCard(
                  Icons.support_agent,
                  tr("support"),
                  Colors.red,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => UserSupportPage()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            Text(
              tr("recommended_rooms"),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (isLoading) const Center(child: CircularProgressIndicator()),

            if (!isLoading && recommendedListings.isEmpty)
              Center(child: Text(tr("no_nearby_listings"))),

            ...recommendedListings.map((listing) => _buildRoomCard(listing)),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, String imgPath, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  imgPath,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    IconData icon,
    String title,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoomCard(Map<String, dynamic> listing) {
    final id = listing['id'];
    if (id == null) return SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      child: InkWell(
        onTap: () {
          final type = listing['type'] ?? 'hostel';
          Widget detailsPage;
          if (type == "home") {
            detailsPage = HomeDetailsPage(listingId: id);
          } else if (type == "pg") {
            detailsPage = PgDetailsPage(listingId: id);
          } else {
            detailsPage = HostelDetailsPage(listingId: id);
          }

          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => detailsPage),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
                    Row(
  children: [
    // ⭐ Interactive 5-star rating
    StatefulBuilder(
      builder: (context, setStateStar) {
        double currentRating = listing['userRating'] ?? 0.0;
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Rated $newRating stars successfully")),
                );
              },
              child: Icon(
                index < currentRating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 20, // smaller star size
              ),
            );
          }).map((widget) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: widget,
          )).toList(),
        );
      },
    ),

    const SizedBox(width: 12),

    // 💾 Save / unsave toggle
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
                  'image': (listing['images'] != null && listing['images'].isNotEmpty)
                      ? listing['images'][0]
                      : null,
                },
              );
            } else {
              await unsaveListing(userId: widget.user.uid!, listingId: id);
            }

            setStateSave(() {
              isSaved = !isSaved;
              listing['isSaved'] = isSaved;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(isSaved ? "Saved" : "Removed from saved")),
            );
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
      ),
    );
  }
}
