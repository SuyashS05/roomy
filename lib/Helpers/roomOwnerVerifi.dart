import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:romy/Helpers/Notifi_Snackbar.dart';

/// Simple in-memory cache for user verification status
class VerificationCache {
  static final Map<String, bool> _verifiedStatus = {};

  static bool? get(String uid) => _verifiedStatus[uid];
  static void set(String uid, bool status) => _verifiedStatus[uid] = status;
}

/// Check if user is verified with caching
Future<bool> checkVerified(BuildContext context, String uid) async {
  final cached = VerificationCache.get(uid);
  if (cached != null) return cached;

  final doc = await FirebaseFirestore.instance
      .collection("RoomOwners")
      .doc(uid)
      .get();

  final data = doc.exists ? doc.data() as Map<String, dynamic> : null;

  final isVerified = data != null &&
      (data["adminCheck"]?.toString().toLowerCase() == "approved") &&
      (data["adminVerified"] == true);

  VerificationCache.set(uid, isVerified);

  if (!isVerified) {
    AppNotifier.show(
      context,
      title: "not_verified".tr(),
      message: "please_verify_id_first".tr(),
      type: NotificationType.warning,
    );
  }

  return isVerified;
}
