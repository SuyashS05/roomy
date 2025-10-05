import 'dart:ui';

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

      return await _reverseGeocode(pos.latitude, pos.longitude);
    } catch (e) {
      debugPrint("❌ Error getting location: $e");
      return null;
    }
  }

  /// ✅ Reverse geocode helper
  static Future<Map<String, dynamic>> _reverseGeocode(
      double lat, double lng) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(lat, lng);

    Placemark place = placemarks.isNotEmpty ? placemarks.first : Placemark();

    return {
      "lat": lat,
      "lng": lng,
      "address":
          "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}",
      "city": place.locality ?? "",
      "state": place.administrativeArea ?? "",
      "country": place.country ?? "",
      "pincode": place.postalCode ?? "",
    };
  }

  /// ✅ Pick location manually on Google Maps
  static Future<Map<String, dynamic>?> pickOnMap(
    BuildContext context, {
    LatLng? initialLocation,
  }) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) =>
            _PickLocationScreen(initialLocation: initialLocation),
      ),
    );
  }
}

class _PickLocationScreen extends StatefulWidget {
  final LatLng? initialLocation;
  const _PickLocationScreen({this.initialLocation});

  @override
  State<_PickLocationScreen> createState() => _PickLocationScreenState();
}

class _PickLocationScreenState extends State<_PickLocationScreen> {
  GoogleMapController? _mapController;
  LatLng? _center;
  String _currentAddress = "Fetching address...";
  bool _isMoving = false;

  @override
  void initState() {
    super.initState();
    _initMap();
  }

  Future<void> _initMap() async {
    if (widget.initialLocation != null) {
      setState(() {
        _center = widget.initialLocation;
      });
      _updateAddressFromLatLng(widget.initialLocation!);
    } else {
      final loc = await LocationHelper.getCurrentLocation();
      if (loc != null) {
        setState(() {
          _center = LatLng(loc["lat"], loc["lng"]);
          _currentAddress = loc["address"];
        });
      }
    }
  }

  Future<void> _updateAddressFromLatLng(LatLng pos) async {
    final data =
        await LocationHelper._reverseGeocode(pos.latitude, pos.longitude);
    setState(() => _currentAddress = data["address"]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pick Location")),
      body: _center == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              alignment: Alignment.center,
              children: [
                /// 🌍 Map
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _center!,
                    zoom: 17,
                  ),
                  onMapCreated: (controller) => _mapController = controller,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  onCameraMoveStarted: () {
                    setState(() {
                      _isMoving = true;
                      _currentAddress = "Moving...";
                    });
                  },
                  onCameraIdle: () async {
                    LatLng center = await _mapController!.getLatLng(
                      ScreenCoordinate(
                        x: MediaQuery.of(context).size.width ~/ 2,
                        y: MediaQuery.of(context).size.height ~/ 2,
                      ),
                    );
                    setState(() => _isMoving = false);
                    _updateAddressFromLatLng(center);
                  },
                ),

                /// 📍 Animated Center Pin
                AnimatedPadding(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.only(bottom: _isMoving ? 20 : 0),
                  child: const Icon(Icons.location_pin,
                      size: 50, color: Colors.redAccent),
                ),

                /// 🪟 Glassmorphic Address Card
                Positioned(
                  bottom: 90,
                  left: 20,
                  right: 20,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: BackdropFilter(
                      filter:
                          ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.white.withOpacity(0.6),
                        child: Row(
                          children: [
                            const Icon(Icons.place, color: Colors.redAccent),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _currentAddress,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

      /// ✅ Confirm Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          LatLng center = await _mapController!.getLatLng(
            ScreenCoordinate(
              x: MediaQuery.of(context).size.width ~/ 2,
              y: MediaQuery.of(context).size.height ~/ 2,
            ),
          );

          final data =
              await LocationHelper._reverseGeocode(center.latitude, center.longitude);

          Navigator.pop(context, data);
        },
        label: const Text("Confirm Location"),
        icon: const Icon(Icons.check),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
