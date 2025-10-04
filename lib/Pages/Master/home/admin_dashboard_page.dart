import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:romy/Pages/ListingsMap.dart';
import 'package:romy/Pages/Master/pages/AdminCampaignApprovalPage.dart';
import 'package:romy/Pages/Master/pages/AdminCampainPage.dart';
import 'package:romy/Pages/User/home/mapPreviewUsers.dart';
import 'package:romy/Pages/User/pages/SearchBar.dart';
import 'package:romy/provoiders/user_details_provider.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserDetailsProvider>().user;

    final usersRef = FirebaseFirestore.instance.collection('users');
    final reportsRef = FirebaseFirestore.instance.collection('reports');

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // 🌍 Mini Map Preview
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ListingsMap()),
                  );
                },
                child: const MapPreviewWidget(),
              ),
              const SizedBox(height: 20),
                          // 🔹 Search widget
              RoomSearchWidget(),
          
              const SizedBox(height: 16),
          
              // Grid of Action Cards
              GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 0.95,
                children: [
                  // Total Users
                  StreamBuilder<QuerySnapshot>(
                    stream: usersRef.snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return const _LoadingCard(
                          "Users",
                          Icons.people,
                          Colors.blue,
                        );
                      final count = snapshot.data!.docs.length;
                      return _StatCard(
                        "Total Users",
                        "$count",
                        Icons.people,
                        Colors.blue,
                      );
                    },
                  ),
                        
                  // Room Owners
                  StreamBuilder<QuerySnapshot>(
                    stream:
                        usersRef
                            .where('role', isEqualTo: 'roomOwner')
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return const _LoadingCard(
                          "Room Owners",
                          Icons.house,
                          Colors.green,
                        );
                      final count = snapshot.data!.docs.length;
                      return _StatCard(
                        "Room Owners",
                        "$count",
                        Icons.house,
                        Colors.green,
                      );
                    },
                  ),
                        
                  // Active Seekers
                  StreamBuilder<QuerySnapshot>(
                    stream:
                        usersRef
                            .where('role', isEqualTo: 'roomSeeker')
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return const _LoadingCard(
                          "Active Seekers",
                          Icons.search,
                          Colors.orange,
                        );
                      final count = snapshot.data!.docs.length;
                      return _StatCard(
                        "Active Seekers",
                        "$count",
                        Icons.search,
                        Colors.orange,
                      );
                    },
                  ),
                        
                  // Pending Reports
                  StreamBuilder<QuerySnapshot>(
                    stream:
                        reportsRef
                            .where('status', isEqualTo: 'pending')
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return const _LoadingCard(
                          "Pending Reports",
                          Icons.report,
                          Colors.red,
                        );
                      final count = snapshot.data!.docs.length;
                      return _StatCard(
                        "Pending Reports",
                        "$count",
                        Icons.report,
                        Colors.red,
                      );
                    },
                  ),
                  _StatCard("Reports History", "", Icons.history, Colors.deepOrange),
                ],
              ),
              const SizedBox(height: 20),
              Divider(color: Colors.grey[300], height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Create Campaign Card
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminCampaignsPage(),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              colors: [Colors.purple, Colors.deepPurpleAccent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purple.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.white24,
                                child: Icon(
                                  Icons.campaign,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                "Create Campaign",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                
                    // Approve Campaign Card
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminCampaignApprovalPage(),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              colors: [Colors.teal, Colors.greenAccent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.teal.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.white24,
                                child: Icon(
                                  Icons.verified,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                "Approve Campaigns",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard(this.title, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 6),
            if (value.isNotEmpty)
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _LoadingCard(this.title, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color.withOpacity(0.7)),
            const SizedBox(height: 8),
            const CircularProgressIndicator(),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
