import 'package:flutter/material.dart';

class PgDetailsPage extends StatelessWidget {
  final String listingId;
  final bool isOwnerAccess;
  final String? ownerUid;

  const PgDetailsPage({
    Key? key,
    required this.listingId,
    this.isOwnerAccess = false,
    this.ownerUid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Placeholder for PG details page
    return Scaffold(
      appBar: AppBar(title: const Text("PG Details")),
      body: Center(child: Text("Details for PG Listing ID: $listingId")),
    );
  }
}