import 'package:flutter/material.dart';

class UserSupportPage extends StatefulWidget {
  const UserSupportPage({super.key});

  @override
  State<UserSupportPage> createState() => _UserSupportPageState();
}

class _UserSupportPageState extends State<UserSupportPage> {
  final TextEditingController _feedbackController = TextEditingController();

  final List<Map<String, dynamic>> faqs = [
    {
      'question': 'How do I book a room?',
      'answer': 'To book a room, search for a listing, click "View Details" and then tap "Book Now".'
    },
    {
      'question': 'How can I contact the owner?',
      'answer': 'You can contact the owner directly from the listing page via phone or chat.'
    },
    {
      'question': 'How do I cancel a booking?',
      'answer': 'Go to your bookings page, select the booking, and tap "Cancel Booking".'
    },
    {
      'question': 'How do I update my profile?',
      'answer': 'Go to your profile, tap "Edit Profile", and make the necessary changes.'
    },
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _submitFeedback() {
    final feedback = _feedbackController.text.trim();
    if (feedback.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your feedback")),
      );
      return;
    }

    // 🔹 Static, so we just show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Thank you for your feedback!")),
    );

    _feedbackController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Support"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Hero section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Need Help?",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "We are here to help you with any questions or issues you may have.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 🔹 Support categories
            const Text(
              "Support Categories",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCategoryCard(Icons.help_outline, "FAQs"),
                _buildCategoryCard(Icons.contact_mail, "Contact Us"),
                _buildCategoryCard(Icons.feedback, "Feedback"),
              ],
            ),
            const SizedBox(height: 24),

            // 🔹 FAQs section
            const Text(
              "Frequently Asked Questions",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...faqs.map(
              (faq) => Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  title: Text(
                    faq['question'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        faq['answer'],
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 🔹 Feedback form
            const Text(
              "Send Us Feedback",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _feedbackController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Enter your feedback or query...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitFeedback,
                icon: const Icon(Icons.send),
                label: const Text("Submit Feedback"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Colors.blueAccent,
                ),
              ),
            ),

            const SizedBox(height: 32),
            Center(
              child: Text(
                "Roomy Support Team",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(IconData icon, String title) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("$title tapped")),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                Icon(icon, size: 36, color: Colors.blueAccent),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
