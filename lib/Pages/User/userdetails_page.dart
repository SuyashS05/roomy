import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UserDetailsPage extends StatelessWidget {
  final String userId;
  const UserDetailsPage({super.key, required this.userId});

  Future<DocumentSnapshot<Map<String, dynamic>>> _getUser() {
    return FirebaseFirestore.instance
        .collection('roomFinderProfiles')
        .doc(userId)
        .get();
  }

  // Open phone dialer
  void _callPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint("Can't call $phone");
    }
  }

  // Open WhatsApp chat
  void _openWhatsApp(String phone) async {
    final url = Uri.parse(
      'https://wa.me/$phone',
    ); // phone should be in international format
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Can't open WhatsApp for $phone");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Details")),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _getUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("User not found"));
          }

          final userData = snapshot.data!.data()!;
          final displayName = userData['displayName'] ?? "Roommate profile";
          const profileUrl = "";
          const bio = "Contact and private profile details are not shown here.";
          final hobbies = (userData['hobbies'] ?? []).join(', ');
          final languages = (userData['languages'] ?? []).join(', ');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      profileUrl.isNotEmpty ? NetworkImage(profileUrl) : null,
                  child:
                      profileUrl.isEmpty
                          ? const Icon(Icons.person, size: 60)
                          : null,
                ),
                const SizedBox(height: 16),
                Text(
                  displayName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(height: 16),
                const Divider(height: 32),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "About",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(bio),
                        if (hobbies.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text("Hobbies: $hobbies"),
                        ],
                        if (languages.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text("Languages: $languages"),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
