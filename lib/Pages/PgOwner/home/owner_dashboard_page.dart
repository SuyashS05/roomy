import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:romy/Models/Users.dart';
import 'package:romy/Pages/ListingsMap.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:romy/Pages/PgOwner/Pages/AnalysisChart.dart';
import 'package:romy/Pages/PgOwner/Pages/RoomOwnerPaymentPage.dart';
import 'package:romy/Pages/PgOwner/Pages/RoomOwnerSupportPage.dart';
import 'package:romy/Pages/PgOwner/Pages/mylistings_widgits.dart';
import 'package:romy/Pages/User/home/mapPreviewUsers.dart';

class OwnerDashboardPage extends StatelessWidget {
  final UserModel user;
  const OwnerDashboardPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🌍 Mini Map Container
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ListingsMap()),
              );
            },
            child: const MapPreviewWidget(),
          ),

          const SizedBox(height: 20),

          // 📊 Summary Cards
          Row(
            children: [
              Expanded(
                child: FutureBuilder<QuerySnapshot>(
                  future:
                      FirebaseFirestore.instance
                          .collection("listings")
                          .where("ownerUid", isEqualTo: user.uid)
                          .get(),
                  builder: (context, snapshot) {
                    String totalListings = "0";
                    if (snapshot.hasData) {
                      totalListings = snapshot.data!.docs.length.toString();
                    }
                    return _buildSummaryCard(
                      Icons.home,
                      "total_listings".tr(),
                      totalListings,
                      Colors.blue,
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              _buildSummaryCard(
                Icons.bookmark,
                "booked_rooms".tr(),
                "0",
                Colors.green,
              ),
              const SizedBox(width: 8),
              _buildSummaryCard(
                Icons.pending_actions,
                "pending".tr(),
                "0",
                Colors.orange,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 📈 Occupancy Chart Placeholder
          // _buildChartPlaceholder(context),
          buildOccupancyChart(context),

          const SizedBox(height: 20),

          // 📝 Recent Listings
          Text(
            "recent_listings".tr(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          MyListingsWidget(user: user),

          const SizedBox(height: 20),

          // ⚡ Quick Actions
          Text(
            "quick_actions".tr(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildQuickAction(
                Icons.payment,
                "payments".tr(),
                Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RoomOwnerPaymentPage()),
                  );
                },
              ),
              _buildQuickAction(
                Icons.support_agent,
                "support".tr(),
                Colors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RoomOwnerSupportPage()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartPlaceholder(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.indigo.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          "occupancy_chart_placeholder".tr(),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildListingCard(
    String title,
    String price,
    String details,
    String imageUrl,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
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
                ],
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    IconData icon,
    String label,
    Color color, {
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 150,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
