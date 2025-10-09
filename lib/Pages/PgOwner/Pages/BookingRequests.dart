import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;

class BookingRequestsSection extends StatelessWidget {
  final String hostelId;
  final bool isOwner;
  final Future<void> Function(String requestId, Map<String, dynamic> req)
      onAction;

  const BookingRequestsSection({
    super.key,
    required this.hostelId,
    required this.isOwner,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOwner) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Booking Requests",
          style: Theme.of(context).textTheme.headlineLarge!,
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('bookingRequests')
              .where('hostelId', isEqualTo: hostelId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();
            final requests = snapshot.data!.docs;

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: requests.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final req = requests[index].data() as Map<String, dynamic>;
                return FutureBuilder<DocumentSnapshot>(
                  future:
                      _firestore.collection('users').doc(req['userUid']).get(),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData) return const SizedBox();
                    final user =
                        userSnapshot.data!.data() as Map<String, dynamic>?;

                    return ListTile(
                      title: Text(user?['displayName'] ?? req['userUid']),
                      subtitle: Text(
                        "Contact: ${user?['contactNumber'] ?? 'N/A'}\nFloor: ${req['floorId']}, Room: ${req['roomId']}, Cot: ${req['cotId']}",
                      ),
                      trailing: Text(
                        (req['status'] ?? 'pending').toUpperCase(),
                        style: TextStyle(
                          color: req['status'] == 'pending'
                              ? Colors.orange
                              : req['status'] == 'approved'
                                  ? Colors.green
                                  : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () => onAction(requests[index].id, req),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}

Future<void> showBookingRequestActions(
    BuildContext context,
    String requestId,
    Map<String, dynamic> req,
  ) async {
  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Manage Booking Request"),
      content: Text(
        "User ${req['userUid']} requested Floor ${req['floorId']}, Room ${req['roomId']}, Cot ${req['cotId']}",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () async {
            await _firestore
                .collection('bookingRequests')
                .doc(requestId)
                .update({'status': 'approved'});
            Navigator.pop(context);
          },
          child: const Text("Approve"),
        ),
        TextButton(
          onPressed: () async {
            await _firestore
                .collection('bookingRequests')
                .doc(requestId)
                .update({'status': 'rejected'});
            Navigator.pop(context);
          },
          child: const Text("Reject"),
        ),
      ],
    ),
  );
}
