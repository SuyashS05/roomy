import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:romy/Helpers/nearbyListing.dart';
import 'package:romy/Models/Users.dart';
import 'package:romy/Pages/ListingsMap.dart';
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
      final listings = await fetchNearbyListings(widget.user.lat!, widget.user.lng!);
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => ListingsMap()));
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
                          builder: (_) =>
                              ProfileSettingsPage(user: widget.user)),
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

            ...recommendedListings.map(
              (listing) => _buildRoomCard(
                listing['title'] ?? tr("unknown_room"),
                "₹${listing['basePrice'] ?? 'N/A'}/month",
                listing['amenities'] != null
                    ? (listing['amenities'] as Map).keys.join(" • ")
                    : "",
                listing['images'] != null && listing['images'].isNotEmpty
                    ? listing['images'][0]
                    : "https://picsum.photos/200",
              ),
            ),
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
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
      IconData icon, String title, Color color,
      {VoidCallback? onTap}) {
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
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoomCard(String title, String price, String details, String imageUrl) {
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
                      style:
                          const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(price,
                      style: const TextStyle(fontSize: 14, color: Colors.green)),
                  const SizedBox(height: 4),
                  Text(details,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
