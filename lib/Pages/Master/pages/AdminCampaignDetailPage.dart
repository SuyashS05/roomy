import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCampaignDetailPage extends StatelessWidget {
  final String campaignId;
  const AdminCampaignDetailPage({super.key, required this.campaignId});

  @override
  Widget build(BuildContext context) {
    final campaignRef = FirebaseFirestore.instance.collection("campaigns").doc(campaignId);

    return Scaffold(
      appBar: AppBar(title: const Text("Campaign Details")),
      body: FutureBuilder<DocumentSnapshot>(
        future: campaignRef.get(),
        builder: (ctx, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty)
                  Image.network(data['imageUrl'], height: 200, width: double.infinity, fit: BoxFit.cover),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['title'], style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text(data['description'] ?? ""),
                      const SizedBox(height: 8),
                      Text("Location: ${data['location'] ?? "N/A"}"),
                      Text("Created by: ${data['createdById']}"),
                      Text("Active: ${data['active']}"),
                      const SizedBox(height: 16),
                      const Divider(),
                      const Text("Joined Users", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),

                // 🔥 Stream joined users
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("campaign_participants")
                      .doc(campaignId)
                      .snapshots(),
                  builder: (ctx, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    if (!snapshot.data!.exists) return const Center(child: Text("No users joined yet"));

                    final participants = snapshot.data!.data() as Map<String, dynamic>;
                    final users = participants.values.toList();

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: users.length,
                      itemBuilder: (ctx, i) {
                        final user = users[i];
                        return ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(user['userId']),
                          subtitle: Text("Joined at: ${user['joinedAt']?.toDate().toString().substring(0, 16)}"),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
