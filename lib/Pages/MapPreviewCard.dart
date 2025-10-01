import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:romy/Pages/ListingsMap.dart';

class MapPreviewCard extends StatefulWidget {
  const MapPreviewCard({Key? key}) : super(key: key);

  @override
  State<MapPreviewCard> createState() => _MapPreviewCardState();
}

class _MapPreviewCardState extends State<MapPreviewCard> {
  LatLng? _userLatLng;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    try {
      final perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        // fallback: India center
        setState(() {
          _userLatLng = const LatLng(20.5937, 78.9629);
          _loading = false;
        });
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      setState(() {
        _userLatLng = LatLng(pos.latitude, pos.longitude);
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _userLatLng = const LatLng(20.5937, 78.9629);
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ListingsMap()),
        );
      },
      child: Stack(
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: _loading
                  ? Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _userLatLng!,
                        zoom: 14, // nice street-level zoom
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId('me'),
                          position: _userLatLng!,
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueAzure),
                        )
                      },
                      zoomControlsEnabled: false,
                      scrollGesturesEnabled: false,
                      tiltGesturesEnabled: false,
                      rotateGesturesEnabled: false,
                      myLocationEnabled: false,
                      liteModeEnabled:
                          true, // fast lightweight preview for performance
                    ),
            ),
          ),
          Positioned(
            right: 12,
            top: 12,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.zoom_out_map),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ListingsMap()),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}


/*
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:romy/Pages/ListingsMap.dart';

class MapPreviewCard extends StatefulWidget {
  const MapPreviewCard({Key? key}) : super(key: key);

  @override
  State<MapPreviewCard> createState() => _MapPreviewCardState();
}

class _MapPreviewCardState extends State<MapPreviewCard> {
  double? _latitude;
  double? _longitude;
  bool _loading = true;

  final String _googleApiKey = 'YOUR_GOOGLE_MAPS_STATIC_API_KEY';

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _setFallbackLocation();
        return;
      }

      final pos = await Geolocator.getCurrentPosition();
      setState(() {
        _latitude = pos.latitude;
        _longitude = pos.longitude;
        _loading = false;
      });
    } catch (_) {
      _setFallbackLocation();
    }
  }

  void _setFallbackLocation() {
    setState(() {
      _latitude = 20.5937; // India center
      _longitude = 78.9629;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _latitude != null && _longitude != null
        ? 'https://maps.googleapis.com/maps/api/staticmap'
            '?center=$_latitude,$_longitude'
            '&zoom=14'
            '&size=600x300'
            '&markers=color:blue%7Clabel:M%7C$_latitude,$_longitude'
            '&key=$_googleApiKey'
        : null;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ListingsMap()),
      ),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: _loading || imageUrl == null
              ? Container(
                  color: Colors.grey.shade200,
                  child: const Center(child: CircularProgressIndicator()),
                )
              : Stack(
                  children: [
                    Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.zoom_out_map),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ListingsMap()),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
 */