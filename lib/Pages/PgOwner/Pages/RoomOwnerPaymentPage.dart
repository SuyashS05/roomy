import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class RoomOwnerPaymentPage extends StatelessWidget {
  const RoomOwnerPaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("payments".tr()),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment, size: 80, color: Colors.orange),
            const SizedBox(height: 20),
            Text(
              "This is the Room Owner Payments page.",
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              "Here you can view payment summaries, pending payments, and transactions.",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
