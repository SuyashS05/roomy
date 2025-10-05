import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:romy/Helpers/LocationHelper.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminCreateCampaignPage extends StatefulWidget {
  final String? campaignId; // null = create, not null = edit
  const AdminCreateCampaignPage({super.key, this.campaignId});

  @override
  State<AdminCreateCampaignPage> createState() => _AdminCreateCampaignPageState();
}

class _AdminCreateCampaignPageState extends State<AdminCreateCampaignPage> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _location = TextEditingController();
  final _imageUrl = TextEditingController();

  double? _lat, _lng;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.campaignId != null) _loadCampaign();
  }

  Future<void> _loadCampaign() async {
    final doc = await FirebaseFirestore.instance
        .collection("campaigns")
        .doc(widget.campaignId)
        .get();
    if (doc.exists) {
      final data = doc.data()!;
      _title.text = data['title'];
      _desc.text = data['description'];
      _location.text = data['location'];
      _imageUrl.text = data['imageUrl'] ?? "";
      _lat = data['lat'];
      _lng = data['lng'];
    }
  }

  Future<void> _pickOnMap() async {
    final loc = await LocationHelper.pickOnMap(context);
    if (loc != null) {
      setState(() {
        _lat = loc["lat"];
        _lng = loc["lng"];
        _location.text = loc["address"];
      });
    }
  }

  /// 🖼️ Opens a bottom sheet to pick an image from Firestore (app_images)
  Future<void> _selectImageFromAppImages() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                "Select an App Image",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
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
                      return const Center(child: Text("No app images available."));
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

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _imageUrl.text = url;
                            });
                            Navigator.pop(context);
                          },
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
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
                                  padding: const EdgeInsets.all(4),
                                  child: Text(
                                    title,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
      },
    );
  }

  Future<void> _saveCampaign() async {
    if (_title.text.isEmpty || _lat == null || _lng == null) return;

    setState(() => _loading = true);

    final user = FirebaseAuth.instance.currentUser;
    final data = {
      "title": _title.text.trim(),
      "description": _desc.text.trim(),
      "location": _location.text.trim(),
      "lat": _lat,
      "lng": _lng,
      "imageUrl": _imageUrl.text.trim(),
      "createdBy": user?.uid ?? "admin",
      "updatedAt": DateTime.now(),
      "active": true,
    };

    if (widget.campaignId == null) {
      data["createdAt"] = DateTime.now();
      await FirebaseFirestore.instance.collection("campaigns").add(data);
    } else {
      await FirebaseFirestore.instance
          .collection("campaigns")
          .doc(widget.campaignId)
          .update(data);
    }

    setState(() => _loading = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(widget.campaignId == null ? "Create Campaign" : "Edit Campaign")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(controller: _title, decoration: const InputDecoration(labelText: "Title")),
            TextField(controller: _desc, decoration: const InputDecoration(labelText: "Description")),
            TextField(controller: _location, decoration: const InputDecoration(labelText: "Location")),
            TextField(controller: _imageUrl, decoration: const InputDecoration(labelText: "Image URL")),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectImageFromAppImages,
                    icon: const Icon(Icons.photo_library),
                    label: const Text("Select from App Images"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickOnMap,
                    icon: const Icon(Icons.map),
                    label: const Text("Pick on Map"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_imageUrl.text.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(_imageUrl.text, height: 150, fit: BoxFit.cover),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _saveCampaign,
              child: _loading
                  ? const CircularProgressIndicator()
                  : Text(widget.campaignId == null ? "Save Campaign" : "Update Campaign"),
            ),
          ],
        ),
      ),
    );
  }
}
