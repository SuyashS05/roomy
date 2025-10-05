import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        "title": "New Room Added",
        "message": "A new room near you has been listed. Check it out!",
        "time": "2 hrs ago",
        "icon": Icons.home,
        "color": Colors.blue,
      },
      {
        "title": "Message from Owner",
        "message": "The owner replied to your query about Flat 102.",
        "time": "5 hrs ago",
        "icon": Icons.message,
        "color": Colors.green,
      },
      {
        "title": "Profile Updated",
        "message": "Your profile details were successfully updated.",
        "time": "1 day ago",
        "icon": Icons.person,
        "color": Colors.orange,
      },
      {
        "title": "Support Response",
        "message": "Our support team has responded to your ticket.",
        "time": "2 days ago",
        "icon": Icons.support_agent,
        "color": Colors.red,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: true,
        elevation: 2,
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final notif = notifications[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: notif["color"] as Color,
                child: Icon(notif["icon"] as IconData, color: Colors.white),
              ),
              title: Text(
                notif["title"] as String,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(notif["message"] as String),
              trailing: Text(
                notif["time"] as String,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              onTap: () {
                // Add tap action later (navigate to detail)
              },
            ),
          );
        },
      ),
    );
  }
}
