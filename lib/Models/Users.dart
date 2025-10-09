import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? profileUrl;
  final String role;
  final bool profileComplete;
  final bool preferencesGiven;
  final String language; // 'en', 'hi', 'mr'
  final String theme; // 'light', 'dark', 'system'

  // 🔹 Extra fields from your Firestore schema
  final String? phone;
  final String? email2;
  final String? address;
  final String? city;
  final int? age;
  final double? lat;
  final double? lng;
  final int? userId;
  final String? deviceToken;
  final DateTime? dob;
  final String? gender;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.profileUrl,
    required this.role,
    this.profileComplete = false,
    this.preferencesGiven = false,
    this.language = 'en',
    this.theme = 'light',
    this.phone,
    this.email2,
    this.address,
    this.city,
    this.age,
    this.lat,
    this.lng,
    this.userId,
    this.deviceToken,
    this.dob,
    this.gender,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid, String email) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: map['displayName'] as String?,
      profileUrl: map['profileUrl'] as String?,
      role: map['role'] as String? ?? 'user',
      profileComplete: map['profileComplete'] as bool? ?? false,
      preferencesGiven: map['preferencesGiven'] as bool? ?? false,
      language: map['language'] as String? ?? 'en',
      theme: map['theme'] as String? ?? 'light',
      phone: map['phone'] as String?,
      email2: map['email2'] as String?,
      address: map['address'] as String?,
      city: map['city'] as String?,
      age: (map['age'] as num?)?.toInt(),
      lat: (map['lat'] as num?)?.toDouble(),
      lng: (map['lng'] as num?)?.toDouble(),
      userId: (map['userId'] as num?)?.toInt(),
      gender: map['gender'] as String?,
      deviceToken: map['deviceToken'] as String?,
      dob: (map['dob'] != null) ? (map['dob'] as Timestamp).toDate() : null,
      createdAt: (map['createdAt'] != null) ? (map['createdAt'] as Timestamp).toDate() : null,
      updatedAt: (map['updatedAt'] != null) ? (map['updatedAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user': uid,
      'displayName': displayName,
      'profileUrl': profileUrl,
      'role': role,
      'profileComplete': profileComplete,
      'preferencesGiven': preferencesGiven,
      'language': language,
      'theme': theme,
      'phone': phone,
      'email2': email2,
      'address': address,
      'city': city,
      'age': age,
      'lat': lat,
      'lng': lng,
      'userId': userId,
      'deviceToken': deviceToken,
      'dob': dob,
      'gender': gender,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  UserModel copyWith({
    String? displayName,
    String? phone,
    String? city,
    String? address,
    String? email2,
    String? email,
    String? role,
    String? profileUrl,
    DateTime? dob,
    String? gender,
    int? age,
    double? lat,
    double? lng,
    bool? profileComplete,
    bool? preferencesGiven,
    DateTime? updatedAt,
    String? language,
    String? theme,
    String? deviceToken,
  }) {
    return UserModel(
      uid: uid,
      displayName: displayName ?? this.displayName,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      address: address ?? this.address,
      email2: email2 ?? this.email2,
      email: email ?? this.email,
      role: role ?? this.role,
      profileUrl: profileUrl ?? this.profileUrl,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      profileComplete: profileComplete ?? this.profileComplete,
      preferencesGiven: preferencesGiven ?? this.preferencesGiven,
      deviceToken: deviceToken ?? this.deviceToken,
      userId: userId, // 🔹 never overwrite
      createdAt: createdAt, // 🔹 never overwrite
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
