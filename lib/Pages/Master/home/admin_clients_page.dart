import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:romy/Pages/Master/pages/AppClientPage.dart';
import 'package:romy/Pages/Master/pages/clientRequest.dart';
import 'package:romy/provoiders/user_details_provider.dart';

class AdminClientsPage extends StatelessWidget {
  const AdminClientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserDetailsProvider>().user;

    // List of client management options
    final List<Map<String, dynamic>> clientOptions = [
      {
        "title": "Room Owners Requests",
        "icon": Icons.business,
        "color": Colors.deepPurple,
        "page": const ClientRequestsPage(),
      },
      {
        "title": "All Room Owners",
        "icon": Icons.group,
        "color": Colors.orange,
        "page": AllRoomOwnersPage(),
      },
      // Add more options here as needed
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Clients Management"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          itemCount: clientOptions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Two columns
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.0,
          ),
          itemBuilder: (context, index) {
            final item = clientOptions[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => item["page"]),
                );
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                shadowColor: item["color"].withOpacity(0.4),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: item["color"].shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(item["icon"], color: item["color"], size: 36),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        item["title"],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
