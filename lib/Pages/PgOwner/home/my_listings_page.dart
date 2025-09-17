import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

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
          _buildListingCard("1BHK Apartment", "₹8000/month", "City Center • WiFi", "https://picsum.photos/210"),
          _buildListingCard("Shared PG", "₹4000/month", "Near College • Meals Included", "https://picsum.photos/211"),
          _buildListingCard("Luxury Flat", "₹20000/month", "3BHK • Furnished", "https://picsum.photos/212"),
        ],
      ),
    );
  }

  Widget _buildListingCard(String title, String price, String details, String imageUrl) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            child: Image.network(imageUrl, width: 100, height: 100, fit: BoxFit.cover),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(price, style: const TextStyle(fontSize: 14, color: Colors.green)),
                  const SizedBox(height: 4),
                  Text(details, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text("Edit"),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                        label: const Text("Delete", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
