import 'package:flutter/material.dart';

class PreferencesPreviewCard extends StatefulWidget {
  final double completeness;
  final Map<String, dynamic> preferences; // pass all prefs here

  const PreferencesPreviewCard({
    super.key,
    required this.completeness,
    required this.preferences,
  });

  @override
  State<PreferencesPreviewCard> createState() =>
      _PreferencesPreviewCardState();
}

class _PreferencesPreviewCardState extends State<PreferencesPreviewCard> {
  bool _compactView = true;

  Color _progressColor(double value) {
    if (value < 0.5) return Colors.red;
    if (value < 0.8) return Colors.orange;
    return Colors.green;
  }

  Widget _buildChip(String label, String? value) {
    return Chip(
      label: Text(
        "$label: ${value == null || value.isEmpty ? '—' : value}",
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: Colors.blue.shade50,
    );
  }

  Widget _buildTile(String label, String? value, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(value == null || value.isEmpty ? "—" : value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = widget.preferences;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Header with progress
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Profile Preferences Completion",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text("${(widget.completeness * 100).round()}%"),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: widget.completeness,
              backgroundColor: Colors.grey[200],
              valueColor:
                  AlwaysStoppedAnimation(_progressColor(widget.completeness)),
            ),
            const SizedBox(height: 12),

            // Mode toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Preview of entered preferences"),
                Switch(
                  value: _compactView,
                  onChanged: (v) => setState(() => _compactView = v),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Compact Mode → Chips Grid
            if (_compactView)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _buildChip("Behavior", prefs["behavior"]),
                  _buildChip("Interests", prefs["interests"]),
                  _buildChip("Hobbies", prefs["hobbies"]),
                  _buildChip("Work Shift", prefs["workShift"]),
                  _buildChip("Food", prefs["foodType"]),
                  _buildChip("Languages", prefs["languages"]),
                  _buildChip("Budget", prefs["budget"]),
                ],
              ),

            // Detailed Mode → ExpansionTiles with Tiles
            if (!_compactView)
              ExpansionTile(
                initiallyExpanded: true,
                title: const Text("Detailed Preferences"),
                children: [
                  _buildTile("Behavior", prefs["behavior"],
                      Icons.sentiment_satisfied, Colors.orange),
                  _buildTile("Interests", prefs["interests"], Icons.palette,
                      Colors.purple),
                  _buildTile("Hobbies", prefs["hobbies"], Icons.sports_esports,
                      Colors.teal),
                  _buildTile("Work Shift", prefs["workShift"], Icons.work,
                      Colors.blue),
                  _buildTile("Bathroom Sharing", prefs["bathroomSharing"],
                      Icons.bathtub, Colors.cyan),
                  _buildTile("Food Preferences", prefs["foodType"],
                      Icons.fastfood, Colors.green),
                  _buildTile("Languages", prefs["languages"], Icons.language,
                      Colors.deepPurple),
                  _buildTile("Smoking", prefs["smoking"], Icons.smoking_rooms,
                      Colors.red),
                  _buildTile("Sleep/Wake", prefs["sleepWake"],
                      Icons.bedtime_outlined, Colors.indigo),
                  _buildTile("Budget", prefs["budget"], Icons.attach_money,
                      Colors.teal),
                ],
              ),
          ],
        ),
      ),
    );
  }
}


// PreferencesPreviewCard(
//   completeness: _completeness,
//   preferences: {
//     "behavior": _selectedBehaviors.join(", "),
//     "interests": _selectedInterests.join(", "),
//     "hobbies": _selectedHobbies.join(", "),
//     "workShift": _workShift,
//     "bathroomSharing":
//         _shareBathroom == true ? "Yes" : _shareBathroom == false ? "No" : "—",
//     "foodType": _foodType,
//     "languages": _selectedLanguages.join(", "),
//     "smoking": _smoking,
//     "sleepWake":
//         "${_formatTimeOfDay(_sleepTime)} / ${_formatTimeOfDay(_wakeTime)}",
//     "budget":
//         "₹${_budgetRange.start.round()} - ₹${_budgetRange.end.round()}",
//   },
// )
