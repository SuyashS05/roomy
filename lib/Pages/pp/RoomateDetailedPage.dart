import 'package:flutter/material.dart';

class Roomatedetailedpage extends StatefulWidget {
  const Roomatedetailedpage({super.key});

  @override
  State<Roomatedetailedpage> createState() => _RoomatedetailedpageState();
}

class _RoomatedetailedpageState extends State<Roomatedetailedpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Roommate Details"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// Profile Image
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage('assets/img/img.png'), // use your own asset or NetworkImage
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 20),

              /// Name
              Text(
                "Prathmesh Pimpare",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 6),

              /// Location
              Text(
                "Pune, Maharashtra",
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),

              SizedBox(height: 20),

              /// About
              Text(
                "Hi, I'm looking for a roommate to share a 2BHK apartment. I’m clean, respectful, and work from home. Preferred roommate should be working professional or student.",
                style: TextStyle(fontSize: 15),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 20),

              /// Budget and Preferences
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.monetization_on, color: Colors.green),
                        SizedBox(width: 10),
                        Text("Budget: ₹5000/month", style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.people_outline, color: Colors.purple),
                        SizedBox(width: 10),
                        Text("Looking for: 1 Roommate", style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),

              /// Contact Button
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Add navigation to chat or call
                },
                icon: Icon(Icons.message),
                label: Text("Contact Now"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  textStyle: TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
