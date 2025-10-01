import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:romy/Pages/notFoundPage.dart';

class HomeDetailsPage extends StatefulWidget {
  final String listingId;
  const HomeDetailsPage({Key? key, required this.listingId}) : super(key: key);

  @override
  State<HomeDetailsPage> createState() => _HomeDetailsPageState();
}

class _HomeDetailsPageState extends State<HomeDetailsPage> {
  Map<String, dynamic>? listing;
  Map<String, dynamic>? home;
  bool loading = true;
  int _currentImage = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final listSnap =
        await FirebaseFirestore.instance
            .collection('listings')
            .doc(widget.listingId)
            .get();
    final homeSnap =
        await FirebaseFirestore.instance
            .collection('homes')
            .doc(widget.listingId)
            .get();

    if (listSnap.exists) listing = listSnap.data();
    if (homeSnap.exists) home = homeSnap.data();

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (listing == null) {
      return HostelPgNotFoundPage(
        onRetry: _fetchData, // your retry logic
      );
    }
    // if (listing == null) {
    //   return const Scaffold(body: Center(child: Text("Home not found")));
    // }

    final images = List<String>.from(listing!["images"] ?? []);
    final address = listing!["address"] ?? {};
    final amenities = listing!["amenities"] ?? {};
    final homeSpecs = home ?? {};

    return Scaffold(
      floatingActionButton: _buildFAB(),
      body: CustomScrollView(
        slivers: [
          // 🖼️ Hero Image Carousel
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 280,
                      viewportFraction: 1.0,
                      enableInfiniteScroll: false,
                      onPageChanged:
                          (i, _) => setState(() => _currentImage = i),
                    ),
                    items:
                        images.isEmpty
                            ? [
                              Image.asset(
                                'assets/no_image.png',
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ]
                            : images
                                .map(
                                  (url) => Image.network(
                                    url,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                )
                                .toList(),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        images.length,
                        (i) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: _currentImage == i ? 10 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color:
                                _currentImage == i
                                    ? Colors.white
                                    : Colors.white54,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Rating
                  Text(
                    listing!["title"] ?? "",
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: (listing!["avgRating"] ?? 0).toDouble(),
                        itemBuilder:
                            (_, __) =>
                                const Icon(Icons.star, color: Colors.amber),
                        itemSize: 20,
                      ),
                      const SizedBox(width: 8),
                      Text("(${listing!["reviewCount"] ?? 0} reviews)"),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "₹${listing!["basePrice"] ?? 0}/month",
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Divider(height: 30),

                  _buildLocationSection(address),
                  const Divider(height: 30),

                  _buildHomeSpecs(homeSpecs),
                  const Divider(height: 30),

                  _buildAmenitiesSection(amenities),
                  const Divider(height: 30),

                  _buildRulesAndBilling(),
                  const Divider(height: 30),

                  _buildGallery(images),
                  const Divider(height: 30),

                  _buildReviews(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () {
        // Call / Book action
      },
      icon: const Icon(Icons.phone),
      label: const Text("Contact / Book"),
    );
  }

  Widget _buildLocationSection(Map address) {
    final full = address["fullAddress"] ?? "";
    final lat = listing!["location"]?["lat"];
    final lng = listing!["location"]?["lng"];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Location", style: Theme.of(context).textTheme.headlineLarge!),
        const SizedBox(height: 8),
        Text(full),
        if (lat != null && lng != null) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 180,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(lat, lng),
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('home'),
                  position: LatLng(lat, lng),
                ),
              },
              zoomControlsEnabled: false,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHomeSpecs(Map specs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Property Details",
          style: Theme.of(context).textTheme.headlineLarge!,
        ),
        const SizedBox(height: 8),
        Text("Type: ${specs["propertyType"] ?? "Independent House"}"),
        Text("BHK: ${specs["bhk"] ?? "-"}"),
        Text("Bedrooms: ${specs["bedrooms"] ?? "-"}"),
        Text("Bathrooms: ${specs["bathrooms"] ?? "-"}"),
        Text("Balconies: ${specs["balconies"] ?? "-"}"),
        Text("Built-up Area: ${specs["builtUpArea"] ?? "-"} sq.ft."),
        Text("Carpet Area: ${specs["carpetArea"] ?? "-"} sq.ft."),
        Text("Parking Spaces: ${specs["parking"] ?? "-"}"),
        Text("Furnishing: ${specs["furnishing"] ?? "Unfurnished"}"),
        if (specs["age"] != null) Text("Property Age: ${specs["age"]} years"),
      ],
    );
  }

  Widget _buildAmenitiesSection(Map amenities) {
    final amenityIcons = {
      "wifi": Icons.wifi,
      "waterSupply": Icons.water_drop,
      "powerBackup": Icons.bolt,
      "security": Icons.security,
      "ac": Icons.ac_unit,
      "garden": Icons.park,
      "parking": Icons.local_parking,
      "modularKitchen": Icons.kitchen,
      "lift": Icons.elevator,
    };
    final available =
        amenityIcons.entries.where((e) => amenities[e.key] == true).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Amenities", style: Theme.of(context).textTheme.headlineLarge!),
        const SizedBox(height: 8),
        available.isEmpty
            ? const Text("No amenities specified")
            : Wrap(
              spacing: 10,
              runSpacing: 8,
              children:
                  available
                      .map(
                        (e) => Chip(
                          avatar: Icon(e.value, size: 20),
                          label: Text(
                            e.key.replaceAll(RegExp(r'([A-Z])'), ' \$1'),
                          ),
                        ),
                      )
                      .toList(),
            ),
      ],
    );
  }

  Widget _buildRulesAndBilling() {
    final rules = listing!["extraRules"] ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Rules & Billing",
          style: Theme.of(context).textTheme.headlineLarge!,
        ),
        const SizedBox(height: 8),
        if (rules["depositMonths"] != null)
          Text("Deposit: ${rules["depositMonths"]} months"),
        if (rules["lockInMonths"] != null)
          Text("Lock-in: ${rules["lockInMonths"]} months"),
        Text("Maintenance Fee: ₹${listing!["maintenanceFee"] ?? 0}/month"),
        Text(
          "Electricity Included: ${listing!["electricityBillIncluded"] == true ? "Yes" : "No"}",
        ),
        Text(
          "Water Included: ${listing!["waterBillIncluded"] == true ? "Yes" : "No"}",
        ),
        Text(
          "Internet Included: ${listing!["internetIncluded"] == true ? "Yes" : "No"}",
        ),
      ],
    );
  }

  Widget _buildGallery(List<String> images) {
    if (images.length <= 1) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Gallery", style: Theme.of(context).textTheme.headlineLarge!),
        const SizedBox(height: 8),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 3,
          physics: const NeverScrollableScrollPhysics(),
          children:
              images
                  .map(
                    (url) => Padding(
                      padding: const EdgeInsets.all(2),
                      child: Image.network(url, fit: BoxFit.cover),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }

  Widget _buildReviews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Reviews", style: Theme.of(context).textTheme.headlineLarge!),
        const SizedBox(height: 8),
        const Text("No reviews yet. Be the first to review!"),
      ],
    );
  }
}
