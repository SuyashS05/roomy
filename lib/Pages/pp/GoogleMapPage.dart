import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:get/get.dart';
import 'package:romy/Pages/pp/RoomInfoPageGoogle.dart';
class GoogleMapPage extends StatefulWidget {
  @override
  State<GoogleMapPage> createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  Location _locationController = Location();
  LatLng? currentPos;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentPos == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
        initialCameraPosition: CameraPosition(
          target: currentPos!,
          zoom: 15,
        ),
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        markers: {
          Marker(
            markerId: MarkerId("My Current Location"),
            position: currentPos!,
            icon: BitmapDescriptor.defaultMarker,
            onTap: () {
              Get.to(Roominfopage()); // ✅ Navigate on marker tap
            },
            infoWindow: InfoWindow(
              title: "My Location",
            ),
          ),
          Marker(
            markerId: MarkerId("Location 2"),
            position: LatLng(16.6948, 74.2228),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            infoWindow: InfoWindow(title: "Location 2"),
          ),
          Marker(
            markerId: MarkerId("Location 3"),
            position: LatLng(16.6954, 74.2218),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            infoWindow: InfoWindow(title: "Location 3"),
          ),Marker(
            markerId: MarkerId("Location 4"),
            position: LatLng(16.653944, 74.262285),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            infoWindow: InfoWindow(title: "Location 4"),
          ),Marker(
            markerId: MarkerId("Location 5"),
            position: LatLng(16.685,74.331),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            infoWindow: InfoWindow(title: "Location 5"),
          ),


        },
      ),
    );
  }

  Future<void> getUserLocation() async {
    bool serviceEnabled;
    PermissionStatus _permissionGranted;

    // Check if location service is enabled
    serviceEnabled = await _locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    // Check for location permission
    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // Listen for location updates
    _locationController.onLocationChanged.listen((LocationData _currentLocation) {
      if (_currentLocation.latitude != null &&
          _currentLocation.longitude != null) {
        setState(() {
          currentPos =
              LatLng(_currentLocation.latitude!, _currentLocation.longitude!);
        });

        // Move camera smoothly to new position
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(currentPos!),
        );

        print("Current Location: $currentPos");
      }
    });
  }
}
