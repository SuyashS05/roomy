import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

class RoomSearchWidget extends StatefulWidget {
  final void Function(Map<String, dynamic>)? onRoomTap;

  const RoomSearchWidget({super.key, this.onRoomTap});

  @override
  State<RoomSearchWidget> createState() => _RoomSearchWidgetState();
}

class _RoomSearchWidgetState extends State<RoomSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = false;

  Future<void> _searchRooms(String query) async {
    if (query.length < 3) {
      setState(() {
        _results = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('listings')
          .where('published', isEqualTo: true)
          .get();

      final rooms = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .where((room) {
        final q = query.toLowerCase();
        final title = (room['title'] ?? '').toString().toLowerCase();
        final type = (room['type'] ?? '').toString().toLowerCase();
        final address = (room['fullAddress'] ?? '').toString().toLowerCase();
        final landmark = (room['landmark'] ?? '').toString().toLowerCase();
        final listingId = (room['listingId'] ?? '').toString().toLowerCase();

        return title.contains(q) ||
            type.contains(q) ||
            address.contains(q) ||
            landmark.contains(q) ||
            listingId.contains(q);
      }).toList();

      setState(() {
        _results = rooms;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error searching rooms: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🔹 Elevated search bar with shadow
        Material(
          elevation: 6,
          shadowColor: Colors.black26,
          borderRadius: BorderRadius.circular(16),
          child: TextField(
            controller: _searchController,
            onChanged: _searchRooms,
            decoration: InputDecoration(
              hintText: tr("ListingSearch"), // Easy Localization key
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 🔹 Loading indicator
        if (_isLoading)
          const Center(child: CircularProgressIndicator()),

        // 🔹 No results message
        if (!_isLoading &&
            _results.isEmpty &&
            _searchController.text.length >= 3)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              tr("no_rooms_found"),
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),

        // 🔹 Results list with ExpansionTile
        if (_results.isNotEmpty)
          ..._results.map(
            (room) => Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              shadowColor: Colors.black26,
              child: ExpansionTile(
                leading: room['images'] != null && room['images'].isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          room['images'][0],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(Icons.home, size: 60, color: Colors.grey),
                title: Text(room['title'] ?? tr("unknown_room")),
                subtitle: Text(
                    "${tr("price")}: ₹${room['basePrice'] ?? 'N/A'}/month"),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (room['type'] != null)
                          Text("${tr("type")}: ${room['type']}"),
                        if (room['fullAddress'] != null)
                          Text("${tr("address")}: ${room['fullAddress']}"),
                        if (room['landmark'] != null)
                          Text("${tr("landmark")}: ${room['landmark']}"),
                        if (room['amenities'] != null)
                          Text(
                              "${tr("amenities")}: ${(room['amenities'] as Map).keys.join(", ")}"),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              if (widget.onRoomTap != null) {
                                widget.onRoomTap!(room);
                              }
                            },
                            child: Text(tr("view_details")),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
