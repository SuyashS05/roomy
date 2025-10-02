import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:romy/Pages/PgOwner/Pages/HomeDetailsPage.dart';
import 'package:romy/Pages/PgOwner/Pages/HostelDetailsPage.dart';
import 'package:romy/Pages/PgOwner/Pages/PgDetailsPage.dart';

class ListingsMap extends StatefulWidget {
  const ListingsMap({Key? key}) : super(key: key);

  @override
  State<ListingsMap> createState() => _ListingsMapState();
}

class _ListingsMapState extends State<ListingsMap> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _center;
  double _radiusKm = 1;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  List<Map<String, dynamic>> _visibleListings = [];
  MapType _currentMapType = MapType.normal;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever)
      return;

    final pos = await Geolocator.getCurrentPosition();
    setState(() => _center = LatLng(pos.latitude, pos.longitude));
    _fetchListings();
  }

  Future<void> _fetchListings() async {
    if (_center == null) return;
    final docs = await FirebaseFirestore.instance.collection('listings').get();

    final km2m = 1000 * _radiusKm;
    final markers = <Marker>{};
    final visible = <Map<String, dynamic>>[];

    for (var doc in docs.docs) {
      final data = doc.data();
      final lat = data['location']?['lat'];
      final lng = data['location']?['lng'];
      if (lat == null || lng == null) continue;

      final d = Geolocator.distanceBetween(
        _center!.latitude,
        _center!.longitude,
        lat,
        lng,
      );

      if (d <= km2m) {
        final available = (data['status'] ?? 'available') == 'available';
        final hue =
            available ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueBlue;

        markers.add(
          Marker(
            markerId: MarkerId(doc.id),
            position: LatLng(lat, lng),
            icon: BitmapDescriptor.defaultMarkerWithHue(hue),
            infoWindow: InfoWindow(
              title: data['title'] ?? '',
              snippet: "₹${data['basePrice'] ?? ''}/month",
              onTap: () => _openDetails(doc.id, data['type'] ?? 'hostel'),
            ),
            onTap: () => _highlightListing(doc.id),
          ),
        );

        visible.add({
          'id': doc.id,
          'title': data['title'] ?? '',
          'type': data['type'] ?? 'hostel',
          'price': data['basePrice'] ?? '',
          'available': available,
          'lat': lat,
          'lng': lng,
          'image':
              (data['images'] != null && data['images'].isNotEmpty)
                  ? data['images'][0]
                  : null,
          'city': data['city'],
          'wifi': data['amenities']?['wifi'],
          'parking': data['amenities']?['parking'],
          'ac': data['amenities']?['ac'],
          'drinkingWater': data['amenities']?['drinkingWater'],
          'hotWater': data['amenities']?['hotWater'],
        });
      }
    }

    setState(() {
      _markers = markers;
      _visibleListings = visible;
      _circles = {
        Circle(
          circleId: const CircleId("radius"),
          center: _center!,
          radius: km2m,
          fillColor: Colors.red.withOpacity(0.12),
          strokeColor: Colors.redAccent,
          strokeWidth: 2,
        ),
      };
    });
  }

  void _openDetails(String id, String type) {
    Widget detailsPage;

    if (type == "home") {
      detailsPage = HomeDetailsPage(listingId: id);
    } else if (type == "pg") {
      detailsPage = PgDetailsPage(listingId: id);
    } else {
      detailsPage = HostelDetailsPage(listingId: id);
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => detailsPage));
  }

  Future<void> _highlightListing(String id) async {
    final listing = _visibleListings.firstWhere(
      (element) => element['id'] == id,
    );
    final controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(listing['lat'], listing['lng']), 17),
    );
  }

  Future<void> _updateRadius(double val) async {
    setState(() => _radiusKm = val);
    _fetchListings();
  }

  void _setMapType(MapType type) {
    setState(() => _currentMapType = type);
    Navigator.pop(context);
  }

  Widget _buildMapTypeSheet() {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Normal'),
            onTap: () => _setMapType(MapType.normal),
          ),
          ListTile(
            leading: const Icon(Icons.satellite),
            title: const Text('Satellite'),
            onTap: () => _setMapType(MapType.satellite),
          ),
          ListTile(
            leading: const Icon(Icons.terrain),
            title: const Text('Terrain'),
            onTap: () => _setMapType(MapType.terrain),
          ),
          ListTile(
            leading: const Icon(Icons.layers),
            title: const Text('Hybrid'),
            onTap: () => _setMapType(MapType.hybrid),
          ),
        ],
      ),
    );
  }

  Widget _buildRadiusControl(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.9),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            const Text(
              "Search Radius",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Slider(
              value: _radiusKm,
              min: 1,
              max: 5,
              divisions: 4,
              label: "${_radiusKm.toStringAsFixed(0)} km",
              activeColor: Colors.redAccent,
              onChanged: (val) => _updateRadius(val),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListingsOverlay(BuildContext context) {
    if (_visibleListings.isEmpty) return const SizedBox();

    return SizedBox(
      height: 250,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _visibleListings.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final l = _visibleListings[i];

          return GestureDetector(
            onTap: () {
              _highlightListing(l['id']);
              Future.delayed(const Duration(milliseconds: 900), () {
                _openDetails(l['id'], l['type']);
              });
            },

            child: Container(
              width: 260,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🖼 Image Preview
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                    child:
                        l['image'] != null
                            ? Image.network(
                              l['image'],
                              height: 120,
                              width: 260,
                              fit: BoxFit.cover,
                              loadingBuilder: (ctx, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  height: 120,
                                  width: 260,
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              },
                            )
                            : Container(
                              height: 120,
                              width: 260,
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.home,
                                size: 60,
                                color: Colors.grey,
                              ),
                            ),
                  ),

                  // 📌 Details
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l['title'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                l['city'] ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "₹${l['price']}/month",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // ✅ Amenities Icons
                        Wrap(
                          spacing: 8,
                          children: [
                            if (l['wifi'] == true)
                              const Icon(
                                Icons.wifi,
                                size: 18,
                                color: Colors.blue,
                              ),
                            if (l['parking'] == true)
                              const Icon(
                                Icons.local_parking,
                                size: 18,
                                color: Colors.green,
                              ),
                            if (l['ac'] == true)
                              const Icon(
                                Icons.ac_unit,
                                size: 18,
                                color: Colors.lightBlue,
                              ),
                            if (l['drinkingWater'] == true)
                              const Icon(
                                Icons.water_drop,
                                size: 18,
                                color: Colors.teal,
                              ),
                            if (l['hotWater'] == true)
                              const Icon(
                                Icons.hot_tub,
                                size: 18,
                                color: Colors.redAccent,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_center == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          "Discover Nearby Hostels",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        elevation: 0,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _center!, zoom: 14),
            mapType: _currentMapType,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            compassEnabled: true,
            zoomGesturesEnabled: true,
            onMapCreated: (c) => _controller.complete(c),
            markers: _markers,
            circles: _circles,
            onTap: (pos) {
              setState(() => _center = pos);
              _fetchListings();
            },
          ),

          // Radius slider bottom sheet
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: _buildRadiusControl(context),
          ),

          // Visible listings overlay (collapsible)
          Positioned(
            top: 80,
            left: 16,
            right: 16,
            child: _buildListingsOverlay(context),
          ),

          // Recenter button
          Positioned(
            bottom: 90,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.primary,
              onPressed: () async {
                final controller = await _controller.future;
                controller.animateCamera(
                  CameraUpdate.newLatLngZoom(_center!, 14),
                );
              },
              child: const Icon(Icons.my_location),
            ),
          ),

          // Map layers button
          Positioned(
            top: 90,
            right: 16,
            child: FloatingActionButton(
              heroTag: "layersBtn",
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: const Icon(Icons.layers),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (ctx) => _buildMapTypeSheet(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


/*
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:romy/Pages/PgOwner/Pages/HostelDetailsPage.dart';

class ListingsMap extends StatefulWidget {
  const ListingsMap({Key? key}) : super(key: key);

  @override
  State<ListingsMap> createState() => _ListingsMapState();
}

class _ListingsMapState extends State<ListingsMap> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _center;
  double _radiusKm = 1;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    final perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) return;

    final pos = await Geolocator.getCurrentPosition();
    setState(() => _center = LatLng(pos.latitude, pos.longitude));
    _fetchListings();
  }

  Future<void> _fetchListings() async {
    if (_center == null) return;
    final docs =
        await FirebaseFirestore.instance.collection('listings').get();

    final km2m = 1000 * _radiusKm;
    final markers = <Marker>{};

    for (var doc in docs.docs) {
      final data = doc.data();
      final lat = data['location']?['lat'];
      final lng = data['location']?['lng'];
      if (lat == null || lng == null) continue;

      final d = Geolocator.distanceBetween(
          _center!.latitude, _center!.longitude, lat, lng);

      if (d <= km2m) {
        final available = (data['status'] ?? 'available') == 'available';
        final markerColor = available
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
            : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);

        markers.add(Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(lat, lng),
          icon: markerColor,
          infoWindow: InfoWindow(
            title: data['title'],
            snippet: "₹${data['basePrice'] ?? ''}/month",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HostelDetailsPage(listingId: doc.id),
                ),
              );
            },
          ),
        ));
      }
    }

    setState(() {
      _markers = markers;
      _circles = {
        Circle(
          circleId: const CircleId("radius"),
          center: _center!,
          radius: km2m,
          fillColor: Colors.red.withOpacity(0.1),
          strokeColor: Colors.redAccent,
          strokeWidth: 2,
        )
      };
    });
  }

  Future<void> _updateRadius(double newRadius) async {
    setState(() => _radiusKm = newRadius);
    _fetchListings();
  }

  @override
  Widget build(BuildContext context) {
    if (_center == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nearby Hostels"),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
                CameraPosition(target: _center!, zoom: 15),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (c) => _controller.complete(c),
            markers: _markers,
            circles: _circles,
            onTap: (pos) {
              // Change center to tapped location
              setState(() => _center = pos);
              _fetchListings();
            },
          ),
          // Radius Control Panel
          Positioned(
            top: 16,
            right: 10,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    const Text("Radius: "),
                    DropdownButton<double>(
                      value: _radiusKm,
                      underline: const SizedBox(),
                      items: [1, 2, 3, 4, 5]
                          .map((e) => DropdownMenuItem(
                                value: e.toDouble(),
                                child: Text("${e} km"),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) _updateRadius(val);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
*/