import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';

class HostelPgNotFoundPage extends StatelessWidget {
  final VoidCallback onRetry;

  const HostelPgNotFoundPage({Key? key, required this.onRetry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFf5f7fb),
      body: Stack(
        children: [
          // 🎨 Gradient bubbles background
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.15),
                    Colors.purple.withOpacity(0.10),
                    Colors.orange.withOpacity(0.10),
                  ],
                ),
              ),
            ),
          ),

          // 🌟 Main Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🌀 Lottie Animation
                  Lottie.asset(
                    'assets/lottie/empty.json',
                    width: 260,
                    height: 260,
                    repeat: true,
                  ),
                  const SizedBox(height: 20),

                  // 🏠 Title
                  Text(
                    "No Hostel/PG Found!",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ✨ Subtitle
                  Text(
                    "Looks like this listing has been removed\nor never existed. Let’s find you another cozy place!",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 🔄 Retry Button
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 6,
                      shadowColor: theme.colorScheme.primary.withOpacity(0.4),
                    ),
                    icon: const Icon(Icons.refresh, size: 24),
                    label: Text(
                      "Try Again",
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // 🏡 Back Home
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.home_rounded, color: Colors.deepPurple),
                    label: Text(
                      "Go to Home",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
