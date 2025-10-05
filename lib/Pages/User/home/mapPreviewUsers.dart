import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapPreviewWidget extends StatefulWidget {
  final double radius;
  const MapPreviewWidget({super.key, this.radius = 500});

  @override
  State<MapPreviewWidget> createState() => _MapPreviewWidgetState();
}

class _MapPreviewWidgetState extends State<MapPreviewWidget>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  LatLng? _currentPosition;
  GoogleMapController? _mapController;
  AnimationController? _pulseController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();

    // Setup pulse animation for circle
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    Position position =
        await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    if (mounted) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      height: 220,
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentPosition!,
                      zoom: 15,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                    circles: {
                      Circle(
                        circleId: const CircleId('user_radius'),
                        center: _currentPosition!,
                        radius: widget.radius,
                        fillColor: Colors.orange.withOpacity(0.2),
                        strokeColor: Colors.orange.withOpacity(0.5),
                        strokeWidth: 2,
                      ),
                    },
                  ),
                  // Gradient overlay for style
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Floating location button
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: FloatingActionButton(
                      backgroundColor: Colors.orange,
                      mini: true,
                      onPressed: () {
                        if (_mapController != null && _currentPosition != null) {
                          _mapController!.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(target: _currentPosition!, zoom: 17),
                            ),
                          );
                        }
                      },
                      child: const Icon(Icons.my_location),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
