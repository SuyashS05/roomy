import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Roommate {
  final String name;
  final String location;
  final String lookingFor;
  final String budget;

  Roommate(this.name, this.location, this.lookingFor, this.budget);
}

class Findroomates extends StatefulWidget {
  const Findroomates({super.key});

  @override
  State<Findroomates> createState() => _FindroomatesState();
}

class _FindroomatesState extends State<Findroomates> {
  List<Roommate> allRoommates = [
    Roommate("Prathmesh Pimpare", "Pune, Maharashtra", "1 Roommate", "₹5000"),
    Roommate("Aarav Singh", "Mumbai, Maharashtra", "2 Roommates", "₹8000"),
    Roommate("Riya Sharma", "Delhi", "1 Roommate", "₹6000"),
    Roommate("Neha Jain", "Bangalore", "1 Roommate", "₹7000"),
    Roommate("Aman Verma", "Hyderabad", "2 Roommates", "₹5500"),
    Roommate("Sneha Roy", "Chennai", "1 Roommate", "₹4800"),
    Roommate("Yash Mehta", "Ahmedabad", "1 Roommate", "₹5200"),
    Roommate("Pooja Deshmukh", "Pune, Maharashtra", "1 Roommate", "₹5300"),
    Roommate("Aditya Patil", "Nashik", "2 Roommates", "₹6200"),
    Roommate("Kiran Joshi", "Nagpur", "1 Roommate", "₹4700"),
  ];

  List<Roommate> filteredRoommates = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredRoommates = List.from(allRoommates);
  }

  void filterRoommates(String query) {
    final filtered = allRoommates.where((roommate) {
      final nameLower = roommate.name.toLowerCase();
      final locationLower = roommate.location.toLowerCase();
      final searchLower = query.toLowerCase();

      return nameLower.contains(searchLower) || locationLower.contains(searchLower);
    }).toList();

    setState(() {
      filteredRoommates = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade400,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Find Roommate",
                  style: TextStyle(
                      fontSize: 27,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),

                /// 🔍 Search bar
                TextField(
                  controller: searchController,
                  onChanged: filterRoommates,
                  decoration: InputDecoration(
                    hintText: 'Search by name or location',
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 10),

                /// 🧩 GridView of filtered roommates
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: filteredRoommates.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    childAspectRatio: 0.7,
                  ),
                  itemBuilder: (context, index) {
                    final roommate = filteredRoommates[index];
                    return InkWell(
                      onTap: (){
                        //Get.to(Roomatedetailedpage());
                      },
                      child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.grey.shade400,
                                child:
                                Icon(Icons.person, size: 40, color: Colors.white),
                              ),
                              SizedBox(height: 10),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      roommate.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      roommate.location,
                                      style: TextStyle(fontSize: 12),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "Looking for: ${roommate.lookingFor}",
                                      style: TextStyle(fontSize: 12),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "Budget: ${roommate.budget}/month",
                                      style: TextStyle(
                                          color: Colors.green, fontSize: 12),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
