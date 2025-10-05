import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:romy/Pages/User/pages/CampaignDetailPage.dart';
import 'package:romy/Pages/User/pages/UserCreateCampaignPage.dart';
import 'package:romy/provoiders/user_details_provider.dart';

class CampaignsPage extends StatefulWidget {
  const CampaignsPage({super.key});

  @override
  State<CampaignsPage> createState() => _CampaignsPageState();
}

class _CampaignsPageState extends State<CampaignsPage> {
  final _searchController = TextEditingController();
  String _query = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<UserDetailsProvider>().user!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Find Roommate Campaigns"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserCreateCampaignPage()),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search by campaign name or ID",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = "");
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (val) {
                setState(() => _query = val.trim().toLowerCase());
              },
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("campaigns")
            .where("active", isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          // Filter by search
          var campaigns = _query.isEmpty
              ? docs
              : docs.where((d) {
                  final title = d['title'].toString().toLowerCase();
                  final id = d.id.toLowerCase();
                  return title.contains(_query) || id.contains(_query);
                }).toList();

          if (campaigns.isEmpty) {
            return const Center(child: Text("No campaigns found"));
          }

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("campaign_participants")
                .doc() // not specific campaign, we’ll get whole collection
                .snapshots(),
            builder: (context, snap) {
              return FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance.collection("campaign_participants").get(),
                builder: (context, participantSnapshot) {
                  if (!participantSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final participantDocs = participantSnapshot.data!.docs;
                  final joinedCampaigns = <String>{};

                  for (var p in participantDocs) {
                    final data = p.data() as Map<String, dynamic>;
                    if (data.containsKey(user.uid)) {
                      joinedCampaigns.add(p.id);
                    }
                  }

                  // Sort: joined campaigns at top
                  campaigns.sort((a, b) {
                    final aJoined = joinedCampaigns.contains(a.id);
                    final bJoined = joinedCampaigns.contains(b.id);
                    if (aJoined && !bJoined) return -1;
                    if (!aJoined && bJoined) return 1;
                    return 0;
                  });

                  return ListView.builder(
                    itemCount: campaigns.length,
                    itemBuilder: (ctx, i) {
                      final camp = campaigns[i];
                      final imageUrl = camp['imageUrl'] ?? "";
                      final isJoined = joinedCampaigns.contains(camp.id);

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: imageUrl.isNotEmpty
                              ? SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(imageUrl, fit: BoxFit.cover),
                                  ),
                                )
                              : const CircleAvatar(child: Icon(Icons.campaign)),
                          title: Text(camp['title']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(camp['description']),
                              const SizedBox(height: 4),
                              Text("Location: ${camp['location']}"),
                              Text("ID: ${camp.id.substring(0, 6)}"),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: isJoined
                              ? const Chip(label: Text("Joined"))
                              : ElevatedButton(
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection("campaign_participants")
                                        .doc(camp.id)
                                        .set({
                                      user.uid: {
                                        "userId": user.uid,
                                        "joinedAt": DateTime.now(),
                                      }
                                    }, SetOptions(merge: true));
                                  },
                                  child: const Text("Join"),
                                ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CampaignDetailPage(campaign: camp),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
