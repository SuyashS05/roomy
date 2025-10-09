import 'package:flutter/material.dart';

class FloorCard extends StatelessWidget {
  final String floorKey;
  final Map<String, dynamic> floor;
  final bool isOwner;
  final Function(String, Map<String, dynamic>) onEditFloor;
  final Function(String, String, Map<String, dynamic>) onEditRoom;
  final Function(String, String, String, Map<String, dynamic>) onEditCot;
  final Function(String, String, String) onBookCot;

  const FloorCard({
    super.key,
    required this.floorKey,
    required this.floor,
    required this.isOwner,
    required this.onEditFloor,
    required this.onEditRoom,
    required this.onEditCot,
    required this.onBookCot,
  });

  @override
  Widget build(BuildContext context) {
    final rooms = (floor["rooms"] ?? {}) as Map<String, dynamic>;

    return Container(
      width: 340,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.blueGrey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 6,
            color: Colors.black12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Floor Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                floor["name"] ?? "Floor",
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontWeight: FontWeight.bold, color: Colors.blueGrey[800]),
              ),
              if (isOwner)
                IconButton(
                  icon: const Icon(Icons.edit, size: 20, color: Colors.blueGrey),
                  onPressed: () => onEditFloor(floorKey, floor),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Rooms
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemCount: rooms.length,
              itemBuilder: (context, roomIndex) {
                final roomKey = rooms.keys.elementAt(roomIndex);
                final room = rooms[roomKey] as Map<String, dynamic>;
                return RoomCard(
                  floorKey: floorKey,
                  roomKey: roomKey,
                  room: room,
                  isOwner: isOwner,
                  onEditRoom: onEditRoom,
                  onEditCot: onEditCot,
                  onBookCot: onBookCot,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class RoomCard extends StatelessWidget {
  final String floorKey;
  final String roomKey;
  final Map<String, dynamic> room;
  final bool isOwner;
  final Function(String, String, Map<String, dynamic>) onEditRoom;
  final Function(String, String, String, Map<String, dynamic>) onEditCot;
  final Function(String, String, String) onBookCot;

  const RoomCard({
    super.key,
    required this.floorKey,
    required this.roomKey,
    required this.room,
    required this.isOwner,
    required this.onEditRoom,
    required this.onEditCot,
    required this.onBookCot,
  });

  @override
  Widget build(BuildContext context) {
    final cots = (room["cots"] ?? {}) as Map<String, dynamic>;

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: const [
          BoxShadow(blurRadius: 4, color: Colors.black12, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(room["name"] ?? "Room", style: const TextStyle(fontWeight: FontWeight.w600)),
              if (isOwner)
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  onPressed: () => onEditRoom(floorKey, roomKey, room),
                ),
            ],
          ),
          Text("Capacity: ${room["capacity"] ?? cots.length}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 6),
          Flexible(
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.4),
              itemCount: cots.length,
              itemBuilder: (context, cotIndex) {
                final cotKey = cots.keys.elementAt(cotIndex);
                final cot = cots[cotKey] as Map<String, dynamic>;
                final isAvailable = cot["status"] == "available";

                return InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => isOwner
                      ? onEditCot(floorKey, roomKey, cotKey, cot)
                      : onBookCot(floorKey, roomKey, cotKey),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      color: isAvailable ? Colors.green[50] : Colors.red[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isAvailable ? Colors.green : Colors.red, width: 1.4),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "₹${cot["pricePerMonth"] ?? 0}",
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isAvailable ? Colors.green[800] : Colors.red[800]),
                        ),
                        Text(
                          cot["status"]?.toString().toUpperCase() ?? "",
                          style: TextStyle(
                              fontSize: 10,
                              color: isAvailable ? Colors.green[800] : Colors.red[800]),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
