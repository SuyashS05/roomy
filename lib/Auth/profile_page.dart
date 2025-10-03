import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:romy/Helpers/LocationHelper.dart';
import 'package:romy/provoiders/locale_provider.dart';
import 'package:romy/provoiders/user_details_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _city = TextEditingController();
  final _address = TextEditingController();
  final _email2 = TextEditingController();

  DateTime? _dob;
  int? _age;
  bool _loading = false;

  double? _lat;
  double? _lng;
  String? _gender;

  @override
  void initState() {
    super.initState();
    _loadFromProvider();
  }

  void _loadFromProvider() {
    final user = context.read<UserDetailsProvider>().user;
    if (user != null) {
      _name.text = user.displayName ?? '';
      _phone.text = user.phone ?? '';
      _city.text = user.city ?? '';
      _address.text = user.address ?? '';
      _email2.text = user.email2 ?? '';
      _dob = user.dob;
      _gender = user.gender;
      _age = user.dob != null ? _calculateAge(user.dob!) : null;
      _lat = user.lat;
      _lng = user.lng;
    }
  }

  Future<void> _save() async {
    final userProvider = context.read<UserDetailsProvider>();
    final current = userProvider.user;

    if (current == null) return;
    setState(() => _loading = true);

    final updated = current.copyWith(
      displayName: _name.text.trim(),
      phone: _phone.text.trim(),
      city: _city.text.trim(),
      address: _address.text.trim(),
      email2: _email2.text.trim(),
      dob: _dob,
      age: _age,
      gender: _gender,
      lat: _lat,
      lng: _lng,
      profileComplete: _isProfileComplete(),
      updatedAt: DateTime.now(),
    );

    await FirebaseFirestore.instance
        .collection("users")
        .doc(current.uid)
        .set(updated.toMap(), SetOptions(merge: true));

    setState(() => _loading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Profile_updated".tr())));
  }

  bool _isProfileComplete() {
    return _phone.text.trim().isNotEmpty &&
        _email2.text.trim().isNotEmpty &&
        _dob != null;
    _gender != null && _gender!.isNotEmpty;
  }

  int _calculateAge(DateTime dob) {
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  Future<void> _pickDob() async {
    final initialDate = _dob ?? DateTime(2000);
    final newDob = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (newDob != null) {
      setState(() {
        _dob = newDob;
        _age = _calculateAge(newDob);
      });
    }
  }

  Future<void> _pickProfileImage() async {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text("choose_profile_image".tr()),
          content: SizedBox(
            width: double.maxFinite,
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection("profiles").snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                return GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (ctx, i) {
                    final url = docs[i]['url'] as String;
                    return GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);

                        final userProvider =
                            context.read<UserDetailsProvider>();
                        final current = userProvider.user!;
                        final updated = current.copyWith(
                          profileUrl: url,
                          profileComplete: _isProfileComplete(),
                          updatedAt: DateTime.now(),
                        );

                        await FirebaseFirestore.instance
                            .collection("users")
                            .doc(current.uid)
                            .set(updated.toMap(), SetOptions(merge: true));
                      },
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(url),
                        radius: 30,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _useCurrentLocation() async {
    final loc = await LocationHelper.getCurrentLocation();
    if (loc != null) {
      setState(() {
        _lat = loc["lat"];
        _lng = loc["lng"];
        _city.text = loc["address"];
        _address.text = loc["address"];
      });
    }
  }

  Future<void> _pickOnMap() async {
    final loc = await LocationHelper.pickOnMap(context);
    if (loc != null) {
      setState(() {
        _lat = loc["lat"];
        _lng = loc["lng"];
        _city.text = loc["address"];
        _address.text = loc["address"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserDetailsProvider>().user;
    final localeProvider = context.watch<LocaleProvider>();

    if (user == null) {
      return Scaffold(body: Center(child: Text("No user data available".tr())));
    }

    return Scaffold(
      appBar: AppBar(title: Text("your_profile".tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (user.role.isNotEmpty) Text("Role: ${user.role}"),
            Text(
              "Primary Email: ${user.email}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickProfileImage,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        user.profileUrl != null && user.profileUrl!.isNotEmpty
                            ? NetworkImage(user.profileUrl!)
                            : null,
                    child:
                        user.profileUrl == null || user.profileUrl!.isEmpty
                            ? const Icon(Icons.add_a_photo, size: 30)
                            : null,
                  ),
                  Positioned(
                    right: -2,
                    top: -2,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white,
                      child: Icon(
                        _isProfileComplete()
                            ? Icons.check_circle
                            : Icons.cancel,
                        color:
                            _isProfileComplete() ? Colors.green : Colors.orange,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            TextField(
              controller: _name,
              decoration: InputDecoration(labelText: 'full_name'.tr()),
            ),
            TextField(
              controller: _phone,
              decoration: InputDecoration(labelText: 'phone'.tr()),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _gender,
                    decoration: InputDecoration(labelText: 'gender'.tr()),
                    items:
                        ['Male', 'Female', 'Other'].map((g) {
                          return DropdownMenuItem(
                            value: g,
                            child: Text(g.tr()),
                          );
                        }).toList(),
                    onChanged: (val) {
                      setState(() => _gender = val);
                    },
                  ),
                ),
              ],
            ),

            TextField(
              controller: _city,
              decoration: InputDecoration(labelText: 'city'.tr()),
            ),
            TextField(
              controller: _address,
              decoration: InputDecoration(labelText: 'address'.tr()),
            ),

            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _useCurrentLocation,
                  icon: const Icon(Icons.my_location),
                  label: Text("use_current_location".tr()),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _pickOnMap,
                  icon: const Icon(Icons.map),
                  label: Text("pick_on_map".tr()),
                ),
              ],
            ),

            TextField(
              controller: _email2,
              decoration: InputDecoration(labelText: 'secondary_email'.tr()),
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _dob == null
                        ? 'Date of Birth: not set'.tr()
                        : 'DOB: ${DateFormat.yMMMd().format(_dob!)} (Age: $_age)',
                  ),
                ),
                TextButton(onPressed: _pickDob, child: Text('select_dob'.tr())),
              ],
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _save,
              child:
                  _loading
                      ? const CircularProgressIndicator()
                      : Text("save".tr()),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';

// class ProfilePage extends StatefulWidget {
//   final String uid;
//   const ProfilePage({required this.uid, super.key});

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   final _name = TextEditingController();
//   final _phone = TextEditingController();
//   final _city = TextEditingController();
//   final _address = TextEditingController();
//   final _email2 = TextEditingController();
//   DateTime? _dob;

//   bool _loading = false;
//   String? _role;
//   String? _primaryEmail;
//   int? _age;
//   String? _profileUrl;

//   @override
//   void initState() {
//     super.initState();
//     _load();
//   }

//   Future<void> _load() async {
//     final userDoc =
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(widget.uid)
//             .get();

//     _primaryEmail = FirebaseAuth.instance.currentUser?.email;

//     if (userDoc.exists) {
//       final data = userDoc.data()!;
//       _name.text = (data['displayName'] ?? '') as String;
//       _phone.text = (data['phone'] ?? '') as String;
//       _city.text = (data['city'] ?? '') as String;
//       _address.text = (data['address'] ?? '') as String;
//       _email2.text = (data['email2'] ?? '') as String;
//       _role = data['role'] as String?;
//       _profileUrl = (data['profileUrl'] ?? '') as String?;

//       if (data['dob'] != null) {
//         _dob = (data['dob'] as Timestamp).toDate();
//         _age = _calculateAge(_dob!);
//       }
//       setState(() {});
//     }
//   }

//   Future<void> _save() async {
//     setState(() => _loading = true);

//     final docRef = FirebaseFirestore.instance
//         .collection('users')
//         .doc(widget.uid);

//     // ✅ Calculate profile completeness
//     final isComplete = _isProfileComplete();

//     await docRef.set({
//       'displayName': _name.text.trim(),
//       'phone': _phone.text.trim(),
//       'city': _city.text.trim(),
//       'address': _address.text.trim(),
//       'profileUrl': _profileUrl ?? "",
//       'email2': _email2.text.trim(),
//       'dob': _dob != null ? Timestamp.fromDate(_dob!) : null,
//       'age': _age,
//       'updatedAt': FieldValue.serverTimestamp(),
//       'profileComplete': isComplete,
//     }, SetOptions(merge: true));

//     setState(() => _loading = false);

//     if (!mounted) return;
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(const SnackBar(content: Text('Profile saved')));
//   }

//   Future<void> _updateProfileImage(String url) async {
//     setState(() => _profileUrl = url);

//     final isComplete = _isProfileComplete();

//     await FirebaseFirestore.instance.collection('users').doc(widget.uid).set({
//       'profileUrl': url,
//       'profileComplete': isComplete,
//       'updatedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//   }

//   bool _isProfileComplete() {
//     return _phone.text.trim().isNotEmpty &&
//         _email2.text.trim().isNotEmpty &&
//         _dob != null;
//   }

//   int _calculateAge(DateTime dob) {
//     final today = DateTime.now();
//     int age = today.year - dob.year;
//     if (today.month < dob.month ||
//         (today.month == dob.month && today.day < dob.day)) {
//       age--;
//     }
//     return age;
//   }

//   Future<void> _pickDob() async {
//     final initialDate = _dob ?? DateTime(2000);
//     final newDob = await showDatePicker(
//       context: context,
//       initialDate: initialDate,
//       firstDate: DateTime(1950),
//       lastDate: DateTime.now(),
//     );
//     if (newDob != null) {
//       setState(() {
//         _dob = newDob;
//         _age = _calculateAge(newDob);
//       });
//     }
//   }

//   Future<void> _pickProfileImage() async {
//     showDialog(
//       context: context,
//       builder: (ctx) {
//         return AlertDialog(
//           title: const Text("Choose Profile Image"),
//           content: SizedBox(
//             width: double.maxFinite,
//             child: StreamBuilder<QuerySnapshot>(
//               stream:
//                   FirebaseFirestore.instance.collection("profiles").snapshots(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 final docs = snapshot.data!.docs;
//                 return GridView.builder(
//                   shrinkWrap: true,
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 3,
//                     crossAxisSpacing: 8,
//                     mainAxisSpacing: 8,
//                   ),
//                   itemCount: docs.length,
//                   itemBuilder: (ctx, i) {
//                     final url = docs[i]['url'] as String;
//                     return GestureDetector(
//                       onTap: () async {
//                         Navigator.pop(context);
//                         await _updateProfileImage(url); // ✅ saves instantly
//                       },
//                       child: CircleAvatar(
//                         backgroundImage: NetworkImage(url),
//                         radius: 30,
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Your Profile')),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             if (_role != null) Text('Role: $_role'),
//             if (_primaryEmail != null)
//               Text(
//                 'Primary Email: $_primaryEmail',
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),

//             const SizedBox(height: 12),
//             GestureDetector(
//               onTap: _pickProfileImage,
//               child: CircleAvatar(
//                 radius: 50,
//                 backgroundImage:
//                     _profileUrl != null && _profileUrl!.isNotEmpty
//                         ? NetworkImage(_profileUrl!)
//                         : null,
//                 child:
//                     _profileUrl == null || _profileUrl!.isEmpty
//                         ? const Icon(Icons.add_a_photo, size: 30)
//                         : null,
//               ),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: _name,
//               decoration: const InputDecoration(labelText: 'Full name'),
//             ),
//             TextField(
//               controller: _phone,
//               decoration: const InputDecoration(labelText: 'Phone'),
//             ),
//             TextField(
//               controller: _city,
//               decoration: const InputDecoration(labelText: 'City / Village'),
//             ),
//             TextField(
//               controller: _address,
//               decoration: const InputDecoration(labelText: 'Address'),
//             ),
//             TextField(
//               controller: _email2,
//               decoration: const InputDecoration(labelText: 'Secondary Email'),
//             ),

//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     _dob == null
//                         ? 'Date of Birth: not set'
//                         : 'DOB: ${DateFormat.yMMMd().format(_dob!)} (Age: $_age)',
//                   ),
//                 ),
//                 TextButton(
//                   onPressed: _pickDob,
//                   child: const Text('Select DOB'),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _loading ? null : _save,
//               child:
//                   _loading
//                       ? const CircularProgressIndicator()
//                       : const Text('Save'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
