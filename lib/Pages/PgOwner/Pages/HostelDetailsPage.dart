import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:romy/Models/Users.dart';
import 'package:romy/Pages/PgOwner/Pages/BookingRequests.dart';
import 'package:romy/Pages/PgOwner/Pages/FlooreCard.dart';
import 'package:romy/Pages/PgOwner/Pages/hostel_add_page.dart';
import 'package:romy/Pages/notFoundPage.dart';
import 'package:romy/provoiders/user_details_provider.dart';

final _firestore = FirebaseFirestore.instance;

class HostelDetailsPage extends StatefulWidget {
  final String listingId;
  final bool isOwnerAccess; // 👈 new
  final String? ownerUid; // 👈 new

  const HostelDetailsPage({
    Key? key,
    required this.listingId,
    this.isOwnerAccess = false, // default false for normal users
    this.ownerUid,
  }) : super(key: key);

  @override
  State<HostelDetailsPage> createState() => _HostelDetailsPageState();
}

class _HostelDetailsPageState extends State<HostelDetailsPage> {
  Map<String, dynamic>? listing;
  Map<String, dynamic>? hostel;
  bool loading = true;
  int _currentImage = 0;
  bool get isOwner => widget.isOwnerAccess;
  late String hostelId; // ensure you set this when opening page

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _showEditFloorDialog(
    String floorKey,
    Map<String, dynamic> floorData,
  ) async {
    final nameController = TextEditingController(text: floorData['name']);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Floor"),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: "Floor Name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await _firestore.collection('hostels').doc(hostelId).update({
                  "floors.$floorKey.name": nameController.text,
                });
                Navigator.pop(context);
                await _fetchData();
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditRoomDialog(
    String floorKey,
    String roomKey,
    Map<String, dynamic> roomData,
  ) async {
    final nameController = TextEditingController(text: roomData['name']);
    final capacityController = TextEditingController(
      text: roomData['capacity']?.toString() ?? '',
    );
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Room"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Room Name"),
              ),
              TextField(
                controller: capacityController,
                decoration: const InputDecoration(labelText: "Capacity"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await _firestore.collection('hostels').doc(hostelId).update({
                  "floors.$floorKey.rooms.$roomKey.name": nameController.text,
                  "floors.$floorKey.rooms.$roomKey.capacity":
                      int.tryParse(capacityController.text) ?? 0,
                });
                Navigator.pop(context);
                await _fetchData();
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditCotDialog(
    String floorKey,
    String roomKey,
    String cotKey,
    Map<String, dynamic> cotData,
  ) async {
    final priceController = TextEditingController(
      text: cotData['pricePerMonth']?.toString() ?? '',
    );
    String selectedStatus = cotData['status'] ?? 'available';

    await showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder:
                (context, setStateDialog) => AlertDialog(
                  title: const Text("Edit Cot"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Price per month",
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        decoration: const InputDecoration(labelText: "Status"),
                        items: const [
                          DropdownMenuItem(
                            value: 'available',
                            child: Text('Available'),
                          ),
                          DropdownMenuItem(
                            value: 'occupied',
                            child: Text('Occupied'),
                          ),
                          DropdownMenuItem(
                            value: 'maintenance',
                            child: Text('Maintenance'),
                          ),
                        ],
                        onChanged:
                            (val) =>
                                setStateDialog(() => selectedStatus = val!),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await _firestore.collection('hostels').doc(hostelId).update({
                          "floors.$floorKey.rooms.$roomKey.cots.$cotKey.pricePerMonth":
                              int.tryParse(priceController.text) ?? 0,
                          "floors.$floorKey.rooms.$roomKey.cots.$cotKey.status":
                              selectedStatus,
                        });
                        Navigator.pop(context);
                        await _fetchData(); // refresh page
                      },
                      child: const Text("Save"),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> _handleBookingRequest(
    String floorKey,
    String roomKey,
    String cotKey,
  ) async {
    if (isOwner) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Confirm Booking"),
            content: const Text(
              "Do you want to send a booking request for this cot?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Confirm"),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    try {
      final user =
          Provider.of<UserDetailsProvider>(context, listen: false).user;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You must be logged in to book.")),
        );
        return;
      }

      await _firestore.collection("bookingRequests").add({
        "listingId": listing!["listingId"],
        "hostelId": hostelId,
        "floorId": floorKey,
        "roomId": roomKey,
        "cotId": cotKey,
        "userUid": user.uid,
        "userName": user.displayName ?? "",
        "contactNumber": user.phone ?? "",
        "ownerUid": listing!["ownerUid"],
        "status": "pending",
        "createdAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Booking request sent!")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to send request: $e")));
    }
  }

  Future<void> _fetchData() async {
    setState(() => loading = true);

    final listSnap =
        await _firestore.collection('listings').doc(widget.listingId).get();
    final hostSnap =
        await _firestore.collection('hostels').doc(widget.listingId).get();

    if (listSnap.exists) listing = listSnap.data();
    if (hostSnap.exists) hostel = hostSnap.data();

    // Assign hostelId so edit dialogs work
    hostelId = widget.listingId;

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
      floatingActionButton: BuildFAB(
        isOwner: isOwner,
        context: context,
        widget: widget,
      ),
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
                  BuildLocationSection(
                    listing: listing,
                    context: context,
                    address: address,
                  ),

                  const Divider(height: 30),
                  buildAmenitiesSection(context: context, amenities: amenities),

                  const Divider(height: 30),
                  BuildRulesAndBIlling(listing: listing, context: context),

                  const Divider(height: 30),
                  BookingRequestsSection(
                    hostelId: hostelId,
                    ownerUid: listing!["ownerUid"],
                    isOwner: isOwner,
                    onAction:
                        (requestId, req) =>
                            showBookingRequestActions(context, requestId, req),
                  ),

                  const Divider(height: 30),
                  _buildFloorsSection(floors),

                  const Divider(height: 30),
                  BuildGallery(context: context, images: images),

                  const Divider(height: 30),
                  BuildReviews(context: context),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloorsSection(Map<String, dynamic> floors) {
    if (floors.isEmpty) return const Text("No floor or room data available");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Floors & Rooms",
          style: Theme.of(context).textTheme.headlineLarge!,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 400,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: floors.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final floorKey = floors.keys.elementAt(index);
              final floor = floors[floorKey] as Map<String, dynamic>;

              return FloorCard(
                floorKey: floorKey,
                floor: floor,
                isOwner: isOwner,
                onEditFloor: _showEditFloorDialog,
                onEditRoom: _showEditRoomDialog,
                onEditCot: _showEditCotDialog,
                onBookCot: _handleBookingRequest,
              );
            },
          ),
        ),
      ],
    );
  }
}

