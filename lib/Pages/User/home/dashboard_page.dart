import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:romy/Pages/ListingsMap.dart';
import 'package:romy/Pages/pp/GoogleMap.dart';

class DashboardPage extends StatelessWidget {
  final User user;
  const DashboardPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildCard(
                  context,
                  "Find Room",
                  "assets/img/ViewRoom.png",
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MapSample()),
                  ),
                ),
                const SizedBox(width: 8),
                _buildCard(
                  context,
                  "Find Roommates",
                  "assets/img/ViewRoomate.png",
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>  MapSample(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text("Quick Actions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              children: [
                _buildActionCard(Icons.search, "Find Rooms", Colors.blue),
                _buildActionCard(Icons.map, "Nearby", Colors.green, onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ListingsMap()),
                  );
                }),
                _buildActionCard(Icons.chat, "Messages", Colors.orange),
                _buildActionCard(Icons.support_agent, "Support", Colors.red),
              ],
            ),
            const SizedBox(height: 20),
            const Text("Recommended Rooms",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildRoomCard(
              "Cozy PG near University",
              "₹5000/month",
              "WiFi • AC • Meals",
              "https://picsum.photos/200",
            ),
            _buildRoomCard(
              "2BHK Flat in City Center",
              "₹12000/month",
              "Fully Furnished",
              "https://picsum.photos/201",
            ),
            _buildRoomCard(
              "Shared Room in Hostel",
              "₹3500/month",
              "Girls Only • WiFi",
              "https://picsum.photos/202",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
      BuildContext context, String title, String imgPath, VoidCallback onTap) {
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
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(IconData icon, String title, Color color, {VoidCallback? onTap}) {
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
              Text(title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoomCard(
    String title,
    String price,
    String details,
    String imageUrl,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            child: Image.network(imageUrl,
                width: 100, height: 100, fit: BoxFit.cover),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
