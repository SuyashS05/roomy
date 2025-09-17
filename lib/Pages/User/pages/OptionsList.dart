// preferences_options.dart
import 'package:flutter/material.dart';

/// Hobbies options
const List<String> hobbyOptions = [
  'Reading',
  'Music',
  'Movies',
  'Cooking',
  'Travel',
  'Gym',
  'Cricket',
  'Football',
  'Badminton',
  'Yoga',
  'Coding',
];

/// Interests options
const List<String> interestsOptions = [
  'Art',
  'Drawing',
  'Painting',
  'Cooking',
  'Dancing',
  'Gardening',
  'Hiking',
  'Music',
];

/// Languages options
const List<String> languageOptions = [
  "Hindi",
  "English",
  "Marathi",
  "Gujarati",
  "Punjabi",
  "Bengali",
  "Tamil",
  "Telugu",
  "Kannada",
  "Malayalam",
  "Urdu",
  "Nepali",
  "Bhojpuri",
  "Other",
];

/// Behavior options
const List<String> behaviorOptions = [
  'Calm',
  'Gets angry easily',
  'Friendly',
  'Silent',
  'Talkative',
  'Focused',
  'Party lover',
  'Introvert',
  'Extrovert',
  'Balanced',
];

final Map<String, List<String>> occupationOptions = {
  "Student": [
    "Engineering - FY",
    "Engineering - SY",
    "Engineering - TY",
    "Engineering - Final",
    "Diploma",
    "Post Graduation",
    "Higher Education",
    "Class 10",
    "Class 12",
  ],
  "Working": [
    "Professor",
    "Corporate Job",
    "Startup",
    "Government Job",
    "Freelancer",
    "Business Owner",
  ],
  "Other": ["Exam Preparation", "Homemaker"],
};

final List<String> socialOptions = [
  'Loves group hangouts',
  'Prefers small circle',
  'Independent',
  'Needs personal space',
  'Always with friends',
  'Work-focused',
  'Family-oriented',
];

final List<String> slangOptions = [
  "No slang",
  "Mild slang",
  "Adjustable",
  "Frequent slang",
];

final List<String> foodOptions = [
  "Veg",
  "Non-veg",
  "Vegan",
  "Jain",
  "Eggetarian",
  "Adjustable",
];

final List<String> studyTimeOptions = [
  "Morning person",
  "Night owl",
  "Flexible",
];

final List<String> floorOptions = [
  "Ground floor",
  "Upper floor",
  "Doesn’t matter",
];

final List<String> allergyOptions = ["Dust", "Pollen", "Food", "Pets", "Other"];

final List<String> diseaseOptions = [
  "Asthma",
  "Diabetes",
  "Heart Condition",
  "Other",
];

final List<String> physicalOptions = [
  "Good",
  "Handicap",
  "Limited Mobility",
  "Other",
];

final List<String> yesNoAdjustable = ["Yes", "No", "Adjustable"];