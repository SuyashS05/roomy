import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AllRoomOwnersPage extends StatelessWidget {
  const AllRoomOwnersPage({super.key});

  // Bottom sheet to show detailed info
  void _showOwnerDetails(BuildContext context, Map<String, dynamic> ownerData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(ownerData['profileUrl'] ?? ""),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                ownerData['displayName'] ?? "Unnamed",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                ownerData['email'] ?? "",
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionButton(Icons.phone, Colors.green, "Call", () {
                  _callNumber(ownerData['phone']);
                }),
                _actionButton(Icons.message, Colors.orange, "SMS", () {
                  _sendSMS(ownerData['phone']);
                }),
                _actionButton(Icons.chat, Colors.teal, "WhatsApp", () {
                  _sendWhatsApp(ownerData['phone']);
                }),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: Text(ownerData['address'] ?? "Address not set"),
            ),
            ListTile(
              leading: const Icon(Icons.cake),
              title: Text("Age: ${ownerData['age'] ?? 'N/A'}"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, Color color, String label, VoidCallback onTap) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: IconButton(
            icon: Icon(icon, color: color),
            onPressed: onTap,
          ),
        ),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }

  // Direct call
  void _callNumber(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final url = 'tel:$phone';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  // Direct SMS
  void _sendSMS(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final url = 'sms:$phone';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  // Direct WhatsApp
  void _sendWhatsApp(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final url = 'https://wa.me/$phone';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersRef = FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'roomOwner');

    return Scaffold(
      appBar: AppBar(title: const Text("All Room Owners")),
      body: StreamBuilder<QuerySnapshot>(
        stream: usersRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text("No Room Owners found."));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final owner = docs[index];
              final ownerData = owner.data() as Map<String, dynamic>;

              return GestureDetector(
                onTap: () => _showOwnerDetails(context, ownerData),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage:
                            NetworkImage(ownerData['profileUrl'] ?? ""),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        ownerData['displayName'] ?? "Unnamed",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ownerData['email'] ?? "",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
