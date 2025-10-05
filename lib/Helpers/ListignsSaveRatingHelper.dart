import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

/// 1️⃣ Give a rating to a listing
Future<void> rateListing({
  required String listingId,
  required String userId,
  required double rating, // 1.0 - 5.0
}) async {
  if (rating < 1 || rating > 5) {
    throw Exception("Rating must be between 1 and 5");
  }

  final ratingRef = _firestore
      .collection('listings')
      .doc(listingId)
      .collection('ratings')
      .doc(userId); // One rating per user

  await ratingRef.set({
    'userId': userId,
    'rating': rating,
    'timestamp': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));

  // Optional: update average rating on the listing document
  final ratingsSnapshot = await _firestore
      .collection('listings')
      .doc(listingId)
      .collection('ratings')
      .get();

  if (ratingsSnapshot.docs.isNotEmpty) {
    double avgRating = ratingsSnapshot.docs
            .map((doc) => (doc['rating'] ?? 0) as double)
            .reduce((a, b) => a + b) /
        ratingsSnapshot.docs.length;

    await _firestore
        .collection('listings')
        .doc(listingId)
        .update({'averageRating': avgRating});
  }
}

/// 2️⃣ Save a listing to user's saved collection
Future<void> saveListing({
  required String userId,
  required String listingId,
  Map<String, dynamic>? listingData, // optional info
}) async {
  final savedRef = _firestore
      .collection('users')
      .doc(userId)
      .collection('saved')
      .doc(listingId);

  await savedRef.set({
    'listingId': listingId,
    'savedAt': FieldValue.serverTimestamp(),
    ...?listingData, // optional: save extra data like title/image
  }, SetOptions(merge: true));
}

/// 3️⃣ Optional: Remove saved listing
Future<void> unsaveListing({
  required String userId,
  required String listingId,
}) async {
  final savedRef = _firestore
      .collection('users')
      .doc(userId)
      .collection('saved')
      .doc(listingId);

  await savedRef.delete();
}
