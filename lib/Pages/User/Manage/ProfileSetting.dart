import 'package:flutter/material.dart';
import 'package:romy/Models/Users.dart';
import 'package:geolocator/geolocator.dart';

class ProfileSettingsPage extends StatefulWidget {
  final UserModel user;
  const ProfileSettingsPage({super.key, required this.user});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  String _selectedTheme = "light";
  String _selectedLanguage = "en";
  String _location = "Unknown";

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.displayName ?? "");
    _phoneController = TextEditingController(text: widget.user.phone ?? "");
    _emailController = TextEditingController(text: widget.user.email);
    _selectedTheme = widget.user.theme;
    _selectedLanguage = widget.user.language;
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _location = "${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
      });
    } catch (e) {
      debugPrint("Error fetching location: $e");
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    // 🔹 Here you can call Firestore to update user profile
    debugPrint("Settings saved: ${_nameController.text}, $_selectedTheme, $_selectedLanguage, $_location");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Settings saved successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile & Settings"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔹 Profile Picture
            CircleAvatar(
              radius: 50,
              backgroundImage: widget.user.profileUrl != null
                  ? NetworkImage(widget.user.profileUrl!)
                  : const AssetImage("assets/img/default_profile.png") as ImageProvider,
            ),
            const SizedBox(height: 16),

            // 🔹 Name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 🔹 Phone
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: "Phone",
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // 🔹 Email
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              readOnly: true,
            ),
            const SizedBox(height: 16),

            // 🔹 Theme Selection
            DropdownButtonFormField<String>(
              value: _selectedTheme,
              items: const [
                DropdownMenuItem(value: "light", child: Text("Light")),
                DropdownMenuItem(value: "dark", child: Text("Dark")),
                DropdownMenuItem(value: "system", child: Text("System")),
              ],
              onChanged: (value) => setState(() => _selectedTheme = value ?? "light"),
              decoration: const InputDecoration(
                labelText: "App Theme",
                prefixIcon: Icon(Icons.color_lens),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 🔹 Language Selection
            DropdownButtonFormField<String>(
              value: _selectedLanguage,
              items: const [
                DropdownMenuItem(value: "en", child: Text("English")),
                DropdownMenuItem(value: "hi", child: Text("Hindi")),
                DropdownMenuItem(value: "mr", child: Text("Marathi")),
              ],
              onChanged: (value) => setState(() => _selectedLanguage = value ?? "en"),
              decoration: const InputDecoration(
                labelText: "Language",
                prefixIcon: Icon(Icons.language),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 🔹 Location Settings
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.green),
              title: const Text("Current Location"),
              subtitle: Text(_location),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.green),
                onPressed: _getCurrentLocation,
              ),
            ),
            const SizedBox(height: 24),

            // 🔹 Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  "Save Settings",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 🔹 Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Implement logout
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  "Logout",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
