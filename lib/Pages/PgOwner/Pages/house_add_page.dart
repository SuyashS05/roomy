import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:romy/Helpers/Notifi_Snackbar.dart';
import 'package:romy/Pages/locationpiker.dart';

class HomeAddPage extends StatefulWidget {
  final User owner;
  final String? editListingId;

  const HomeAddPage({super.key, required this.owner, this.editListingId});

  @override
  State<HomeAddPage> createState() => _HomeAddPageState();
}

class _HomeAddPageState extends State<HomeAddPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
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
  bool ac = false;
  bool parking = false;
  bool garden = false;
  bool pool = false;
  bool security = false;

  // Bills
  bool electricityBillIncluded = true;
  bool waterBillIncluded = true;
  bool internetIncluded = true;
  int maintenanceFee = 0;

  // Rules
  String genderRule = "coed";
  String? curfewTime;
  int depositMonths = 0;
  int lockInMonths = 0;

  // Location
  LatLng? _selectedLocation;

  // Images
  final List<String> _imageUrls = [];
  final ImagePicker _picker = ImagePicker();

  // Floors & Rooms
  List<Map<String, dynamic>> floors = [];

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.editListingId != null) _loadExistingData();
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
      ac = a["ac"] ?? false;
      parking = a["parking"] ?? false;
      garden = a["garden"] ?? false;
      pool = a["pool"] ?? false;
      security = a["security"] ?? false;

      electricityBillIncluded = data["electricityBillIncluded"] ?? true;
      waterBillIncluded = data["waterBillIncluded"] ?? true;
      internetIncluded = data["internetIncluded"] ?? true;
      maintenanceFee = data["maintenanceFee"] ?? 0;

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

      final homeSnap =
          await FirebaseFirestore.instance
              .collection("homes")
              .doc(widget.editListingId)
              .get();

      if (homeSnap.exists) {
        floors = [];
        (homeSnap.data()!["floors"] as Map).forEach((floorId, floor) {
          final f = Map<String, dynamic>.from(floor);
          f["rooms"] = (f["rooms"] as Map).values.toList();
          floors.add(f);
        });
      }
      setState(() {});
    }
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

  // Future<void> _pickLocation() async {
  //   final selected = await Navigator.push<LatLng>(
  //     context,
  //     MaterialPageRoute(
  //       builder: (_) => LocationPicker(initialLocation: _selectedLocation),
  //     ),
  //   );

  //   if (selected != null) {
  //     setState(() => _selectedLocation = selected);

  //     // Optional: Reverse geocode to fill city/state/pincode/address
  //     try {
  //       final placemarks = await placemarkFromCoordinates(
  //         selected.latitude,
  //         selected.longitude,
  //       );
  //       if (placemarks.isNotEmpty) {
  //         final place = placemarks.first;
  //         _cityController.text = place.locality ?? "";
  //         _stateController.text = place.administrativeArea ?? "";
  //         _pincodeController.text = place.postalCode ?? "";
  //         _addressController.text =
  //             "${place.street}, ${place.subLocality}, ${place.locality}";
  //       }
  //     } catch (e) {
  //       debugPrint("Error reverse geocoding: $e");
  //     }
  //   }
  // }

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    for (var file in pickedFiles) {
      final url = await _uploadImage(File(file.path));
      setState(() => _imageUrls.add(url));
    }
  }

  Future<String> _uploadImage(File file) async {
    final ref = FirebaseStorage.instance.ref(
      "homes/${widget.editListingId ?? DateTime.now().millisecondsSinceEpoch}/${DateTime.now().millisecondsSinceEpoch}.jpg",
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
        "size": null,
        "price": int.tryParse(_basePriceController.text) ?? 0,
        "features": {
          "ac": false,
          "fan": true,
          "attachedBathroom": true,
          "balcony": false,
          "wardrobe": true,
        },
        "images": [],
      });
    });
  }

  void _editRoom(int floorIndex, int roomIndex) async {
    final room = floors[floorIndex]["rooms"][roomIndex];
    final nameController = TextEditingController(text: room["name"]);
    final sizeController = TextEditingController(
      text: room["size"]?.toString(),
    );
    final priceController = TextEditingController(
      text: room["price"]?.toString(),
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
                  controller: sizeController,
                  decoration: const InputDecoration(
                    labelText: "Room Size (sq.ft)",
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: "Price"),
                  keyboardType: TextInputType.number,
                ),
                SwitchListTile(
                  value: room["features"]["attachedBathroom"] ?? true,
                  onChanged:
                      (v) => setState(
                        () => room["features"]["attachedBathroom"] = v,
                      ),
                  title: const Text("Attached Bathroom"),
                ),
                SwitchListTile(
                  value: room["features"]["balcony"] ?? false,
                  onChanged:
                      (v) => setState(() => room["features"]["balcony"] = v),
                  title: const Text("Balcony"),
                ),
                SwitchListTile(
                  value: room["features"]["wardrobe"] ?? true,
                  onChanged:
                      (v) => setState(() => room["features"]["wardrobe"] = v),
                  title: const Text("Wardrobe"),
                ),
                SwitchListTile(
                  value: room["features"]["ac"] ?? false,
                  onChanged: (v) => setState(() => room["features"]["ac"] = v),
                  title: const Text("AC"),
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
                      "size": int.tryParse(sizeController.text) ?? room["size"],
                      "price":
                          int.tryParse(priceController.text) ?? room["price"],
                    }),
                child: const Text("Save"),
              ),
            ],
          ),
    );

    if (result != null) {
      setState(() {
        room["name"] = result["name"];
        room["size"] = result["size"];
        room["price"] = result["price"];
      });
    }
  }

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
        "type": "home",
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
        "amenities": {
          "wifi": wifi,
          "drinkingWater": drinkingWater,
          "hotWater": hotWater,
          "ac": ac,
          "parking": parking,
          "garden": garden,
          "pool": pool,
          "security": security,
        },
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

      final homeRef = FirebaseFirestore.instance
          .collection("homes")
          .doc(docRef.id);
      Map<String, dynamic> homeData = {"listingId": docRef.id, "floors": {}};

      for (int f = 0; f < floors.length; f++) {
        final floor = floors[f];
        final floorId = "floor$f";
        homeData["floors"][floorId] = {
          "name": floor["name"],
          "floorNumber": floor["floorNumber"],
          "rooms": {},
        };
        for (int r = 0; r < floor["rooms"].length; r++) {
          final room = floor["rooms"][r];
          final roomId = "room$r";
          homeData["floors"][floorId]["rooms"][roomId] = {
            "roomId": roomId,
            "name": room["name"],
            "size": room["size"],
            "price": room["price"],
            "features": room["features"],
            "images": room["images"],
          };
        }
      }

      await homeRef.set(homeData, SetOptions(merge: true));

      if (mounted) {
        await AppNotifier.show(
          context,
          message:
              widget.editListingId != null ? "Home updated!" : "Home added!",
          type: NotificationType.success,
        );
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppNotifier.show(
          context,
          message: "Error saving home: $e",
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
        title: Text(widget.editListingId != null ? "Edit Home" : "Add Home"),
      ),
      body:
          isSaving
              ? const Center(child: CircularProgressIndicator())
              : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: "Home Name"),
                      validator:
                          (v) => v == null || v.isEmpty ? "Required" : null,
                    ),
                    const Divider(),
                    const Text(
                      "Location",
                      style: TextStyle(fontWeight: FontWeight.bold),
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
                      style: TextStyle(fontWeight: FontWeight.bold),
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
                    const SizedBox(height: 10),
                    const Text(
                      "Amenities",
                      style: TextStyle(fontWeight: FontWeight.bold),
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
                      value: ac,
                      onChanged: (v) => setState(() => ac = v!),
                      title: const Text("AC"),
                    ),
                    CheckboxListTile(
                      value: parking,
                      onChanged: (v) => setState(() => parking = v!),
                      title: const Text("Parking"),
                    ),
                    CheckboxListTile(
                      value: garden,
                      onChanged: (v) => setState(() => garden = v!),
                      title: const Text("Garden"),
                    ),
                    CheckboxListTile(
                      value: pool,
                      onChanged: (v) => setState(() => pool = v!),
                      title: const Text("Swimming Pool"),
                    ),
                    CheckboxListTile(
                      value: security,
                      onChanged: (v) => setState(() => security = v!),
                      title: const Text("Security"),
                    ),
                    const Divider(),
                    const Text(
                      "Billing Details",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextFormField(
                      initialValue: maintenanceFee.toString(),
                      decoration: const InputDecoration(
                        labelText: "Maintenance Fee (monthly)",
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => maintenanceFee = int.tryParse(v) ?? 0,
                    ),
                    const Divider(),
                    const Text(
                      "Extra Rules",
                      style: TextStyle(fontWeight: FontWeight.bold),
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
                        labelText: "Curfew Time (e.g., 10:00 PM)",
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
                      style: TextStyle(fontWeight: FontWeight.bold),
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
                                child: ListTile(
                                  title: Text(
                                    "${room["name"]} - ₹${room["price"]}",
                                  ),
                                  subtitle: Text(
                                    "Size: ${room["size"] ?? 'N/A'} sq.ft",
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
                                ),
                              );
                            }).toList(),
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
                            ? "Update Home"
                            : "Save Home",
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
