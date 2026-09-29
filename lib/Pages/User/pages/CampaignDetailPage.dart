import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:romy/Pages/User/userdetails_page.dart';
import 'package:romy/provoiders/user_details_provider.dart';

class CampaignDetailPage extends StatefulWidget {
  final QueryDocumentSnapshot campaign;
  const CampaignDetailPage({super.key, required this.campaign});

  @override
  State<CampaignDetailPage> createState() => _CampaignDetailPageState();
}

class _CampaignDetailPageState extends State<CampaignDetailPage> {
  bool _leaving = false;
  bool _loadingMatches = true;
  List<_MatchResult> _matches = [];

  @override
  void initState() {
    super.initState();
    _computeMatches();
  }

  Future<void> _computeMatches() async {
    setState(() {
      _loadingMatches = true;
      _matches = [];
    });

    final currentUser = context.read<UserDetailsProvider>().user!;
    final campaignId = widget.campaign.id;

    // 1) load participants doc for campaign
    final participantsSnap =
        await FirebaseFirestore.instance
            .collection('campaign_participants')
            .doc(campaignId)
            .get();

    if (!participantsSnap.exists) {
      setState(() {
        _loadingMatches = false;
      });
      return;
    }

    final participantsData = participantsSnap.data() as Map<String, dynamic>;
    // participantsData keys are user UIDs or nested maps - we assume values have 'userId'
    final participantUids = <String>[];
    participantsData.forEach((k, v) {
      try {
        if (v is Map && v['userId'] != null) {
          participantUids.add(v['userId'].toString());
        } else if (k is String) {
          // fallback if stored as { uid: {...} } and key is uid
          participantUids.add(k);
        }
      } catch (_) {}
    });

    // remove self from candidates
    final candidateUids =
        participantUids.where((u) => u != currentUser.uid).toList();
    if (candidateUids.isEmpty) {
      setState(() {
        _loadingMatches = false;
      });
      return;
    }

    // 2) fetch current user's roomFinder profile
    final currentRfSnap =
        await FirebaseFirestore.instance
            .collection('roomFinders')
            .where(
              'createdBy',
              isEqualTo: currentUser.uid,
            ) // if you store createdBy
            .limit(1)
            .get();

    // fallback: if doc id is uid, try that too
    DocumentSnapshot? curRfDoc;
    if (currentRfSnap.docs.isNotEmpty) {
      curRfDoc = currentRfSnap.docs.first;
    } else {
      final alt =
          await FirebaseFirestore.instance
              .collection('roomFinders')
              .doc(currentUser.uid)
              .get();
      if (alt.exists) curRfDoc = alt;
    }

    if (curRfDoc == null || !curRfDoc.exists) {
      // no roomFinder profile for current user -> can't compute matches
      setState(() {
        _loadingMatches = false;
      });
      return;
    }

    final currentRf = curRfDoc.data() as Map<String, dynamic>;

    // 3) fetch candidate roomFinder docs in batches (Firestore limit 10 per "in")
    final batches = <List<String>>[];
    const batchSize = 10;
    for (var i = 0; i < candidateUids.length; i += batchSize) {
      batches.add(
        candidateUids.sublist(i, min(i + batchSize, candidateUids.length)),
      );
    }

    final candidateDocs = <DocumentSnapshot>[];
    for (final b in batches) {
      // Try by field 'createdBy' or by doc ID - we'll query both
      final q1 =
          await FirebaseFirestore.instance
              .collection('roomFinderProfiles')
              .where('createdBy', whereIn: b)
              .get();
      candidateDocs.addAll(q1.docs);

      // Also try fetching docs whose id equals uid (fallback)
      for (final uid in b) {
        final doc =
            await FirebaseFirestore.instance
                .collection('roomFinderProfiles')
                .doc(uid)
                .get();
        if (doc.exists) candidateDocs.add(doc);
      }
    }

    // de-duplicate by id
    final unique = <String, DocumentSnapshot>{};
    for (final d in candidateDocs) unique[d.id] = d;
    final finalCandidates = unique.values.toList();

    // 4) compute similarity score for each candidate
    final results = <_MatchResult>[];
    for (final doc in finalCandidates) {
      final cand = doc.data() as Map<String, dynamic>;
      final score = _computeSimilarityScore(currentRf, cand);
      results.add(_MatchResult(uid: doc.id, score: score, doc: doc));
    }

    // sort descending and take top 10
    results.sort((a, b) => b.score.compareTo(a.score));
    final top = results.take(10).toList();

    setState(() {
      _loadingMatches = false;
      _matches = top;
    });
  }

