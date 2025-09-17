import 'package:flutter/material.dart';

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Saved Rooms")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildRoomCard(
            "Luxury Apartment",
            "₹15000/month",
            "3BHK • Near IT Park",
            "https://picsum.photos/203",
          ),
          _buildRoomCard(
            "Budget Hostel",
            "₹4000/month",
            "Boys • Free WiFi",
            "https://picsum.photos/204",
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(
      String title, String price, String details, String imageUrl) {
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
