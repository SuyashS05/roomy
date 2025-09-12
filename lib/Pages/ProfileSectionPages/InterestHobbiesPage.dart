import 'package:flutter/material.dart';

class InterestsPage extends StatefulWidget {
  @override
  _InterestsPageState createState() => _InterestsPageState();
}

class _InterestsPageState extends State<InterestsPage> {
  // List of interests
  final List<String> interests = [
    "Reading", "Yoga", "Sports", "Photography", "Cooking",
    "Hiking", "Game", "Music", "Arts", "Dance",
    "Volunteering", "Fishing"
  ];

  // Selected interests
  List<String> selectedInterests = [];

  // Employment status options
  final List<String> employmentOptions = [
    "Student",
    "Employed",
    "Self-employed",
    "Unemployed",
    "Other"
  ];

  String? selectedEmployment;
  String? sleepHabit; // Early Bird or Night Owl

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Interests & Hobbies"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Your Interests & Hobbies",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              SizedBox(height: 10),

              // Wrap for chips
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: interests.map((interest) {
                  final isSelected = selectedInterests.contains(interest);
                  return ChoiceChip(
                    label: Text(interest),
                    selected: isSelected,
                    selectedColor: Colors.deepPurple.shade200,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedInterests.add(interest);
                        } else {
                          selectedInterests.remove(interest);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 25),

              // Employment dropdown
              Text("Your Employment Status",
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
                  value: selectedEmployment,
                  hint: Text("What's your employment"),
                  isExpanded: true,
                  underline: SizedBox(),
                  onChanged: (value) {
                    setState(() {
                      selectedEmployment = value;
                    });
                  },
                  items: employmentOptions.map((String option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 25),

              // Early Bird or Night Owl
              Text("You are a",
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
                    selected: sleepHabit == "Early Bird",
                    selectedColor: Colors.deepPurple.shade200,
                    onSelected: (selected) {
                      setState(() {
                        sleepHabit = "Early Bird";
                      });
                    },
                  ),
                  ChoiceChip(
                    label: Text("Night Owl"),
                    selected: sleepHabit == "Night Owl",
                    selectedColor: Colors.deepPurple.shade200,
                    onSelected: (selected) {
                      setState(() {
                        sleepHabit = "Night Owl";
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 40),

              // Submit button
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
                    // Handle form submit
                    // print("Selected Interests: $selectedInterests");
                    // print("Employment Status: $selectedEmployment");
                    // print("Sleep Habit: $sleepHabit");

                    //on pressed functionality
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
