import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:romy/Helpers/LocationHelper.dart';
import 'package:romy/Helpers/Notifi_Snackbar.dart';
import 'package:romy/Models/Users.dart';

class HostelAddPage extends StatefulWidget {
  final UserModel owner;
  final String? editListingId; // if null → add mode, else edit mode

  const HostelAddPage({super.key, required this.owner, this.editListingId});

  @override
  State<HostelAddPage> createState() => _HostelAddPageState();
}

class _HostelAddPageState extends State<HostelAddPage> {
  final _formKey = GlobalKey<FormState>();

  // Common listing controllers
  final _titleController = TextEditingController();
  final _addressController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _basePriceController = TextEditingController();
  final _renovationDateController = TextEditingController();

  // Amenities
  bool wifi = false;
  bool drinkingWater = false;
  bool hotWater = false;
  bool mess = false;
  bool fan = false;
  bool ac = false;
  bool tv = false;
  bool tableChair = false;
  bool parking = false;

  // Rules
  String genderRule = "coed";
  String? curfewTime;
  int depositMonths = 0;
  int lockInMonths = 0;

  // Bills
  bool electricityBillIncluded = true;
  bool waterBillIncluded = true;
  bool internetIncluded = true;
  int maintenanceFee = 0;
  int messFeeMonthly = 0;

  // Location
  LatLng? _selectedLocation;

  // Images
  final List<String> _imageUrls = [];
  final ImagePicker _picker = ImagePicker();
  // Bathrooms type
  String bathroomsType = "shared";

