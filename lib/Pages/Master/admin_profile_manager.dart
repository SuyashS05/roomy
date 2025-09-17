import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminProfileManager extends StatefulWidget {
  const AdminProfileManager({super.key});

  @override
  State<AdminProfileManager> createState() => _AdminProfileManagerState();
}

class _AdminProfileManagerState extends State<AdminProfileManager> {
  final _urlController = TextEditingController();

  Future<void> _addProfileImage() async {
    if (_urlController.text.trim().isEmpty) return;
    await FirebaseFirestore.instance.collection('profiles').add({
      'url': _urlController.text.trim(),
      'addedAt': FieldValue.serverTimestamp(),
    });
    _urlController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile image added")),
    );
  }

  Future<void> _deleteProfileImage(String id) async {
    await FirebaseFirestore.instance.collection('profiles').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin: Manage Profile Images")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: "Profile Image URL",
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addProfileImage,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('profiles').snapshots(),
                builder: (ctx, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data!.docs;
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: docs.length,
                    itemBuilder: (ctx, i) {
                      final doc = docs[i];
                      final url = doc['url'] as String;
                      return Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(url),
                          ),
                          Positioned(
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteProfileImage(doc.id),
                            ),
                          )
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
