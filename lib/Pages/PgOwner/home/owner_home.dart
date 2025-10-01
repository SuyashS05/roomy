import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:romy/Pages/PgOwner/Pages/hostel_add_page.dart';
import 'package:romy/Pages/PgOwner/Pages/house_add_page.dart';
import 'package:romy/Pages/PgOwner/Pages/pg_add_page.dart';
import 'my_listings_page.dart';
import 'profile_page.dart';
import 'owner_dashboard_page.dart';

class OwnerHome extends StatefulWidget {
  final User user;
  const OwnerHome({super.key, required this.user});

  @override
  State<OwnerHome> createState() => _OwnerHomeState();
}

class _OwnerHomeState extends State<OwnerHome> {
  int _index = 0;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      OwnerDashboardPage(user: widget.user),
      MyListingsPage(user: widget.user),
      Container(), // Placeholder, bottom sheet will open instead
      OnerProfilePage(user: widget.user),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          if (i == 2) {
            // Open bottom sheet instead of changing page
            _showAddListingSheet();
          } else {
            setState(() => _index = i);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Listings"),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: "Add Room"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  void _showAddListingSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Add New Listing",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAddCard(
                  title: "Hostel",
                  icon: Icons.apartment,
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context); // Close bottom sheet
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HostelAddPage(owner: widget.user),
                      ),
                    );
                  },
                ),
                _buildAddCard(
                  title: "PG",
                  icon: Icons.people,
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PgAddPage(owner: widget.user)),
                    );
                  },
                ),
                _buildAddCard(
                  title: "House",
                  icon: Icons.house,
                  color: Colors.green,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => HomeAddPage(owner: widget.user)),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              offset: const Offset(0, 3),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: color,
              radius: 24,
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
