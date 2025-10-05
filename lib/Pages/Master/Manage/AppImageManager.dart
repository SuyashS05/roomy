import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAppImageManager extends StatefulWidget {
  const AdminAppImageManager({super.key});

  @override
  State<AdminAppImageManager> createState() => _AdminAppImageManagerState();
}

class _AdminAppImageManagerState extends State<AdminAppImageManager> {
  final _urlController = TextEditingController();
  final _titleController = TextEditingController();

  Future<void> _addAppImage() async {
    if (_urlController.text.trim().isEmpty) return;

    await FirebaseFirestore.instance.collection('app_images').add({
      'url': _urlController.text.trim(),
      'title': _titleController.text.trim().isEmpty
          ? 'Untitled Image'
          : _titleController.text.trim(),
      'addedAt': FieldValue.serverTimestamp(),
    });

    _urlController.clear();
    _titleController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("App image added successfully")),
    );
  }

  Future<void> _deleteAppImage(String id) async {
    await FirebaseFirestore.instance.collection('app_images').doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("App image deleted")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin: Manage App Images")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: "Image Title (optional)",
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: "App Image URL",
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.blue, size: 32),
                  onPressed: _addAppImage,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('app_images')
                    .orderBy('addedAt', descending: true)
                    .snapshots(),
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text("No app images added yet."),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: docs.length,
                    itemBuilder: (ctx, i) {
                      final doc = docs[i];
                      final url = doc['url'] as String;
                      final title = doc['title'] ?? '';

                      return Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey[200],
                              image: DecorationImage(
                                image: NetworkImage(url),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              color: Colors.black.withOpacity(0.5),
                              padding: const EdgeInsets.all(6),
                              child: Text(
                                title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteAppImage(doc.id),
                            ),
                          ),
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
