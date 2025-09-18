import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PgAddPage extends StatefulWidget {
  final String? editListingId;
  const PgAddPage({super.key, required User owner, this.editListingId});

  @override
  State<PgAddPage> createState() => _PgAddPageState();
}

class _PgAddPageState extends State<PgAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  String _rentType = "cot";

  final Map<String, bool> _amenities = {
    "WiFi": false,
    "Mess": false,
    "Laundry": false,
    "Fan": false,
    "AC": false,
  };

  bool _loading = false;

  Future<void> _savePg() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      await FirebaseFirestore.instance.collection("pgs").add({
        "ownerId": user.uid,
        "name": _name.text.trim(),
        "address": _address.text.trim(),
        "city": _city.text.trim(),
        "rentType": _rentType,
        "amenities": _amenities,
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("PG added successfully ✅")),
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
      appBar: AppBar(title: const Text("Add PG")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: "PG Name"),
              validator: (v) => v!.isEmpty ? "Enter PG name" : null,
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
            const SizedBox(height: 20),
            const Text("Rent Type", style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              value: _rentType,
              items: const [
                DropdownMenuItem(value: "cot", child: Text("Cot Based")),
                DropdownMenuItem(value: "monthly", child: Text("Monthly Rent")),
              ],
              onChanged: (val) => setState(() => _rentType = val!),
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
              onPressed: _loading ? null : _savePg,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Save PG"),
            ),
          ],
        ),
      ),
    );
  }
}
