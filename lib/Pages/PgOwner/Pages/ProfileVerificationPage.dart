import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:romy/Helpers/private_storage_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:romy/Helpers/Notifi_Snackbar.dart';
import 'package:romy/Models/Users.dart';
import 'package:easy_localization/easy_localization.dart';

class RoomOwnerVerificationPage extends StatefulWidget {
  final UserModel user;
  const RoomOwnerVerificationPage({super.key, required this.user});

  @override
  State<RoomOwnerVerificationPage> createState() =>
      _RoomOwnerVerificationPageState();
}

class _RoomOwnerVerificationPageState extends State<RoomOwnerVerificationPage> {
  static final Map<String, Map<String, dynamic>> _cache = {};
  final _formKey = GlobalKey<FormState>();

  final _aadhaarController = TextEditingController();
  final _aadhaarNameController = TextEditingController();
  final _panController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _instagramController = TextEditingController();

  File? _pickedImage;
  String? _existingImagePath;
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  /// Load existing verification data from Firestore
  Future<void> _loadExistingData() async {
    try {
      if (_cache.containsKey(widget.user.uid)) {
        // Use cached data
        final data = _cache[widget.user.uid]!;
        setState(() {
          _isEditing = true;
          _aadhaarController.text = data["aadhaarNumber"] ?? "";
          _aadhaarNameController.text = data["aadhaarName"] ?? "";
          _panController.text = data["panNumber"] ?? "";
          _whatsappController.text = data["whatsapp"] ?? "";
          _instagramController.text = data["instagram"] ?? "";
          _existingImagePath = data["addressProofPath"];
        });
        return; // Skip Firestore read
      }

      // Otherwise, fetch from Firestore
      final doc =
          await FirebaseFirestore.instance
              .collection("RoomOwners")
              .doc(widget.user.uid)
              .get();

      if (doc.exists) {
        final data = doc.data()!;
        _cache[widget.user.uid] = data; // Cache it
        setState(() {
          _isEditing = true;
          _aadhaarController.text = data["aadhaarNumber"] ?? "";
          _aadhaarNameController.text = data["aadhaarName"] ?? "";
          _panController.text = data["panNumber"] ?? "";
          _whatsappController.text = data["whatsapp"] ?? "";
          _instagramController.text = data["instagram"] ?? "";
          _existingImagePath = data["addressProofPath"];
        });
      }
    } catch (e) {
      AppNotifier.show(
        context,
        message: "error_loading_data".tr(args: [e.toString()]),
        type: NotificationType.error,
      );
    }
  }

  /// Pick image from gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
        _existingImagePath = null;
      });
    }
  }

  /// Compress & upload image
  Future<String?> _uploadImage(File file) async {
    try {
      Uint8List? compressed = await FlutterImageCompress.compressWithFile(
        file.path,
        minWidth: 800,
        minHeight: 800,
        quality: 50,
      );

      if (compressed == null) return null;

      final path =
          "room_owner_verifications/${widget.user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg";
      final ref = FirebaseStorage.instance.ref(path);

      await ref.putData(compressed);
      return path;
    } catch (e) {
      debugPrint("Upload Error: $e");
      return null;
    }
  }

  /// Submit / Update verification request
  Future<void> _submitVerification() async {
    if (!_formKey.currentState!.validate()) return;

    if (_pickedImage == null && _existingImagePath == null) {
      AppNotifier.show(
        context,
        message: "upload_address_proof".tr(),
        type: NotificationType.warning,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imagePath = _existingImagePath;

      if (_pickedImage != null) {
        imagePath = await _uploadImage(_pickedImage!);
      }

      await FirebaseFirestore.instance
          .collection("RoomOwners")
          .doc(widget.user.uid)
          .set({
            "uid": widget.user.uid,
            "aadhaarNumber": _aadhaarController.text.trim(),
            "aadhaarName": _aadhaarNameController.text.trim(),
            "panNumber": _panController.text.trim(),
            "whatsapp": _whatsappController.text.trim(),
            "instagram": _instagramController.text.trim(),
            "addressProofPath": imagePath ?? "",
            "submittedAt": FieldValue.serverTimestamp(),
            "adminCheck": "pending",
            "adminVerified": false,
            "unverifiedReason": "",
          }, SetOptions(merge: true));

      // Update cache
      _cache[widget.user.uid] = {
        "aadhaarNumber": _aadhaarController.text.trim(),
        "aadhaarName": _aadhaarNameController.text.trim(),
        "panNumber": _panController.text.trim(),
        "whatsapp": _whatsappController.text.trim(),
        "instagram": _instagramController.text.trim(),
        "addressProofPath": imagePath ?? "",
        "adminCheck": "pending",
        "adminVerified": false,
      };

      if (mounted) {
        AppNotifier.show(
          context,
          message:
              _isEditing
                  ? "verification_updated".tr()
                  : "verification_submitted".tr(),
          type: NotificationType.success,
        );

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });
      }
    } catch (e) {
      AppNotifier.show(
        context,
        message: "error_submitting".tr(args: [e.toString()]),
        type: NotificationType.error,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _aadhaarController.dispose();
    _aadhaarNameController.dispose();
    _panController.dispose();
    _whatsappController.dispose();
    _instagramController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? "update_verification".tr() : "profile_verification".tr(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                "submit_kyc".tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),

              // Aadhaar Number
              TextFormField(
                controller: _aadhaarController,
                decoration: InputDecoration(
                  labelText: "aadhaar_number".tr(),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                maxLength: 12,
                validator: (value) {
                  if (value == null || value.length != 12) {
                    return "enter_valid_aadhaar".tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Aadhaar Name
              TextFormField(
                controller: _aadhaarNameController,
                decoration: InputDecoration(
                  labelText: "aadhaar_name".tr(),
                  border: const OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? "required_field".tr()
                            : null,
              ),
              const SizedBox(height: 16),

              // PAN
              TextFormField(
                controller: _panController,
                decoration: InputDecoration(
                  labelText: "pan_number".tr(),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // WhatsApp
              TextFormField(
                controller: _whatsappController,
                decoration: InputDecoration(
                  labelText: "whatsapp_number".tr(),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? "whatsapp_required".tr()
                            : null,
              ),
              const SizedBox(height: 16),

              // Instagram
              TextFormField(
                controller: _instagramController,
                decoration: InputDecoration(
                  labelText: "instagram_link".tr(),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Address Proof
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.image, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _pickedImage != null
                              ? "image_selected".tr()
                              : _existingImagePath != null
                              ? "old_image_attached".tr()
                              : "upload_address_proof".tr(),
                        ),
                      ),
                      if (_pickedImage != null || _existingImagePath != null)
                        const Icon(Icons.check_circle, color: Colors.green),
                      if (_existingImagePath != null && _pickedImage == null)
                        IconButton(
                          icon: const Icon(
                            Icons.remove_red_eye,
                            color: Colors.blue,
                          ),
                          onPressed:
                              () => showPrivateStorageImageDialog(
                                context,
                                _existingImagePath!,
                                "Address Proof",
                              ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.verified_user),
                    label: Text(
                      _isEditing
                          ? "update_verification_request".tr()
                          : "submit_verification".tr(),
                    ),
                    onPressed: _submitVerification,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
