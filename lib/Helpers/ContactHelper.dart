import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUtils {
  /// 📞 Make a direct phone call
  static Future<void> callNumber(String phoneNumber) async {
    final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      debugPrint("❌ Could not launch phone call: $phoneNumber");
    }
  }

  /// 💬 Send a direct SMS
  static Future<void> sendSMS(String phoneNumber, {String? message}) async {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: {
        if (message != null && message.isNotEmpty) 'body': message,
      },
    );
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      debugPrint("❌ Could not launch SMS: $phoneNumber");
    }
  }

  /// 🟢 Send a direct WhatsApp message
  static Future<void> sendWhatsApp(String phoneNumber, {String? message}) async {
    final cleanedNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final encodedMessage = Uri.encodeComponent(message ?? '');
    final Uri whatsappUri = Uri.parse(
      "https://wa.me/$cleanedNumber?text=$encodedMessage",
    );

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("❌ Could not open WhatsApp for $cleanedNumber");
    }
  }
}