  // Floors/Rooms/Cots
  List<Map<String, dynamic>> floors = [];

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.editListingId != null) {
      _loadExistingData();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _basePriceController.dispose();
    _renovationDateController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingData() async {
    // Load from Firestore (similar to your code)
    final listingSnap =
        await FirebaseFirestore.instance
            .collection("listings")
            .doc(widget.editListingId)
            .get();

    if (listingSnap.exists) {
      final data = listingSnap.data()!;
      _titleController.text = data["title"] ?? "";
      _addressController.text = data["address"]["fullAddress"] ?? "";
      _landmarkController.text = data["address"]["landmark"] ?? "";
      _cityController.text = data["address"]["city"] ?? "";
      _stateController.text = data["address"]["state"] ?? "";
      _pincodeController.text = data["address"]["pincode"] ?? "";
      _basePriceController.text = data["basePrice"]?.toString() ?? "";
      _renovationDateController.text = data["renovationDate"] ?? "";

      final a = data["amenities"] ?? {};
      wifi = a["wifi"] ?? false;
      drinkingWater = a["drinkingWater"] ?? false;
      hotWater = a["hotWater"] ?? false;
      mess = a["mess"] ?? false;
      fan = a["fan"] ?? false;
      ac = a["ac"] ?? false;
      tv = a["tv"] ?? false;
      tableChair = a["tableChair"] ?? false;
      parking = a["parking"] ?? false;

      //if mess then fee     "messFeeMonthly": 2500

      bathroomsType = data["bathroomsType"] ?? "shared";
      electricityBillIncluded = data["electricityBillIncluded"] ?? false;
      waterBillIncluded = data["waterBillIncluded"] ?? false;
      internetIncluded = data["internetIncluded"] ?? false;
      maintenanceFee = data["maintenanceFee"] ?? 0;
      messFeeMonthly = data["messFeeMonthly"] ?? 0;

      _imageUrls.addAll(List<String>.from(data["images"] ?? []));

      if (data["location"] != null) {
        _selectedLocation = LatLng(
          data["location"]["lat"],
          data["location"]["lng"],
        );
      }
      final rules = data["extraRules"] ?? {};
      genderRule = rules["gender"] ?? "coed";
      curfewTime = rules["curfew"];
      depositMonths = rules["depositMonths"] ?? 0;
      lockInMonths = rules["lockInMonths"] ?? 0;
    }

    final hostelSnap =
        await FirebaseFirestore.instance
            .collection("hostels")
            .doc(widget.editListingId)
            .get();

    if (hostelSnap.exists) {
      final data = hostelSnap.data()!;
      floors = [];
      (data["floors"] as Map).forEach((floorId, floor) {
        final f = Map<String, dynamic>.from(floor);
        f["rooms"] = (f["rooms"] as Map).values.toList();
        for (var room in f["rooms"]) {
          room["cots"] = (room["cots"] as Map).values.toList();
        }
        floors.add(f);
      });
    }

    setState(() {});
  }

  Future<void> _pickLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
      });

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        _cityController.text = place.locality ?? "";
        _stateController.text = place.administrativeArea ?? "";
        _pincodeController.text = place.postalCode ?? "";
        _addressController.text =
            "${place.street}, ${place.subLocality}, ${place.locality}";
      }
    } catch (e) {
      debugPrint("Error picking location: $e");
    }
  }

  Future<void> _pickLocationOnMap() async {
    final picked = await LocationHelper.pickOnMap(context);
    if (picked != null) {
      setState(() {
        _selectedLocation = LatLng(picked["lat"], picked["lng"]);
        _addressController.text = picked["address"];
      });
    }
  }

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    for (var file in pickedFiles) {
      final url = await _uploadImage(File(file.path));
      setState(() => _imageUrls.add(url));
    }
  }

  Future<String> _uploadImage(File file) async {
    final ref = FirebaseStorage.instance.ref(
      "hostels/${widget.editListingId ?? DateTime.now().millisecondsSinceEpoch}/${DateTime.now().millisecondsSinceEpoch}.jpg",
    );
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  void _addFloor() {
    setState(() {
      floors.add({
        "name": "Floor ${floors.length + 1}",
        "floorNumber": floors.length,
        "rooms": [],
      });
    });
  }

  void _renameFloor(int floorIndex) async {
    final controller = TextEditingController(text: floors[floorIndex]["name"]);
    final result = await showDialog<String>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Rename Floor"),
            content: TextField(controller: controller),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, controller.text),
                child: const Text("Save"),
              ),
            ],
          ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() => floors[floorIndex]["name"] = result);
    }
  }

  void _addRoom(int floorIndex) {
    setState(() {
      floors[floorIndex]["rooms"].add({
        "name": "Room ${floors[floorIndex]["rooms"].length + 1}",
        "capacity": null,
        "cots": [],
        "features": {
          "fan": true,
          "ac": false,
          "attachedBathroom": true,
          "cupboard": true,
          "balcony": false,
          "powerBackup": true,
        },
        "images": [],
      });
    });
  }

  void _editRoom(int floorIndex, int roomIndex) async {
    final room = floors[floorIndex]["rooms"][roomIndex];
    final nameController = TextEditingController(text: room["name"]);
    final capacityController = TextEditingController(
      text: room["capacity"].toString(),
    );

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Edit Room"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Room Name"),
                ),
                TextField(
                  controller: capacityController,
                  decoration: const InputDecoration(labelText: "Capacity"),
                  keyboardType: TextInputType.number,
                ),
                SwitchListTile(
                  value: room["features"]["attachedBathroom"] ?? false,
                  onChanged:
                      (v) => setState(
                        () => room["features"]["attachedBathroom"] = v,
                      ),
                  title: const Text("Attached Bathroom"),
                ),
                SwitchListTile(
                  value: room["features"]["cupboard"] ?? false,
                  onChanged:
                      (v) => setState(() => room["features"]["cupboard"] = v),
                  title: const Text("Cupboard/Locker"),
                ),
                SwitchListTile(
                  value: room["features"]["balcony"] ?? false,
                  onChanged:
                      (v) => setState(() => room["features"]["balcony"] = v),
                  title: const Text("Balcony"),
                ),
                SwitchListTile(
                  value: room["features"]["powerBackup"] ?? false,
                  onChanged:
                      (v) =>
                          setState(() => room["features"]["powerBackup"] = v),
                  title: const Text("Power Backup"),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed:
                    () => Navigator.pop(ctx, {
                      "name": nameController.text,
                      "capacity":
                          int.tryParse(capacityController.text) ??
                          room["capacity"],
                    }),
                child: const Text("Save"),
              ),
            ],
          ),
    );

    if (result != null) {
      setState(() {
        room["name"] = result["name"];
        room["capacity"] = result["capacity"];
      });
    }
  }

  void _addCot(int floorIndex, int roomIndex) {
    final int basePrice =
        int.tryParse(_basePriceController.text) ?? 0; // fallback if empty
    setState(() {
      floors[floorIndex]["rooms"][roomIndex]["cots"].add({
        "pricePerMonth": basePrice,
        "status": "available", // available, occupied, maintenance
        "occupiedByUid": null,
      });
    });
  }

  void _editCot(int floorIndex, int roomIndex, int cotIndex) async {
    final cot = floors[floorIndex]["rooms"][roomIndex]["cots"][cotIndex];
    final priceController = TextEditingController(
      text: cot["pricePerMonth"].toString(),
    );
    String status = cot["status"];

    await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Edit Cot"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: "Price per Month",
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Available From (YYYY-MM-DD)",
                  ),
                  initialValue: cot["availableFrom"],
                  onChanged: (v) => cot["availableFrom"] = v,
                ),

                DropdownButton<String>(
                  value: status,
                  items: const [
                    DropdownMenuItem(
                      value: "available",
                      child: Text("Available"),
                    ),
                    DropdownMenuItem(
                      value: "occupied",
                      child: Text("Occupied"),
                    ),
                    DropdownMenuItem(
                      value: "maintenance",
                      child: Text("Maintenance"),
                    ),
                  ],
                  onChanged: (v) => status = v!,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    cot["pricePerMonth"] =
                        int.tryParse(priceController.text) ??
                        cot["pricePerMonth"];
                    cot["status"] = status;
                  });
                  Navigator.pop(ctx);
                },
                child: const Text("Save"),
              ),
            ],
          ),
    );
  }

  // 🔹 Save logic is same as before (no change in Firestore structure)
  Future<void> _saveListing() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isSaving = true);

    try {
      final docRef =
          widget.editListingId != null
              ? FirebaseFirestore.instance
                  .collection("listings")
                  .doc(widget.editListingId)
              : FirebaseFirestore.instance.collection("listings").doc();

      await docRef.set({
        "listingId": docRef.id,
        "ownerUid": widget.owner.uid,
        "title": _titleController.text,
        "type": "hostel",
        "images": _imageUrls,
        "address": {
          "fullAddress": _addressController.text,
          "landmark": _landmarkController.text,
          "city": _cityController.text,
          "state": _stateController.text,
          "pincode": _pincodeController.text,
        },
        "location":
            _selectedLocation != null
                ? {
                  "lat": _selectedLocation!.latitude,
                  "lng": _selectedLocation!.longitude,
                }
                : null,
        "defaultCurrency": "INR",
        "basePrice": int.tryParse(_basePriceController.text) ?? 0,
        "pricingMode": "per_cot",
        "amenities": {
          "wifi": wifi,
          "drinkingWater": drinkingWater,
          "hotWater": hotWater,
          "mess": mess,
          "fan": fan,
          "ac": ac,
          "tv": tv,
          "tableChair": tableChair,
          "parking": parking,
        },
        "messFeeMonthly": messFeeMonthly,
        "avgRating": 0,
        "reviewCount": 0,
        "bathroomsType": bathroomsType,
        "electricityBillIncluded": electricityBillIncluded,
        "waterBillIncluded": waterBillIncluded,
        "internetIncluded": internetIncluded,
        "maintenanceFee": maintenanceFee,
        "renovationDate":
            _renovationDateController.text.isNotEmpty
                ? _renovationDateController.text
                : null,
        "extraRules": {
          "gender": genderRule,
          "curfew": curfewTime,
          "depositMonths": depositMonths,
          "lockInMonths": lockInMonths,
        },
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
        "published": true,
      }, SetOptions(merge: true));

      // /hostels
      final hostelRef = FirebaseFirestore.instance
          .collection("hostels")
          .doc(docRef.id);
      Map<String, dynamic> hostelData = {"listingId": docRef.id, "floors": {}};
      for (int f = 0; f < floors.length; f++) {
        final floor = floors[f];
        final floorId = "floor$f";
        hostelData["floors"][floorId] = {
          "name": floor["name"],
          "floorNumber": floor["floorNumber"],
          "rooms": {},
        };
        for (int r = 0; r < floor["rooms"].length; r++) {
          final room = floor["rooms"][r];
          final roomId = "room$r";
          hostelData["floors"][floorId]["rooms"][roomId] = {
            "roomId": roomId,
            "name": room["name"],
            "capacity": room["capacity"],
            "cotBased": true,
            "cots": {},
          };
          for (int c = 0; c < room["cots"].length; c++) {
            final cot = room["cots"][c];
            final cotId = "cot$c";
            hostelData["floors"][floorId]["rooms"][roomId]["cots"][cotId] = cot;
          }
        }
      }
      await hostelRef.set(hostelData, SetOptions(merge: true));

      if (mounted) {
        // Show notification and wait for it to dismiss
        await AppNotifier.show(
          context,
          message:
              widget.editListingId != null
                  ? "Hostel updated!"
                  : "Hostel added!",
          type: NotificationType.success,
        );

        // Navigate back after the notification disappears
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppNotifier.show(
          context,
          message: "Error saving hostel: $e",
          type: NotificationType.error,
        );
      }
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.editListingId != null ? "Edit Hostel" : "Add Hostel",
        ),
      ),
      body:
          isSaving
              ? const Center(child: CircularProgressIndicator())
              : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Divider(),
                    ListTile(
                      title: const Text("Average Rating"),
                      trailing: Text("0 (new)"),
                    ),
                    ListTile(
                      title: const Text("Review Count"),
                      trailing: Text("0"),
                    ),

                    // 🔹 Basic info fields (unchanged from your version)
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: "Hostel Name",
                      ),
                      validator:
                          (v) => v == null || v.isEmpty ? "Required" : null,
                    ),
                    const Divider(),
                    const Text(
                      "Location",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedLocation == null
                                ? "No location selected"
                                : "Lat: ${_selectedLocation!.latitude}, Lng: ${_selectedLocation!.longitude}",
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.location_on),
                          onPressed: _pickLocation,
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.map),
                          label: const Text("Pick on Map"),
                          onPressed: _pickLocationOnMap,
                        ),
                      ],
                    ),

                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: "Full Address",
                      ),
                    ),
                    TextFormField(
                      controller: _landmarkController,
                      decoration: const InputDecoration(labelText: "Landmark"),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _cityController,
                            decoration: const InputDecoration(
                              labelText: "City",
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _stateController,
                            decoration: const InputDecoration(
                              labelText: "State",
                            ),
                          ),
                        ),
                      ],
                    ),
                    TextFormField(
                      controller: _pincodeController,
                      decoration: const InputDecoration(labelText: "Pincode"),
                      keyboardType: TextInputType.number,
                    ),
                    const Divider(),
                    const Text(
                      "Photos",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ..._imageUrls.map(
                          (url) => Stack(
                            children: [
                              Image.network(
                                url,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                  onPressed:
                                      () => setState(
                                        () => _imageUrls.remove(url),
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: _pickImages,
                          child: Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.add_a_photo),
                          ),
                        ),
                      ],
                    ),

                    TextFormField(
                      controller: _basePriceController,
                      decoration: const InputDecoration(
                        labelText: "Base Price (INR)",
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    TextFormField(
                      controller: _renovationDateController,
                      decoration: const InputDecoration(
                        labelText: "Renovation Date (YYYY-MM-DD)",
                      ),
                    ),
                    SizedBox(height: 10),
                    // Amenities
                    const Text(
                      "Amenities",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    CheckboxListTile(
                      value: wifi,
                      onChanged: (v) => setState(() => wifi = v!),
                      title: const Text("WiFi"),
                    ),
                    CheckboxListTile(
                      value: drinkingWater,
                      onChanged: (v) => setState(() => drinkingWater = v!),
                      title: const Text("Drinking Water"),
                    ),
                    CheckboxListTile(
                      value: hotWater,
                      onChanged: (v) => setState(() => hotWater = v!),
                      title: const Text("Hot Water"),
                    ),
                    CheckboxListTile(
                      value: mess,
                      onChanged: (v) => setState(() => mess = v!),
                      title: const Text("Mess"),
                    ),
                    CheckboxListTile(
                      value: fan,
                      onChanged: (v) => setState(() => fan = v!),
                      title: const Text("Fan"),
                    ),
                    CheckboxListTile(
                      value: ac,
                      onChanged: (v) => setState(() => ac = v!),
                      title: const Text("AC"),
                    ),
                    CheckboxListTile(
                      value: tv,
                      onChanged: (v) => setState(() => tv = v!),
                      title: const Text("TV"),
                    ),
                    CheckboxListTile(
                      value: tableChair,
                      onChanged: (v) => setState(() => tableChair = v!),
                      title: const Text("Table & Chair"),
                    ),
                    CheckboxListTile(
                      value: parking,
                      onChanged: (v) => setState(() => parking = v!),
                      title: const Text("Parking"),
                    ),

                    CheckboxListTile(
                      value: electricityBillIncluded,
                      onChanged:
                          (v) => setState(() => electricityBillIncluded = v!),
                      title: const Text("Electricity Included"),
                    ),
                    const Divider(),
                    const Divider(),
                    const Text(
                      "Billing Details",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    TextFormField(
                      initialValue: messFeeMonthly.toString(),
                      decoration: const InputDecoration(
                        labelText: "Mess Fee (per month)",
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => messFeeMonthly = int.tryParse(v) ?? 0,
                    ),
                    TextFormField(
                      initialValue: maintenanceFee.toString(),
                      decoration: const InputDecoration(
                        labelText: "Maintenance Fee (monthly)",
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => maintenanceFee = int.tryParse(v) ?? 0,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: "Gas Charges (monthly)",
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) {
                        /* save to gasCharges */
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: "Internet Charges (monthly)",
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) {
                        /* save to internetCharges */
                      },
                    ),

                    // Rules
                    const Text(
                      "Extra Rules",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      value: genderRule,
                      items: const [
                        DropdownMenuItem(
                          value: "male_only",
                          child: Text("Male Only"),
                        ),
                        DropdownMenuItem(
                          value: "female_only",
                          child: Text("Female Only"),
                        ),
                        DropdownMenuItem(value: "coed", child: Text("Co-ed")),
                      ],
                      onChanged: (v) => setState(() => genderRule = v!),
                      decoration: const InputDecoration(
                        labelText: "Gender Rule",
                      ),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: "Curfew Time (e.g. 10:00 PM)",
                      ),
                      initialValue: curfewTime,
                      onChanged: (v) => curfewTime = v,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: "Deposit Months",
                      ),
                      initialValue: depositMonths.toString(),
                      keyboardType: TextInputType.number,
                      onChanged:
                          (v) =>
                              depositMonths = int.tryParse(v) ?? depositMonths,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: "Lock-in Months",
                      ),
                      initialValue: lockInMonths.toString(),
                      keyboardType: TextInputType.number,
                      onChanged:
                          (v) => lockInMonths = int.tryParse(v) ?? lockInMonths,
                    ),

                    const Divider(),
                    const Text(
                      "Floors & Rooms",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    ...floors.asMap().entries.map((floorEntry) {
                      final fIndex = floorEntry.key;
                      final floor = floorEntry.value;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ExpansionTile(
                          title: Text(floor["name"]),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _renameFloor(fIndex),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed:
                                    () =>
                                        setState(() => floors.removeAt(fIndex)),
                              ),
                            ],
                          ),
                          children: [
                            ...floor["rooms"].asMap().entries.map((roomEntry) {
                              final rIndex = roomEntry.key;
                              final room = roomEntry.value;
                              return Card(
                                child: ExpansionTile(
                                  title: Text(room["name"]),
                                  subtitle: Text(
                                    "Capacity: ${room["capacity"]}, Cots: ${room["cots"].length}",
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed:
                                            () => _editRoom(fIndex, rIndex),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed:
                                            () => setState(
                                              () => floor["rooms"].removeAt(
                                                rIndex,
                                              ),
                                            ),
                                      ),
                                    ],
                                  ),

                                  children: [
                                    ...room["cots"].asMap().entries.map((
                                      cotEntry,
                                    ) {
                                      final cIndex = cotEntry.key;
                                      final cot = cotEntry.value;
                                      return ListTile(
                                        title: Text(
                                          "Cot ${cIndex + 1} - ₹${cot["pricePerMonth"]}",
                                        ),
                                        subtitle: Text(
                                          "Status: ${cot["status"]}",
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit),
                                              onPressed:
                                                  () => _editCot(
                                                    fIndex,
                                                    rIndex,
                                                    cIndex,
                                                  ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete),
                                              onPressed:
                                                  () => setState(
                                                    () => room["cots"].removeAt(
                                                      cIndex,
                                                    ),
                                                  ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    TextButton.icon(
                                      onPressed: () => _addCot(fIndex, rIndex),
                                      icon: const Icon(Icons.bed),
                                      label: const Text("Add Cot"),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            TextButton.icon(
                              onPressed: () => _addRoom(fIndex),
                              icon: const Icon(Icons.add),
                              label: const Text("Add Room"),
                            ),
                          ],
                        ),
                      );
                    }),
                    TextButton.icon(
                      onPressed: _addFloor,
                      icon: const Icon(Icons.add_business),
                      label: const Text("Add Floor"),
                    ),

                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveListing,
                      child: Text(
                        widget.editListingId != null
                            ? "Update Hostel"
                            : "Save Hostel",
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
