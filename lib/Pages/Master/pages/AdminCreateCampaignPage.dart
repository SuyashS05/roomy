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
    final doc = await FirebaseFirestore.instance.collection("campaigns").doc(widget.campaignId).get();
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
      await FirebaseFirestore.instance.collection("campaigns").doc(widget.campaignId).update(data);
    }

    setState(() => _loading = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.campaignId == null ? "Create Campaign" : "Edit Campaign")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(controller: _title, decoration: const InputDecoration(labelText: "Title")),
            TextField(controller: _desc, decoration: const InputDecoration(labelText: "Description")),
            TextField(controller: _location, decoration: const InputDecoration(labelText: "Location")),
            TextField(controller: _imageUrl, decoration: const InputDecoration(labelText: "Image URL")),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _pickOnMap,
              icon: const Icon(Icons.map),
              label: const Text("Pick on Map"),
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
