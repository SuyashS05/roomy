import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoomOwnerDetailsPage extends StatelessWidget {
  final Map<String, dynamic> owner;
  final Map<String, dynamic>? user;

  const RoomOwnerDetailsPage({
    super.key,
    required this.owner,
    required this.user,
  });

  void _showDocument(BuildContext context, String url, String title) {
    if (url.isEmpty) return;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: InteractiveViewer(
          child: Image.network(url, fit: BoxFit.contain),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = owner["adminCheck"] ?? "pending";

    return Scaffold(
      appBar: AppBar(title: Text(owner["aadhaarName"] ?? "Room Owner")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(user?["profileUrl"] ??
                      "https://via.placeholder.com/150"),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    user?["displayName"] ?? "N/A",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Chip(
                  label: Text(status.toUpperCase()),
                  backgroundColor: status == "approved"
                      ? Colors.green[100]
                      : status == "rejected"
                          ? Colors.red[100]
                          : Colors.orange[100],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // User Info
            Text("👤 User Info",
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _infoTile("Email", user?["email"]),
            _infoTile("Alt Email", user?["email2"]),
            _infoTile("Phone", user?["phone"]),
            _infoTile("Age", user?["age"]?.toString()),
            _infoTile("DOB",
                user?["dob"] != null ? (user!["dob"] as Timestamp).toDate().toString() : "N/A"),
            _infoTile("City", user?["city"]),
            _infoTile("Address", user?["address"]),
            const Divider(),

            // Verification Info
            Text("📄 Verification Info",
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _infoTile("Aadhaar Name", owner["aadhaarName"]),
            _infoTile("Aadhaar Number", owner["aadhaarNumber"]),
            _infoTile("PAN Number", owner["panNumber"]),
            _infoTile("WhatsApp", owner["whatsapp"]),
            _infoTile("Instagram", owner["instagram"]),
            _infoTile("Submitted At",
                owner["submittedAt"] != null ? (owner["submittedAt"] as Timestamp).toDate().toString() : "N/A"),
            if ((owner["unverifiedReason"] ?? "").toString().isNotEmpty)
              _infoTile("Unverified Reason", owner["unverifiedReason"]),
            const SizedBox(height: 12),

            // Document Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if ((owner["addressProofUrl"] ?? "").isNotEmpty)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.remove_red_eye),
                    label: const Text("Address Proof"),
                    onPressed: () => _showDocument(
                        context, owner["addressProofUrl"], "Address Proof"),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(value ?? "N/A",
                style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
