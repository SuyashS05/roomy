import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:romy/Helpers/LogOut_confim.dart';
import 'package:romy/Helpers/Notifi_Snackbar.dart';

class HostelDetailsPage extends StatefulWidget {
  final String user;
  final String listingId;

  const HostelDetailsPage({super.key, required this.listingId, required this.user});

  @override
  State<HostelDetailsPage> createState() => _HostelDetailsPageState();
}

class _HostelDetailsPageState extends State<HostelDetailsPage> {
  bool isOwner = false;
  Map<String, dynamic>? hostelData;
  Map<String, dynamic>? floorsData;

  @override
  void initState() {
    super.initState();
    _loadHostelDetails();
  }

  Future<void> _loadHostelDetails() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final listingSnap = await FirebaseFirestore.instance
        .collection('listings')
        .doc(widget.listingId)
        .get();

    final hostelSnap = await FirebaseFirestore.instance
        .collection('hostels')
        .doc(widget.listingId)
        .get();

    setState(() {
      hostelData = listingSnap.data();
      floorsData = hostelSnap.data()?['floors'] as Map<String, dynamic>? ?? {};
      isOwner = hostelData?['ownerUid'] == currentUser?.uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (hostelData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final images = (hostelData?['images'] as List<dynamic>? ?? []);
    final amenities = hostelData?['amenities'] as Map<String, dynamic>? ?? {};
    final title = hostelData?['title'] ?? '';
    final address = hostelData?['address']?['fullAddress'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: isOwner
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    AppNotifier.show(
                      context,
                      message: "Edit Hostel",
                      type: NotificationType.info,
                    );
                  },
                )
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Image Carousel ---
            if (images.isNotEmpty)
              SizedBox(
                height: 200,
                child: PageView.builder(
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(images[index], fit: BoxFit.cover),
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(address, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),

            // --- Amenities ---
            Text('Amenities', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 12,
              children: amenities.entries.map((e) {
                if (e.value == true) {
                  return Chip(label: Text(e.key));
                }
                return const SizedBox.shrink();
              }).toList(),
            ),
            const SizedBox(height: 16),

            // --- Floors & Rooms ---
            Text('Floors & Rooms', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...(floorsData?.entries ?? []).map((floorEntry) {
              final floor = floorEntry.value as Map<String, dynamic>;
              final rooms = floor['rooms'] as Map<String, dynamic>? ?? {};
              return ExpansionTile(
                title: Row(
                  children: [
                    Expanded(child: Text(floor['name'] ?? 'Floor')),
                    if (isOwner)
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          AppNotifier.show(
                            context,
                            message: "Edit Floor",
                            type: NotificationType.info,
                          );
                        },
                      ),
                  ],
                ),
                children: rooms.entries.map((roomEntry) {
                  final room = roomEntry.value as Map<String, dynamic>;
                  final cots = room['cots'] as Map<String, dynamic>? ?? {};
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                  child: Text(room['name'] ?? 'Room',
                                      style: const TextStyle(fontWeight: FontWeight.bold))),
                              if (isOwner)
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    AppNotifier.show(
                                      context,
                                      message: "Edit Room",
                                      type: NotificationType.info,
                                    );
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...cots.entries.map((cotEntry) {
                            final cot = cotEntry.value as Map<String, dynamic>;
                            final status = cot['status'] ?? 'available';
                            final price = cot['pricePerMonth'] ?? 0;
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text('${cotEntry.key} - ₹$price'),
                              subtitle: Text(
                                status == 'available' ? 'Available' : 'Occupied',
                                style: TextStyle(
                                  color: status == 'available' ? Colors.green : Colors.red,
                                ),
                              ),
                              trailing: isOwner
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () {
                                            AppNotifier.show(
                                              context,
                                              message: "Edit Cot",
                                              type: NotificationType.info,
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () async {
                                            final confirm = await showConfirmationDialog(
                                              context,
                                              title: 'Delete Cot',
                                              message: 'Are you sure you want to delete this cot?',
                                            );
                                            if (confirm == true) {
                                              AppNotifier.show(
                                                context,
                                                message: 'Deleting cot...',
                                                type: NotificationType.warning,
                                              );
                                              // TODO: Add delete logic here
                                            }
                                          },
                                        ),
                                      ],
                                    )
                                  : status == 'available'
                                      ? ElevatedButton(
                                          onPressed: () {
                                            AppNotifier.show(
                                              context,
                                              message: "Booking cot ${cotEntry.key}",
                                              type: NotificationType.success,
                                            );
                                          },
                                          child: const Text('Book'),
                                        )
                                      : null,
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
