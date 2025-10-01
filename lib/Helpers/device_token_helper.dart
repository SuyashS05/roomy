import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class DeviceTokenHelper {
  /// Ensures the device token is set in Firestore for the current user
  static Future<void> ensureDeviceToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final snapshot = await docRef.get();

    if (!snapshot.exists) return;

    final currentToken = snapshot.data()?['deviceToken'] as String?;
    if (currentToken == null || currentToken.isEmpty) {
      try {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null && token.isNotEmpty) {
          await docRef.set({'deviceToken': token}, SetOptions(merge: true));
        }
      } catch (e) {
        print("Failed to get device token: $e");
      }
    }
  }

  /// Optional: listen to token refresh dynamically
  static void listenToTokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({'deviceToken': token}, SetOptions(merge: true));
      }
    });
  }
}