  double _computeSimilarityScore(
    Map<String, dynamic> a,
    Map<String, dynamic> b,
  ) {
    // Weights (tweakable). Sum should be 1.0 for readability (here sum = 1.0)
    const weights = {
      'budget': 0.18,
      'cleanliness': 0.10,
      'smoking': 0.10,
      'sleepWake': 0.08,
      'languages': 0.10,
      'hobbies': 0.06,
      'foodType': 0.06,
      'pets': 0.05,
      'shareBathroom': 0.05,
      'socialLevel': 0.06,
      'pgDuration': 0.06,
      'occupation': 0.04,
      'misc': 0.06, // fallback for other small matches
    };

    double total = 0.0;

    // Helper functions
    double clamp01(double v) => v.isNaN ? 0.0 : (v < 0 ? 0 : (v > 1 ? 1 : v));

    // if gender mismatch => no match
    final aGender = (a['gender'] ?? '').toString().toLowerCase();
    final bGender = (b['gender'] ?? '').toString().toLowerCase();
    if (aGender.isNotEmpty && bGender.isNotEmpty && aGender != bGender) {
      return 0.0;
    }

    // New weights
    const extraWeights = {
      'acPreference': 0.04,
      'fanPreference': 0.04,
      'behavior': 0.04,
      'slangUsage': 0.02,
    };

    /// AC preference
    double acScore = 0.5;
    try {
      final aAC = (a['acPreference'] ?? '').toString().toLowerCase();
      final bAC = (b['acPreference'] ?? '').toString().toLowerCase();
      acScore = (aAC == bAC) ? 1.0 : 0.0;
    } catch (_) {}
    total += acScore * extraWeights['acPreference']!;

    /// Fan preference
    double fanScore = 0.5;
    try {
      final aF = (a['fanPreference'] ?? '').toString().toLowerCase();
      final bF = (b['fanPreference'] ?? '').toString().toLowerCase();
      fanScore = (aF == bF) ? 1.0 : 0.0;
    } catch (_) {}
    total += fanScore * extraWeights['fanPreference']!;

    /// Behavior overlap
    double behaviorScore = 0.0;
    try {
      final aBeh = _toLowerStringList(a['behavior']);
      final bBeh = _toLowerStringList(b['behavior']);
      behaviorScore = _jaccard(aBeh, bBeh);
    } catch (_) {}
    total += behaviorScore * extraWeights['behavior']!;

    /// Slang usage
    double slangScore = 0.5;
    try {
      final aSl = (a['slangUsage'] ?? '').toString().toLowerCase();
      final bSl = (b['slangUsage'] ?? '').toString().toLowerCase();
      slangScore = (aSl == bSl) ? 1.0 : 0.0;
    } catch (_) {}
    total += slangScore * extraWeights['slangUsage']!;

    // 1) Budget proximity: compute overlap + closeness
    double budgetScore = 0.0;
    try {
      final aMin = (a['budgetMin'] ?? a['budgetmin'] ?? 0).toDouble();
      final aMax = (a['budgetMax'] ?? a['budgetmax'] ?? aMin).toDouble();
      final bMin = (b['budgetMin'] ?? b['budgetmin'] ?? 0).toDouble();
      final bMax = (b['budgetMax'] ?? b['budgetmax'] ?? bMin).toDouble();

      final overlapMin = max(aMin, bMin);
      final overlapMax = min(aMax, bMax);
      if (overlapMax >= overlapMin) {
        // overlapping ranges => good match
        final overlapSize = overlapMax - overlapMin;
        final rangeSize = max(aMax - aMin, 1);
        budgetScore = 0.6 * (overlapSize / rangeSize) + 0.4; // prefer overlap
      } else {
        // no overlap: score decreases with distance
        final dist = ((aMin + aMax) / 2 - (bMin + bMax) / 2).abs();
        final avgRange = max((aMax - aMin + bMax - bMin) / 2, 1);
        budgetScore = clamp01(
          1 - (dist / (avgRange * 5)) as double,
        ); // larger tolerance
      }
      budgetScore = clamp01(budgetScore);
    } catch (_) {
      budgetScore = 0.5;
    }
    total += budgetScore * weights['budget']!;

    // 2) Cleanliness (numeric, 1-5)
    double cleanlinessScore = 0.5;
    try {
      final aC = (a['cleanliness'] ?? 3).toDouble();
      final bC = (b['cleanliness'] ?? 3).toDouble();
      final diff = (aC - bC).abs();
      cleanlinessScore = clamp01(
        1 - (diff / 4) as double,
      ); // diff 0 ->1, diff4->0
    } catch (_) {}
    total += cleanlinessScore * weights['cleanliness']!;

    // 3) Smoking preference (Yes/No/Occasionally)
    double smokingScore = 0.5;
    try {
      final aS = (a['smoking'] ?? '').toString().toLowerCase();
      final bS = (b['smoking'] ?? '').toString().toLowerCase();
      smokingScore = (aS == bS) ? 1.0 : 0.0;
      // Allow "no" vs "occasionally" slight partial
      if ((aS == 'no' && bS == 'occasionally') ||
          (bS == 'no' && aS == 'occasionally'))
        smokingScore = 0.5;
    } catch (_) {}
    total += smokingScore * weights['smoking']!;

    // 4) Sleep/wake time closeness (compare minutes)
    double sleepWakeScore = 0.5;
    try {
      final aSleep = _parseTimeToMinutes(a['sleepTime']);
      final aWake = _parseTimeToMinutes(a['wakeTime']);
      final bSleep = _parseTimeToMinutes(b['sleepTime']);
      final bWake = _parseTimeToMinutes(b['wakeTime']);
      final sleepDiff = (aSleep - bSleep).abs();
      final wakeDiff = (aWake - bWake).abs();
      final avgDiff = (sleepDiff + wakeDiff) / 2.0;
      sleepWakeScore = clamp01(1 - (avgDiff / (24 * 60 / 2))); // normalize
    } catch (_) {}
    total += sleepWakeScore * weights['sleepWake']!;

    // 5) Languages overlap (set Jaccard)
    double languageScore = 0.0;
    try {
      final aLang = _toLowerStringList(a['languages']);
      final bLang = _toLowerStringList(b['languages']);
      languageScore = _jaccard(aLang, bLang);
    } catch (_) {}
    total += languageScore * weights['languages']!;

    // 6) Hobbies/interests overlap (union)
    double hobbiesScore = 0.0;
    try {
      final aH =
          _toLowerStringList(a['hobbies']) + _toLowerStringList(a['interests']);
      final bH =
          _toLowerStringList(b['hobbies']) + _toLowerStringList(b['interests']);
      hobbiesScore = _jaccard(aH, bH);
    } catch (_) {}
    total += hobbiesScore * weights['hobbies']!;

    // 7) Food type match (vegetarian/non/adjustable)
    double foodScore = 0.5;
    try {
      final aF = (a['foodType'] ?? '').toString().toLowerCase();
      final bF = (b['foodType'] ?? '').toString().toLowerCase();
      foodScore = (aF == bF) ? 1.0 : 0.0;
      if (aF.contains('adjust') || bF.contains('adjust')) foodScore = 0.7;
    } catch (_) {}
    total += foodScore * weights['foodType']!;

    // 8) Pets preference
    double petScore = 0.5;
    try {
      final aP = (a['pets'] ?? '').toString().toLowerCase();
      final bP = (b['pets'] ?? '').toString().toLowerCase();
      petScore = (aP == bP) ? 1.0 : 0.0;
      if (aP.contains('no') && bP.contains('no')) petScore = 1.0;
    } catch (_) {}
    total += petScore * weights['pets']!;

    // 9) Share bathroom
    double shareBathScore = 0.5;
    try {
      final aSB = (a['shareBathroom'] ?? false) == true;
      final bSB = (b['shareBathroom'] ?? false) == true;
      shareBathScore = (aSB == bSB) ? 1.0 : 0.0;
    } catch (_) {}
    total += shareBathScore * weights['shareBathroom']!;

    // 10) Social level closeness (1-5)
    double socialScore = 0.5;
    try {
      final aS = (a['socialLevel'] ?? 3).toDouble();
      final bS = (b['socialLevel'] ?? 3).toDouble();
      final diff = (aS - bS).abs();
      socialScore = clamp01(1 - (diff / 4) as double);
    } catch (_) {}
    total += socialScore * weights['socialLevel']!;

    // 11) PG duration preference closeness (in months)
    double pgScore = 0.5;
    try {
      final aDur = (a['pgDuration'] ?? 0).toDouble();
      final bDur = (b['pgDuration'] ?? 0).toDouble();
      final diff = (aDur - bDur).abs();
      pgScore = clamp01(1 - (diff / max(1.0, max(aDur, bDur) / 2)) as double);
    } catch (_) {}
    total += pgScore * weights['pgDuration']!;

    // 12) Occupation category (student/working/etc.)
    double occScore = 0.5;
    try {
      final aO = (a['occupationCategory'] ?? '').toString().toLowerCase();
      final bO = (b['occupationCategory'] ?? '').toString().toLowerCase();
      occScore = (aO == bO) ? 1.0 : 0.0;
    } catch (_) {}
    total += occScore * weights['occupation']!;

    // 13) misc small checks: allergies, drinking preference, slangUsage
    double miscScore = 0.0;
    try {
      final aDr = (a['drinking'] ?? '').toString().toLowerCase();
      final bDr = (b['drinking'] ?? '').toString().toLowerCase();
      final drinkingMatch = (aDr == bDr) ? 1.0 : 0.0;

      final aAll = _toLowerStringList(a['allergies']);
      final bAll = _toLowerStringList(b['allergies']);
      final allergyConflict = _jaccard(
        aAll,
        bAll,
      ); // higher means same allergies -> ok

      miscScore = (drinkingMatch * 0.6) + (allergyConflict * 0.4);
    } catch (_) {}
    total += miscScore * weights['misc']!;

    // final score normalized 0..1
    final finalScore = double.parse(total.toStringAsFixed(4));
    return finalScore;
  }

