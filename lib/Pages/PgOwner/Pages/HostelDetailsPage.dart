import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:romy/Pages/notFoundPage.dart';

class HostelDetailsPage extends StatefulWidget {
  final String listingId;
  const HostelDetailsPage({Key? key, required this.listingId})
    : super(key: key);

  @override
  State<HostelDetailsPage> createState() => _HostelDetailsPageState();
}

class _HostelDetailsPageState extends State<HostelDetailsPage> {
  Map<String, dynamic>? listing;
  Map<String, dynamic>? hostel;
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
    final hostSnap =
        await FirebaseFirestore.instance
            .collection('hostels')
            .doc(widget.listingId)
            .get();

    if (listSnap.exists) listing = listSnap.data();
    if (hostSnap.exists) hostel = hostSnap.data();

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
    //   return const Scaffold(body: Center(child: Text("Hostel not found")));
    // }

    final images = List<String>.from(listing!["images"] ?? []);
    final address = listing!["address"] ?? {};
    final amenities = listing!["amenities"] ?? {};
    final floors = (hostel?["floors"] ?? {}) as Map<String, dynamic>;

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
                    "From ₹${listing!["basePrice"] ?? 0}/month per cot",
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Divider(height: 30),

                  // Address & Map
                  _buildLocationSection(address),

                  const Divider(height: 30),
                  _buildAmenitiesSection(amenities),

                  const Divider(height: 30),
                  _buildRulesAndBilling(),

                  const Divider(height: 30),
                  _buildFloorsSection(floors),

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
        // booking action
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
                  markerId: const MarkerId('hostel'),
                  position: LatLng(lat, lng),
                ),
              },
              zoomControlsEnabled: false,
              liteModeEnabled: false,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAmenitiesSection(Map amenities) {
    final amenityIcons = {
      "wifi": Icons.wifi,
      "drinkingWater": Icons.water_drop,
      "hotWater": Icons.hot_tub,
      "mess": Icons.restaurant,
      "fan": Icons.toys,
      "ac": Icons.ac_unit,
      "tv": Icons.tv,
      "tableChair": Icons.chair,
      "parking": Icons.local_parking,
    };
    final available =
        amenityIcons.entries.where((e) => amenities[e.key] == true).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Amenities", style: Theme.of(context).textTheme.headlineLarge!),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children:
              available
                  .map(
                    (e) => Chip(
                      avatar: Icon(e.value, size: 20),
                      label: Text(e.key.replaceAll(RegExp(r'([A-Z])'), ' \$1')),
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
        Text("Gender: ${rules["gender"] ?? "Coed"}"),
        if (rules["curfew"] != null) Text("Curfew: ${rules["curfew"]}"),
        Text("Deposit: ${rules["depositMonths"] ?? 0} months"),
        Text("Lock-in: ${rules["lockInMonths"] ?? 0} months"),
        const SizedBox(height: 10),
        Text("Mess Fee: ₹${listing!["messFeeMonthly"] ?? 0}/month"),
        Text("Maintenance Fee: ₹${listing!["maintenanceFee"] ?? 0}/month"),
        Text(
          "Electricity Included: ${listing!["electricityBillIncluded"] ? "Yes" : "No"}",
        ),
        Text("Water Included: ${listing!["waterBillIncluded"] ? "Yes" : "No"}"),
        Text(
          "Internet Included: ${listing!["internetIncluded"] ? "Yes" : "No"}",
        ),
      ],
    );
  }

  Widget _buildFloorsSection(Map<String, dynamic> floors) {
    if (floors.isEmpty) return const Text("No floor/room data");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Floors & Rooms",
          style: Theme.of(context).textTheme.headlineLarge!,
        ),
        const SizedBox(height: 8),
        ...floors.entries.map((floorEntry) {
          final floor = floorEntry.value as Map;
          final rooms = (floor["rooms"] ?? {}) as Map<String, dynamic>;
          return Card(
            child: ExpansionTile(
              title: Text(floor["name"] ?? "Floor"),
              children:
                  rooms.entries.map((roomEntry) {
                    final room = roomEntry.value as Map;
                    final cots = (room["cots"] ?? {}) as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: ExpansionTile(
                        title: Text(
                          "${room["name"]} "
                          "(capacity: ${room["capacity"] ?? '-'})",
                        ),
                        children:
                            cots.entries.map((cotEntry) {
                              final cot = cotEntry.value as Map;
                              return ListTile(
                                title: Text(
                                  "Cot: ₹${cot["pricePerMonth"] ?? 0}/month",
                                ),
                                trailing: Text(
                                  (cot["status"] ?? "available")
                                      .toString()
                                      .toUpperCase(),
                                  style: TextStyle(
                                    color:
                                        (cot["status"] == "available")
                                            ? Colors.green
                                            : Colors.red,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    );
                  }).toList(),
            ),
          );
        }),
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
    // This is a placeholder. Integrate your review system if you have one.
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
