import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HouseAddPage extends StatefulWidget {
  final String? editListingId;
  const HouseAddPage({super.key, required User owner, this.editListingId});

  @override
  State<HouseAddPage> createState() => _HouseAddPageState();
}

class _HouseAddPageState extends State<HouseAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _dailyRent = TextEditingController();
  final _monthlyRent = TextEditingController();

  final Map<String, bool> _amenities = {
    "WiFi": false,
    "Hot Water": false,
    "Parking": false,
    "Fan": false,
    "AC": false,
  };

  bool _loading = false;

  Future<void> _saveHouse() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      await FirebaseFirestore.instance.collection("houses").add({
        "ownerId": user.uid,
        "name": _name.text.trim(),
        "address": _address.text.trim(),
        "city": _city.text.trim(),
        "rentAmount": {
          "daily": double.tryParse(_dailyRent.text) ?? 0,
          "monthly": double.tryParse(_monthlyRent.text) ?? 0,
        },
        "amenities": _amenities,
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("House added successfully ✅")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add House")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: "House Name"),
              validator: (v) => v!.isEmpty ? "Enter house name" : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _address,
              decoration: const InputDecoration(labelText: "Address"),
              validator: (v) => v!.isEmpty ? "Enter address" : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _city,
              decoration: const InputDecoration(labelText: "City"),
              validator: (v) => v!.isEmpty ? "Enter city" : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _dailyRent,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Daily Rent"),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _monthlyRent,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Monthly Rent"),
            ),
            const SizedBox(height: 20),
            const Text("Amenities", style: TextStyle(fontWeight: FontWeight.bold)),
            ..._amenities.keys.map((key) {
              return CheckboxListTile(
                title: Text(key),
                value: _amenities[key],
                onChanged: (val) {
                  setState(() => _amenities[key] = val ?? false);
                },
              );
            }),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _saveHouse,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Save House"),
            ),
          ],
        ),
      ),
    );
  }
}
