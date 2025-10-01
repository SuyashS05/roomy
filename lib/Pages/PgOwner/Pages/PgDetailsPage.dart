import 'package:flutter/material.dart';

class PgDetailsPage extends StatelessWidget {
  final String listingId;

  const PgDetailsPage({super.key, required this.listingId});

  @override
  Widget build(BuildContext context) {
    // Placeholder for PG details page
    return Scaffold(
      appBar: AppBar(title: const Text("PG Details")),
      body: Center(child: Text("Details for PG Listing ID: $listingId")),
    );
  }
}