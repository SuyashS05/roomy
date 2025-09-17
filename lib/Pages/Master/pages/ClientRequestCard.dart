import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget buildRoomOwnerCard(
  BuildContext context,
  Map<String, dynamic> owner,
  String uid,
  String status,
  String name,
  Timestamp? submittedAt,
  void Function(String url, String title) showDocument,
  void Function(String uid, bool approve, {String reason}) updateVerification,
  void Function(String whatsapp) launchWhatsApp,
  void Function(String whatsapp) launchCall, {
  Map<String, dynamic>? user,
}) {
  final whatsapp = owner["whatsapp"] ?? user?["phone"] ?? "";
  final email = user?["email"] ?? "";
  final profileUrl = user?["profileUrl"] ?? "";
  final displayName = user?["displayName"] ?? name;

  return Card(
    elevation: 5,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== HEADER =====
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              radius: 26,
              backgroundImage:
                  profileUrl.isNotEmpty ? NetworkImage(profileUrl) : null,
              backgroundColor: Colors.blueGrey.shade100,
              child:
                  profileUrl.isEmpty
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
            ),
            title: Text(
              displayName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(email.isNotEmpty ? email : "No email provided"),
            trailing: Chip(
              label: Text(
                status.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              backgroundColor:
                  status == "approved"
                      ? Colors.green[100]
                      : status == "rejected"
                      ? Colors.red[100]
                      : Colors.orange[100],
            ),
          ),

          // ===== META INFO =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "Submitted: ${submittedAt != null ? DateFormat.yMMMd().add_jm().format(submittedAt.toDate()) : 'N/A'}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 10),

          // ===== DOCUMENTS =====
          if ((owner["aadhaarNumber"] ?? "").isNotEmpty ||
              (owner["addressProofUrl"] ?? "").isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if ((owner["aadhaarNumber"] ?? "").isNotEmpty)
                    Text(
                      "Aadhaar: ${owner["aadhaarNumber"]}",
                      style: const TextStyle(fontSize: 13),
                    ),
                  const SizedBox(height: 6),
                  if ((owner["addressProofUrl"] ?? "").isNotEmpty)
                    OutlinedButton.icon(
                      icon: const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.blueAccent,
                      ),
                      label: const Text("View Address Proof"),
                      onPressed:
                          () => showDocument(
                            owner["addressProofUrl"],
                            "Address Proof",
                          ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 12),

          // ===== ACTION BUTTONS =====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Contact options
              Row(
                children: [
                  Tooltip(
                    message: "WhatsApp",
                    child: IconButton(
                      icon: const Icon(
                        Icons.message,
                        color: Colors.green,
                        size: 28,
                      ),
                      onPressed:
                          whatsapp.isNotEmpty
                              ? () => launchWhatsApp(whatsapp)
                              : null,
                    ),
                  ),
                  Tooltip(
                    message: "Call",
                    child: IconButton(
                      icon: const Icon(
                        Icons.phone,
                        color: Colors.blueAccent,
                        size: 28,
                      ),
                      onPressed:
                          whatsapp.isNotEmpty
                              ? () => launchCall(whatsapp)
                              : null,
                    ),
                  ),
                ],
              ),

              // Approve / Reject
              Row(
                children: [
                  Tooltip(
                    message: "Approve",
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 30,
                          ),
                          onPressed:
                              status != "approved"
                                  ? () => updateVerification(uid, true)
                                  : null,
                        ),
                        const Text(
                          "Approve",
                          style: TextStyle(fontSize: 12, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                  Tooltip(
                    message: "Reject",
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.cancel,
                            color: Colors.red,
                            size: 30,
                          ),
                          onPressed:
                              status != "rejected"
                                  ? () {
                                    final reasonCtrl = TextEditingController();
                                    showDialog(
                                      context: context,
                                      builder:
                                          (ctx) => AlertDialog(
                                            title: const Text("Reject Request"),
                                            content: TextField(
                                              controller: reasonCtrl,
                                              decoration: const InputDecoration(
                                                hintText:
                                                    "Enter rejection reason",
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.pop(ctx),
                                                child: const Text("Cancel"),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  updateVerification(
                                                    uid,
                                                    false,
                                                    reason:
                                                        reasonCtrl.text.trim(),
                                                  );
                                                  Navigator.pop(ctx);
                                                },
                                                child: const Text("Reject"),
                                              ),
                                            ],
                                          ),
                                    );
                                  }
                                  : null,
                        ),
                        const Text(
                          "Reject",
                          style: TextStyle(fontSize: 12, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
