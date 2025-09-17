import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'my_listings_page.dart';
import 'add_room_page.dart';
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
      AddRoomPage(user: widget.user),
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
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Listings"),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: "Add Room"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
