import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:romy/Helpers/LocationHelper.dart';
import 'package:romy/provoiders/user_details_provider.dart';

class UserCreateCampaignPage extends StatefulWidget {
  const UserCreateCampaignPage({super.key});

  @override
  State<UserCreateCampaignPage> createState() => _UserCreateCampaignPageState();
}

class _UserCreateCampaignPageState extends State<UserCreateCampaignPage> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _location = TextEditingController();
  final _imageUrl = TextEditingController();

  double? _lat, _lng;
  bool _loading = false;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _location.dispose();
    _imageUrl.dispose();
    super.dispose();
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

  Widget _imagePreview() {
    final url = _imageUrl.text.trim();
    if (url.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: SizedBox(
        height: 160,
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (ctx, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                child: const Center(child: Text("Invalid image URL")),
              );
            },
            loadingBuilder: (ctx, child, progress) {
              if (progress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }

  Future<void> _requestCampaign() async {
    if (_title.text.isEmpty || _lat == null || _lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter title and pick a location")),
      );
      return;
    }

    final user = context.read<UserDetailsProvider>().user!;

    setState(() => _loading = true);

    final data = {
      "title": _title.text.trim(),
      "description": _desc.text.trim(),
      "location": _location.text.trim(),
      "lat": _lat,
      "lng": _lng,
      "imageUrl": _imageUrl.text.trim(), // <-- image url saved here (can be empty)
      "createdBy": user.uid,
      "createdByRole": "user",
      "createdAt": DateTime.now(),
      "active": false, // requires admin approval
    };

    try {
      await FirebaseFirestore.instance.collection("campaigns").add(data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Campaign request submitted for approval")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Request New Campaign")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _desc,
              decoration: const InputDecoration(labelText: "Description"),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _location,
              readOnly: true,
              decoration: const InputDecoration(labelText: "Location"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _imageUrl,
              decoration: const InputDecoration(
                labelText: "Image URL (optional)",
                hintText: "https://example.com/image.jpg",
              ),
              keyboardType: TextInputType.url,
              onChanged: (_) => setState(() {}), // refresh preview
            ),
            _imagePreview(),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _pickOnMap,
              icon: const Icon(Icons.map),
              label: const Text("Pick on Map"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _requestCampaign,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Submit Request"),
            ),
          ],
        ),
      ),
    );
  }
}
