import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationHelper {
  /// ✅ Get current location + address
  static Future<Map<String, dynamic>?> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception("Location permissions are denied");
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception("Location permissions are permanently denied");
      }

      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks =
          await placemarkFromCoordinates(pos.latitude, pos.longitude);

      String address = placemarks.isNotEmpty
          ? "${placemarks.first.street}, ${placemarks.first.locality}, ${placemarks.first.administrativeArea}, ${placemarks.first.country}"
          : "Unknown location";

      return {
        "lat": pos.latitude,
        "lng": pos.longitude,
        "address": address,
      };
    } catch (e) {
      debugPrint("❌ Error getting location: $e");
      return null;
    }
  }

  /// ✅ Pick location manually on Google Maps
  static Future<Map<String, dynamic>?> pickOnMap(BuildContext context) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => _PickLocationScreen(),
      ),
    );
  }
}

class _PickLocationScreen extends StatefulWidget {
  @override
  State<_PickLocationScreen> createState() => _PickLocationScreenState();
}

class _PickLocationScreenState extends State<_PickLocationScreen> {
  LatLng? _selected;
  LatLng? _currentLatLng;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    final loc = await LocationHelper.getCurrentLocation();
    if (loc != null) {
      setState(() {
        _currentLatLng = LatLng(loc["lat"], loc["lng"]);
      });

      // Move camera when map is ready
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(_currentLatLng!, 16),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pick Location")),
      body: _currentLatLng == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentLatLng!,
                zoom: 16,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onTap: (latLng) {
                setState(() {
                  _selected = latLng;
                });
              },
              markers: _selected != null
                  ? {
                      Marker(
                        markerId: const MarkerId("selected"),
                        position: _selected!,
                      )
                    }
                  : {},
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_selected != null) {
            List<Placemark> placemarks = await placemarkFromCoordinates(
              _selected!.latitude,
              _selected!.longitude,
            );

            String address = placemarks.isNotEmpty
                ? "${placemarks.first.street}, ${placemarks.first.locality}, ${placemarks.first.administrativeArea}, ${placemarks.first.country}"
                : "Unknown location";

            Navigator.pop(context, {
              "lat": _selected!.latitude,
              "lng": _selected!.longitude,
              "address": address,
            });
          } else {
            Navigator.pop(context, null);
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
