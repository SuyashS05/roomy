import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:romy/Helpers/Notifi_Snackbar.dart';
import 'package:romy/Pages/PgOwner/Pages/HostelDetails.dart';

class ListingsMapPage extends StatefulWidget {
  final User user;
  const ListingsMapPage({super.key, required this.user});

  @override
  State<ListingsMapPage> createState() => _ListingsMapPageState();
}

class _ListingsMapPageState extends State<ListingsMapPage> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  final Set<Marker> _markers = {};
  BitmapDescriptor? _listingIcon;

  @override
  void initState() {
    super.initState();
    _loadListings();
    _createMarkerIcon();
  }

  Future<void> _createMarkerIcon() async {
    _listingIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/icons/marker.png', // Provide your custom icon
    );
  }

  Future<void> _loadListings() async {
    final snapshot = await FirebaseFirestore.instance.collection("listings").get();
    Set<Marker> markers = {};
    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['location'] != null) {
        final lat = data['location']['lat'] as double?;
        final lng = data['location']['lng'] as double?;
        if (lat != null && lng != null) {
          markers.add(Marker(
            markerId: MarkerId(doc.id),
            position: LatLng(lat, lng),
            icon: _listingIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            infoWindow: InfoWindow(
              title: data['title'] ?? "Untitled",
              snippet: "₹${data['basePrice'] ?? 0}/month • Rating: ${data['rating'] ?? 0}",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => HostelDetailsPage(listingId: doc.id, user: widget.user.uid)),
                );
              },
            ),
          ));
        }
      }
    }

    setState(() {
      _markers.addAll(markers);
    });
  }

  Future<void> _searchLocation() async {
    final query = _searchController.text;
    if (query.isEmpty) return;

    try {
      final locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final location = locations.first;
        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(
          LatLng(location.latitude, location.longitude),
          14,
        ));
      } else {
        AppNotifier.show(context, message: "Location not found", type: NotificationType.error);
      }
    } catch (e) {
      AppNotifier.show(context, message: "Error: $e", type: NotificationType.error);
    }
  }

  void _saveListing(String listingId) {
    // Implement your save/bookmark logic here
    AppNotifier.show(context, message: "Saved listing $listingId", type: NotificationType.success);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Listings Map"),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              _mapController?.animateCamera(CameraUpdate.zoomTo(14));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Box
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: "Search city or address",
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchLocation,
                ),
              ],
            ),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(20.5937, 78.9629), // India center by default
                zoom: 5,
              ),
              markers: _markers,
              myLocationEnabled: true,
              zoomControlsEnabled: true,
              onMapCreated: (controller) => _mapController = controller,
            ),
          ),
        ],
      ),
    );
  }
}
