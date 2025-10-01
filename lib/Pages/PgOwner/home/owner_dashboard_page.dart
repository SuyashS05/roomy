import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:romy/Pages/ListingsMap.dart';
import 'package:romy/Pages/MapPreviewCard.dart';

class OwnerDashboardPage extends StatelessWidget {
  final User user;
  const OwnerDashboardPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Owner Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("No new notifications")),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🌍 Mini Map Container
          const MapPreviewCard(),

          const SizedBox(height: 20),

          // 📊 Summary Cards
          Row(
            children: [
              _buildSummaryCard(Icons.home, "Total Listings", "12", Colors.blue),
              const SizedBox(width: 8),
              _buildSummaryCard(Icons.bookmark, "Booked Rooms", "7", Colors.green),
              const SizedBox(width: 8),
              _buildSummaryCard(Icons.pending_actions, "Pending", "5", Colors.orange),
            ],
          ),

          const SizedBox(height: 20),

          // 📈 Occupancy Chart Placeholder
          _buildChartPlaceholder(),

          const SizedBox(height: 20),

          // 📝 Recent Listings
          const Text(
            "Recent Listings",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildListingCard(
              "1BHK Apartment", "₹8000/month", "City Center • WiFi", "https://picsum.photos/210"),
          _buildListingCard(
              "Shared PG", "₹4000/month", "Near College • Meals Included", "https://picsum.photos/211"),
          _buildListingCard(
              "Luxury Flat", "₹20000/month", "3BHK • Furnished", "https://picsum.photos/212"),

          const SizedBox(height: 20),

          // ⚡ Quick Actions
          const Text(
            "Quick Actions",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildQuickAction(Icons.add_business, "Add Listing", Colors.blue),
              _buildQuickAction(Icons.people, "Manage Tenants", Colors.green),
              _buildQuickAction(Icons.payment, "Payments", Colors.orange),
              _buildQuickAction(Icons.support_agent, "Support", Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      IconData icon, String title, String value, Color color) {
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
            Text(title,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildChartPlaceholder() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.indigo.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text(
          "📊 Occupancy / Revenue Chart\n(Static Placeholder)",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildListingCard(
      String title, String price, String details, String imageUrl) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
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
                      style: const TextStyle(
                          fontSize: 14, color: Colors.green)),
                  const SizedBox(height: 4),
                  Text(details,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          )
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, Color color) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
