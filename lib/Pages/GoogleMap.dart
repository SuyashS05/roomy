import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSample extends StatefulWidget {
  final LatLng? initialLocation;

  const MapSample({super.key, this.initialLocation});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _currentPosition;
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};

  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(16.7087, 74.2795),
    zoom: 14.0,
  );

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    LatLng position;

    if (widget.initialLocation != null) {
      position = widget.initialLocation!;
    } else {
      Position userPosition = await _determinePosition();
      position = LatLng(userPosition.latitude, userPosition.longitude);
    }

    setState(() {
      _currentPosition = position;

      _markers.add(
        Marker(
          markerId: const MarkerId("user_location"),
          position: _currentPosition!,
          infoWindow: const InfoWindow(title: "You are here"),
        ),
      );

      _circles.add(
        Circle(
          circleId: const CircleId("user_radius"),
          center: _currentPosition!,
          radius: 1000, // 1 km
          fillColor: Colors.orange.withOpacity(0.2),
          strokeColor: Colors.orange.withOpacity(0.5),
          strokeWidth: 2,
        ),
      );
    });

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentPosition!, zoom: 15),
      ),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled.");
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permissions are permanently denied.");
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Map View")),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition:
                  widget.initialLocation != null ? CameraPosition(target: widget.initialLocation!, zoom: 15) : _defaultPosition,
              markers: _markers,
              circles: _circles,
              mapType: MapType.normal,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              compassEnabled: true,
              tiltGesturesEnabled: true,
              rotateGesturesEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Move camera to current location
          Position pos = await _determinePosition();
          LatLng newPos = LatLng(pos.latitude, pos.longitude);

          setState(() {
            _markers.clear();
            _markers.add(Marker(
              markerId: const MarkerId("user_location"),
              position: newPos,
              infoWindow: const InfoWindow(title: "You are here"),
            ));

            _circles.clear();
            _circles.add(Circle(
              circleId: const CircleId("user_radius"),
              center: newPos,
              radius: 1000,
              fillColor: Colors.orange.withOpacity(0.2),
              strokeColor: Colors.orange.withOpacity(0.5),
              strokeWidth: 2,
            ));
          });

          final GoogleMapController controller = await _controller.future;
          controller.animateCamera(CameraUpdate.newCameraPosition(
              CameraPosition(target: newPos, zoom: 15)));
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
