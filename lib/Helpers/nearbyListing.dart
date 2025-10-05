import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
  const R = 6371; // Earth radius in km
  final dLat = (lat2 - lat1) * pi / 180;
  final dLng = (lng2 - lng1) * pi / 180;
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1 * pi / 180) *
          cos(lat2 * pi / 180) *
          sin(dLng / 2) *
          sin(dLng / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return R * c; // Distance in km
}


Future<List<Map<String, dynamic>>> fetchNearbyListings(
    double userLat, double userLng) async {
  final collectionRef = FirebaseFirestore.instance.collection('listings');

  // Fetch all published listings (or optionally limit by city/area first)
  final snapshot = await collectionRef
      .where('published', isEqualTo: true)
      .get();

  final List<Map<String, dynamic>> nearby = [];

  for (var doc in snapshot.docs) {
    final data = doc.data();
    final loc = data['location'];
    if (loc == null) continue;

    final double lat = loc['lat'] ?? 0;
    final double lng = loc['lng'] ?? 0;
    final distance = calculateDistance(userLat, userLng, lat, lng);

    if (distance <= 2) {
      data['distance'] = distance; // optional: store distance
      data['id'] = doc.id;
      nearby.add(data);
    }

    if (nearby.length >= 5) break; // max 5 listings
  }

  // Optional: sort by distance
  nearby.sort((a, b) => (a['distance'] ?? 0).compareTo(b['distance'] ?? 0));

  return nearby;
}