  int _parseTimeToMinutes(dynamic val) {
    if (val == null) return 0;
    final s = val.toString().trim();
    if (s.isEmpty) return 0;
    // Accept formats: "1:30", "01:30", "13:30", "1:30 AM", "1:30PM"
    final lower = s.toLowerCase();
    final ampm = lower.contains('am') || lower.contains('pm');
    try {
      final clean = lower.replaceAll(RegExp(r'[^0-9:]'), '');
      final parts = clean.split(':');
      int h = int.parse(parts[0]);
      int m = parts.length > 1 ? int.parse(parts[1]) : 0;
      if (ampm) {
        if (lower.contains('pm') && h < 12) h += 12;
        if (lower.contains('am') && h == 12) h = 0;
      }
      return (h * 60) + m;
    } catch (_) {
      return 0;
    }
  }

  List<String> _toLowerStringList(dynamic v) {
    if (v == null) return [];
    if (v is Iterable) {
      return v.map((e) => e.toString().toLowerCase()).toSet().toList();
    }
    return v
        .toString()
        .split(',')
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  double _jaccard(List<String> a, List<String> b) {
    final A = a.toSet();
    final B = b.toSet();
    if (A.isEmpty && B.isEmpty) return 1.0;
    if (A.isEmpty || B.isEmpty) return 0.0;
    final inter = A.intersection(B).length.toDouble();
    final uni = A.union(B).length.toDouble();
    return uni == 0 ? 0.0 : inter / uni;
  }

  Future<void> _leaveCampaign() async {
    setState(() => _leaving = true);
    final user = context.read<UserDetailsProvider>().user!;
    final campaignId = widget.campaign.id;
    try {
      await FirebaseFirestore.instance
          .collection('campaign_participants')
          .doc(campaignId)
          .update({user.uid: FieldValue.delete()});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Left campaign')));
      // Recompute matches as participant removed
      await _computeMatches();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to leave: $e')));
    } finally {
      if (mounted) setState(() => _leaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final camp = widget.campaign.data() as Map<String, dynamic>;
    final lat = (camp['lat'] is num) ? (camp['lat'] as num).toDouble() : null;
    final lng = (camp['lng'] is num) ? (camp['lng'] as num).toDouble() : null;
    final image = (camp['imageUrl'] ?? '').toString();

    final currentUser = context.watch<UserDetailsProvider>().user;

    return Scaffold(
      appBar: AppBar(title: Text(camp['title'] ?? 'Campaign')),
      body: RefreshIndicator(
        onRefresh: () async {
          await _computeMatches();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (image.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    image,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 12),
              Text(
                camp['description'] ?? '',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),
              Text('Location', style: Theme.of(context).textTheme.titleMedium),
              Text(camp['location'] ?? ''),
              const SizedBox(height: 8),
              if (lat != null && lng != null)
                SizedBox(
                  height: 200,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(lat, lng),
                      zoom: 14,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('loc'),
                        position: LatLng(lat, lng),
                      ),
                    },
                    zoomControlsEnabled: false,
                    liteModeEnabled: true,
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh matches'),
                    onPressed: () => _computeMatches(),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    icon: Icon(Icons.exit_to_app),
                    label:
                        _leaving
                            ? const Text('Leaving...')
                            : const Text('Leave Campaign'),
                    onPressed:
                        currentUser == null || _leaving ? null : _leaveCampaign,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Top Matches',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              if (_loadingMatches)
                const Center(child: CircularProgressIndicator())
              else if (_matches.isEmpty)
                const Text('No matches available or not enough participants.')
              else
                Column(
                  children:
                      _matches.map((m) {
                        final candData = m.doc.data() as Map<String, dynamic>;
                        final name =
                            (candData['displayName'] ??
                                    candData['userName'] ??
                                    m.doc.id)
                                .toString();
                        final avatar =
                            (candData['profileUrl'] ??
                                    candData['profileurl'] ??
                                    '')
                                as String?;
                        return FutureBuilder<
                          DocumentSnapshot<Map<String, dynamic>>
                        >(
                          future:
                              FirebaseFirestore.instance
                                  .collection('roomFinderProfiles')
                                  .doc(m.uid)
                                  .get(),
                          builder: (context, userSnap) {
                            if (userSnap.connectionState ==
                                ConnectionState.waiting) {
                              return const ListTile(title: Text('Loading...'));
                            }
                            if (!userSnap.hasData || !userSnap.data!.exists) {
                              return ListTile(title: Text('User not found'));
                            }

                            final userData = userSnap.data!.data()!;
                            final name =
                                userData['displayName'] ??
                                userData['userName'] ??
                                m.uid;
                            final avatar = userData['profileUrl'] ?? '';

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ExpansionTile(
                                leading: CircleAvatar(
                                  radius: 24,
                                  backgroundImage:
                                      avatar.isNotEmpty
                                          ? NetworkImage(avatar)
                                          : null,
                                  child:
                                      avatar.isEmpty
                                          ? const Icon(Icons.person)
                                          : null,
                                ),
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: Text(name)),
                                    Text(
                                      '${(m.score * 100).toStringAsFixed(1)}%',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) =>
                                                UserDetailsPage(userId: m.uid),
                                      ),
                                    );
                                  },
                                  child: const Text('View'),
                                ),
                                childrenPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                children: [
                                  LinearProgressIndicator(
                                    value: m.score.clamp(0.0, 1.0),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildMatchHints(
                                    candidate: candData,
                                    currentRf: null,
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchHints({
    Map<String, dynamic>? currentRf,
    required Map<String, dynamic> candidate,
  }) {
    // Provide a small set of short hints (best-effort)
    final hints = <String>[];
    try {
      if ((candidate['smoking'] ?? '').toString().toLowerCase() == 'no')
        hints.add('Non-smoker');
      if ((candidate['foodType'] ?? '').toString().toLowerCase().contains(
        'veg',
      ))
        hints.add('Prefers veg');
      if ((candidate['pets'] ?? '').toString().toLowerCase().contains('no'))
        hints.add('No pets');
      if ((candidate['shareBathroom'] ?? false) == true)
        hints.add('Shares bathroom');
      if ((candidate['occupationCategory'] ?? '').toString().isNotEmpty)
        hints.add(candidate['occupationCategory']);
      final langs = _toLowerStringList(candidate['languages']);
      if (langs.isNotEmpty)
        hints.add(langs.take(2).map((s) => s.capitalize()).join(', '));
      if ((candidate['acPreference'] ?? '').toString().isNotEmpty)
        hints.add("AC: ${candidate['acPreference']}");
      if ((candidate['fanPreference'] ?? '').toString().isNotEmpty)
        hints.add("Fan: ${candidate['fanPreference']}");
      if ((candidate['slangUsage'] ?? '').toString().toLowerCase() ==
          'no slang')
        hints.add("Polite");
      if ((candidate['behavior'] ?? []) is List) {
        final beh = (candidate['behavior'] as List).take(2).join(", ");
        if (beh.isNotEmpty) hints.add(beh);
      }
    } catch (_) {}
    return Wrap(
      spacing: 6,
      children: hints.map((h) => Chip(label: Text(h))).toList(),
    );
  }
}

class _MatchResult {
  final String uid;
  final double score; // 0.0 .. 1.0
  final DocumentSnapshot doc;
  _MatchResult({required this.uid, required this.score, required this.doc});
}

/// small String extension for capitalization used in hints
extension _Cap on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}


/*
                        return Card(
                          child: ListTile(
                            title: Text(name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LinearProgressIndicator(
                                  value: m.score.clamp(0.0, 1.0),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${(m.score * 100).toStringAsFixed(1)}% match',
                                ),
                                // quick match hints:
                                _buildMatchHints(
                                  currentRf: null,
                                  candidate: candData,
                                ),
                              ],
                            ),
                            trailing: Column(
                              children: [
                                if (avatar != null && avatar.isNotEmpty)
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(avatar),
                                    radius: 20,
                                  )
                                else
                                  const CircleAvatar(child: Icon(Icons.person)),
                                const SizedBox(height: 6),

                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => UserDetailsPage(
                                              userId: m.uid,
                                            ), // 👈 pass uid
                                      ),
                                    );
                                  },
                                  child: const Text('View'),
                                ),
                              ],
                            ),
                          ),
                        );
                        */