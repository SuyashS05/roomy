import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:romy/Pages/GoogleMapPage.dart';
import 'package:romy/Pages/ProfileSectionPages/PersonalInfoPage.dart';
import 'package:romy/Pages/RegistrationPage.dart';
import 'Pages/RoomateDetailedPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: Registrationpage(), // Start from Registration page
    );
  }
}

/// -------------------- MAIN PAGE WITH BOTTOM NAV --------------------
class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    Booking(),
    Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: "Booking",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

/// -------------------- HOME PAGE --------------------
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Welcome,",
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        "Prathmesh",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "Pimpare",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 80,
                  width: 80,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ----------- Find Room -----------
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Get.to(GoogleMapPage());
                    },
                    child: Column(
                      children: [
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.asset(
                              "assets/img/ViewRoom.png",
                              height: 100,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Find Room",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // ----------- Find Roommates -----------
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Get.to(Roomatedetailedpage());
                    },
                    child: Column(
                      children: [
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.asset(
                              "assets/img/ViewRoomate.png",
                              height: 100,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Find Roommates",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// -------------------- BOOKING PAGE --------------------
class Booking extends StatelessWidget {
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

/// -------------------- PROFILE PAGE --------------------
class Profile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 50),
                Container(
                  height: 100,
                  width: 100,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black),
                    color: Colors.green,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Center(child: Text("Prathmesh Pimpare")),
                const Center(child: Text("Prathmesh@gmail.com")),
                const SizedBox(height: 25),
                InkWell(
                  onTap: () {
                    Get.to(Personalinfopage());
                  },
                  child: SizedBox(
                    height: 80,
                    child: Card(
                      surfaceTintColor: Colors.purpleAccent,
                      child: const Center(
                        child: ListTile(
                          leading: Icon(
                            Icons.person,
                            color: Colors.purpleAccent,
                          ),
                          title: Text("Personal Information"),
                          trailing: Icon(Icons.arrow_forward_ios_rounded),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 80,
                  child: Card(
                    surfaceTintColor: Colors.red,
                    child: const Center(
                      child: ListTile(
                        leading: Icon(
                          Icons.favorite,
                          color: Colors.red,
                        ),
                        title: Text("Favorites"),
                        trailing: Icon(Icons.arrow_forward_ios_rounded),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 80,
                  child: Card(
                    surfaceTintColor: Colors.deepOrangeAccent,
                    child: const Center(
                      child: ListTile(
                        leading: Icon(
                          Icons.settings,
                          color: Colors.deepOrangeAccent,
                        ),
                        title: Text("Settings"),
                        trailing: Icon(Icons.arrow_forward_ios_rounded),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 80,
                  child: Card(
                    surfaceTintColor: Colors.blue,
                    child: const Center(
                      child: ListTile(
                        leading: Icon(
                          Icons.logout,
                          color: Colors.blue,
                        ),
                        title: Text("Logout"),
                        trailing: Icon(Icons.arrow_forward_ios_rounded),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}