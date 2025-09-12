import 'package:flutter/material.dart';

class RoommatePreferencePage extends StatefulWidget {
  @override
  _RoommatePreferencePageState createState() => _RoommatePreferencePageState();
}

class _RoommatePreferencePageState extends State<RoommatePreferencePage> {
  // Gender options
  final List<String> genders = ["Male", "Female", "Other"];
  String? selectedGender;
  // Allowed things in room
  final List<String> allowedThings = [
    "Smoking",
    "Drinking",
    "Visitors",
    "Party",
    "Pets",
    "Shared meal & cooking",
  ];
  List<String> selectedThings = [];

  // Early Bird / Night Owl
  String? sleepPreference;

  // Nationality options
  final List<String> nationalities = [
    "Indian",
    "American",
    "British",
    "Canadian",
    "Other"
  ];
  String? selectedNationality;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text("Roommate Preference"),
        backgroundColor: Colors.grey.shade100,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subtitle
              Text(
                "Tell us about your roommate preference",
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              SizedBox(height: 20),

              // Gender
              Text("Preferred Gender",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<String>(
                  value: selectedGender,
                  hint: Text("Select your gender"),
                  isExpanded: true,
                  underline: SizedBox(),
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value;
                    });
                  },
                  items: genders.map((String option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 25),

              // Allowed things in room
              Text("What Things You Want to be Allowed in Your Room",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: allowedThings.map((thing) {
                  final isSelected = selectedThings.contains(thing);
                  return ChoiceChip(
                    label: Text(thing),
                    selected: isSelected,
                    selectedColor: Colors.deepPurple.shade200,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedThings.add(thing);
                        } else {
                          selectedThings.remove(thing);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 25),

              // Early Bird / Night Owl
              Text("You Prefer a",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              SizedBox(height: 10),
              Wrap(
                spacing: 12,
                children: [
                  ChoiceChip(
                    label: Text("Early Bird"),
                    selected: sleepPreference == "Early Bird",
                    selectedColor: Colors.deepPurple.shade200,
                    onSelected: (selected) {
                      setState(() {
                        sleepPreference = "Early Bird";
                      });
                    },
                  ),
                  ChoiceChip(
                    label: Text("Night Owl"),
                    selected: sleepPreference == "Night Owl",
                    selectedColor: Colors.deepPurple.shade200,
                    onSelected: (selected) {
                      setState(() {
                        sleepPreference = "Night Owl";
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    // Handle submit
                    print("Gender: $selectedGender");
                    print("Allowed Things: $selectedThings");
                    print("Sleep Preference: $sleepPreference");
                    print("Nationality: $selectedNationality");
                  },
                  child: Text(
                    "Submit",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
