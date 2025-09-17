import 'package:flutter/material.dart';

/// -------------------- BOOKING PAGE --------------------
class Booking extends StatelessWidget {
  const Booking({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: const Center(
        child: Text("Not Yet Booked"),
      ),
    );
  }
}