class BuildFAB extends StatelessWidget {
  const BuildFAB({
    super.key,
    required this.isOwner,
    required this.context,
    required this.widget,
  });

  final bool isOwner;
  final BuildContext context;
  final HostelDetailsPage widget;

  @override
  Widget build(BuildContext context) {
    if (isOwner) {
      // 👇 Owner can see edit / delete controls
      return FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => HostelAddPage(
                    owner: UserModel(
                      uid: widget.ownerUid ?? "",
                      email: '',
                      role: '',
                    ), // pass real user model if available
                    editListingId: widget.listingId,
                  ),
            ),
          );
        },
        icon: const Icon(Icons.edit),
        label: const Text("Edit Listing"),
      );
    } else {
      // 👇 Normal user sees booking/contact
      return FloatingActionButton.extended(
        onPressed: () {
          // Booking logic
        },
        icon: const Icon(Icons.phone),
        label: const Text("Contact / Book"),
      );
    }
  }
}

class BuildLocationSection extends StatelessWidget {
  const BuildLocationSection({
    super.key,
    required this.listing,
    required this.context,
    required this.address,
  });

  final Map<String, dynamic>? listing;
  final BuildContext context;
  final Map address;

  @override
  Widget build(BuildContext context) {
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
}

class BuildRulesAndBIlling extends StatelessWidget {
  const BuildRulesAndBIlling({
    super.key,
    required this.listing,
    required this.context,
  });

  final Map<String, dynamic>? listing;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
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
}

class BuildGallery extends StatelessWidget {
  const BuildGallery({super.key, required this.context, required this.images});

  final BuildContext context;
  final List<String> images;

  @override
  Widget build(BuildContext context) {
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
}

class BuildReviews extends StatelessWidget {
  const BuildReviews({super.key, required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
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

class buildAmenitiesSection extends StatelessWidget {
  const buildAmenitiesSection({
    super.key,
    required this.context,
    required this.amenities,
  });

  final BuildContext context;
  final Map amenities;

  @override
  Widget build(BuildContext context) {
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
}
