import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

/// A reusable notification system using Flushbar.
/// Supports message, title, type, icon, actions, progress bar, etc.
class AppNotifier {
  static void show(
    BuildContext context, {
    required String message,
    String title = "",
    FlushbarPosition position = FlushbarPosition.TOP,
    Duration duration = const Duration(seconds: 3),
    required NotificationType type,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final config = _getConfig(type);

    Flushbar(
      // Title
      titleText: title.isNotEmpty
          ? Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            )
          : null,

      // Message
      messageText: Text(
        message,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.white,
        ),
      ),

      backgroundColor: config["color"] as Color,
      icon: Icon(
        config["icon"] as IconData,
        color: Colors.white,
        size: 28,
      ),

      margin: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(12),
      duration: duration,
      flushbarPosition: position,

      animationDuration: const Duration(milliseconds: 450),
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeIn,

      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 6,
          spreadRadius: 2,
          offset: const Offset(0, 3),
        )
      ],

      // Top progress bar for duration
      showProgressIndicator: true,
      progressIndicatorBackgroundColor: Colors.white24,
      progressIndicatorValueColor: AlwaysStoppedAnimation<Color>(
        Colors.white,
      ),

      // Optional action button
      mainButton: (actionLabel != null && onAction != null)
          ? TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel,
                style: const TextStyle(color: Colors.white),
              ),
            )
          : TextButton(
              onPressed: () {}, // Close button
              child: const Icon(Icons.close, color: Colors.white),
            ),

      maxWidth: 500, // prevents full-width on big screens
    ).show(context);
  }

  /// Helper for color + icon per type
  static Map<String, dynamic> _getConfig(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return {"color": Colors.green, "icon": Icons.check_circle};
      case NotificationType.error:
        return {"color": Colors.red, "icon": Icons.error};
      case NotificationType.warning:
        return {"color": Colors.orange, "icon": Icons.warning};
      case NotificationType.info:
        return {"color": Colors.blue, "icon": Icons.info};
    }
  }
}

/// Enum for notification types
enum NotificationType { success, error, warning, info }
