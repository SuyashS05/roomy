import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class PrivateStorageImage extends StatefulWidget {
  final String path;
  final BoxFit fit;

  const PrivateStorageImage({
    required this.path,
    this.fit = BoxFit.contain,
    super.key,
  });

  @override
  State<PrivateStorageImage> createState() => _PrivateStorageImageState();
}

class _PrivateStorageImageState extends State<PrivateStorageImage> {
  late Future<Uint8List?> _image;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(covariant PrivateStorageImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) _loadImage();
  }

  void _loadImage() {
    _image = FirebaseStorage.instance
        .ref(widget.path)
        .getData(10 * 1024 * 1024);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _image,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final bytes = snapshot.data;
        if (snapshot.hasError || bytes == null) {
          return const Center(child: Text('Unable to load private image'));
        }
        return Image.memory(bytes, fit: widget.fit);
      },
    );
  }
}

Future<void> showPrivateStorageImageDialog(
  BuildContext context,
  String path,
  String title,
) {
  return showDialog<void>(
    context: context,
    builder:
        (context) => Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(padding: const EdgeInsets.all(12), child: Text(title)),
              SizedBox(
                height: 420,
                child: InteractiveViewer(
                  child: PrivateStorageImage(path: path),
                ),
              ),
            ],
          ),
        ),
  );
}
