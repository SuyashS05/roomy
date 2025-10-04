import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class RoomOwnerSupportPage extends StatelessWidget {
  const RoomOwnerSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("support".tr()),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.support_agent, size: 80, color: Colors.purple),
            const SizedBox(height: 20),
            Text(
              "This is the Room Owner Support page.",
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              "Here you can contact support or submit queries related to your listings.",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
