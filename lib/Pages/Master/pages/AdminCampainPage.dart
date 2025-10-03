import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:romy/Pages/Master/pages/AdminCampaignDetailPage.dart';
import 'package:romy/Pages/Master/pages/AdminCreateCampaignPage.dart';

class AdminCampaignsPage extends StatefulWidget {
  const AdminCampaignsPage({super.key});

  @override
  State<AdminCampaignsPage> createState() => _AdminCampaignsPageState();
}

class _AdminCampaignsPageState extends State<AdminCampaignsPage> {
  String _search = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Campaigns"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminCreateCampaignPage()),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Search by title or ID...",
              ),
              onChanged: (val) {
                setState(() => _search = val.toLowerCase());
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("campaigns")
                  .orderBy("createdAt", descending: true)
                  .snapshots(),
              builder: (ctx, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs.where((doc) {
                  final title = doc['title'].toString().toLowerCase();
                  final id = doc.id.toLowerCase();
                  return title.contains(_search) || id.contains(_search);
                }).toList();

                if (docs.isEmpty) return const Center(child: Text("No campaigns found"));

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (ctx, i) {
                    final camp = docs[i];
                    return Card(
                      child: ListTile(
                        leading: camp['imageUrl'] != null && camp['imageUrl'] != ""
                            ? CircleAvatar(backgroundImage: NetworkImage(camp['imageUrl']))
                            : const CircleAvatar(child: Icon(Icons.campaign)),
                        title: Text(camp['title']),
                        subtitle: Text("By: ${camp['createdBy']}"),
                        trailing: PopupMenuButton<String>(
                          onSelected: (val) {
                            if (val == "edit") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AdminCreateCampaignPage(campaignId: camp.id),
                                ),
                              );
                            } else if (val == "delete") {
                              FirebaseFirestore.instance.collection("campaigns").doc(camp.id).delete();
                            }
                          },
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(value: "edit", child: Text("Edit")),
                            const PopupMenuItem(value: "delete", child: Text("Delete")),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AdminCampaignDetailPage(campaignId: camp.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
