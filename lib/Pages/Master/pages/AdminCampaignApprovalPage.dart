import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:romy/provoiders/user_details_provider.dart';

class AdminCampaignApprovalPage extends StatefulWidget {
  const AdminCampaignApprovalPage({super.key});

  @override
  State<AdminCampaignApprovalPage> createState() => _AdminCampaignApprovalPageState();
}

class _AdminCampaignApprovalPageState extends State<AdminCampaignApprovalPage> {
  final _search = TextEditingController();
  String _query = "";

  Future<void> _approveCampaign(String campaignId, String adminUid) async {
    await FirebaseFirestore.instance.collection("campaigns").doc(campaignId).update({
      "active": true,
      "approvedBy": adminUid,
      "approvedAt": DateTime.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Campaign approved successfully")),
    );
  }

  Future<void> _rejectCampaign(String campaignId) async {
    await FirebaseFirestore.instance.collection("campaigns").doc(campaignId).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Campaign rejected and removed")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.read<UserDetailsProvider>().user!;

    return Scaffold(
      appBar: AppBar(title: const Text("Approve Campaigns")),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: "Search campaign by ID or name",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() => _query = _search.text.trim());
                  },
                ),
              ),
              onSubmitted: (val) => setState(() => _query = val.trim()),
            ),
          ),

          // Campaign List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("campaigns")
                  .where("active", isEqualTo: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;

                // Apply search filter
                final filtered = _query.isEmpty
                    ? docs
                    : docs.where((d) =>
                        d.id.toLowerCase().contains(_query.toLowerCase()) ||
                        d['title'].toString().toLowerCase().contains(_query.toLowerCase()));

                if (filtered.isEmpty) return const Center(child: Text("No pending campaigns found"));

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final camp = filtered.elementAt(i);
                    final data = camp.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  data['imageUrl'],
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(Icons.campaign, size: 40, color: Colors.blueGrey),
                        title: Text(data['title']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (data['description'] != null)
                              Text(data['description'], maxLines: 2, overflow: TextOverflow.ellipsis),
                            Text("Location: ${data['location'] ?? "N/A"}"),
                            Text("Created by: ${data['createdBy']}"),
                            Text("Created at: ${data['createdAt']?.toDate()?.toString().substring(0, 16) ?? ""}"),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () => _approveCampaign(camp.id, admin.uid),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => _rejectCampaign(camp.id),
                            ),
                          ],
                        ),
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
