import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:romy/Pages/User/pages/OptionsList.dart';

class PreferencesPage extends StatefulWidget {
  final String uid;
  const PreferencesPage({super.key, required this.uid});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  bool _loading = false;
  // Text controllers
  final _emergencyContactController = TextEditingController();
  final _tenthController = TextEditingController();
  final _twelfthController = TextEditingController();
  final _pgDurationController = TextEditingController();
  final Set<String> _selectedHobbies = {};
  final Set<String> _selectedLanguages = {};
  final Set<String> _selectedBehaviors = {};
  final Set<String> _selectedSocial = {};
  final Set<String> _selectedInterests = {};
  final Set<String> _selectedAllergies = {};
  final Set<String> _selectedDiseases = {};

  String? _slangUsage;
  String? _foodType;
  String? _studyTime;
  String? _fanPreference;
  String? _acPreference;
  String? _floorPreference;
  int? _pgDuration;
  String? _pgDurationUnit;
  String? _occupationCategory;
  String? _occupationDetail;
  String? _physicalCondition;
  String? _smoking; // 'Yes','No','Sometimes','Prefer not'
  String? _drinking;
  String? _pets;
  String? _workShift; // 'WFH','Office','Hybrid','Night','Rotational'
  bool _shareBathroom = true;

  // numeric / scales
  int _cleanliness = 3; // 1..5
  int _socialLevel = 3; // 1..5
  RangeValues _budgetRange = const RangeValues(3000, 15000);

  // schedule
  TimeOfDay? _sleepTime;
  TimeOfDay? _wakeTime;
  bool _initialLoading = true;
  double _completeness = 0.0;

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('roomFinders')
              .doc(widget.uid)
              .get();

      if (doc.exists) {
        final data = doc.data()!;
        _emergencyContactController.text = data['emergencyContact'] ?? '';
        _tenthController.text = (data['tenthPercentage']?.toString() ?? '');
        _twelfthController.text = (data['twelfthPercentage']?.toString() ?? '');
        _selectedBehaviors.clear();
        if (data['behavior'] is List) {
          for (var b in data['behavior']) {
            _selectedBehaviors.add(b.toString());
          }
        }

        _selectedSocial.clear();
        if (data['socialBehavior'] is List) {
          for (var s in data['socialBehavior']) {
            _selectedSocial.add(s.toString());
          }
        }

        _selectedInterests.clear();
        if (data['interests'] is List) {
          for (var i in data['interests']) {
            _selectedInterests.add(i.toString());
          }
        }
        _selectedHobbies.clear();
        if (data['hobbies'] is List) {
          for (var h in (data['hobbies'] as List)) {
            _selectedHobbies.add(h.toString());
          }
        }

        _selectedLanguages.clear();
        if (data['languages'] is List) {
          for (var l in (data['languages'] as List)) {
            _selectedLanguages.add(l.toString());
          }
        }

        _selectedAllergies.clear();
        if (data['allergies'] is List) {
          for (var a in (data['allergies'] as List)) {
            _selectedAllergies.add(a.toString());
          }
        }
        _selectedDiseases.clear();
        if (data['diseases'] is List) {
          for (var d in (data['diseases'] as List)) {
            _selectedDiseases.add(d.toString());
          }
        }
        _physicalCondition = data['physicalCondition'] as String?;
        _slangUsage = data['slangUsage'] as String?;
        _foodType = data['foodType'] as String?;
        _studyTime = data['studyTime'] as String?;
        _fanPreference = data['fanPreference'] as String?;
        _acPreference = data['acPreference'] as String?;
        _floorPreference = data['floorPreference'] as String?;
        _pgDurationController.text = data['pgDuration']?.toString() ?? '';
        _pgDuration = data['pgDuration']?.toInt();
        _pgDurationUnit = data['pgDurationUnit'] as String?;
        _occupationCategory = data['occupationCategory'] as String?;
        _occupationDetail = data['occupationDetail'] as String?;

        _smoking = data['smoking'] as String?;
        _drinking = data['drinking'] as String?;
        _pets = data['pets'] as String?;
        _workShift = data['workShift'] as String?;
        _shareBathroom = data['shareBathroom'] ?? true;
        _cleanliness = (data['cleanliness'] ?? 3).toInt();
        _socialLevel = (data['socialLevel'] ?? 3).toInt();

        if (data['sleepTime'] is String) {
          final t = _parseTimeOfDay(data['sleepTime'] as String);
          if (t != null) _sleepTime = t;
        }
        if (data['wakeTime'] is String) {
          final t = _parseTimeOfDay(data['wakeTime'] as String);
          if (t != null) _wakeTime = t;
        }

        if (data['budgetMin'] != null && data['budgetMax'] != null) {
          final min = (data['budgetMin'] as num).toDouble();
          final max = (data['budgetMax'] as num).toDouble();
          _budgetRange = RangeValues(min, max);
        }
      }
    } catch (e) {
      // handle if needed
    } finally {
      _initialLoading = false;
      _recalculateCompleteness();
      if (mounted) setState(() {});
    }
  }

  TimeOfDay? _parseTimeOfDay(String s) {
    try {
      final parts = s.split(':');
      if (parts.length == 2) {
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    } catch (_) {}
    return null;
  }

  String _formatTimeOfDay(TimeOfDay? t) {
    if (t == null) return 'Not set';
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickTime(BuildContext ctx, bool isSleep) async {
    final t = await showTimePicker(
      context: ctx,
      initialTime: TimeOfDay(hour: 23, minute: 30),
    );
    if (t != null) {
      setState(() {
        if (isSleep)
          _sleepTime = t;
        else
          _wakeTime = t;
        _recalculateCompleteness();
      });
    }
  }

  Widget _buildChips(String label, List<String> options, Set<String> selected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          children:
              options.map((opt) {
                final sel = selected.contains(opt);
                return FilterChip(
                  label: Text(opt),
                  selected: sel,
                  onSelected: (_) {
                    setState(() {
                      if (sel) {
                        selected.remove(opt);
                      } else {
                        selected.add(opt);
                      }
                    });
                  },
                );
              }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> options,
    void Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      items:
          options
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
      onChanged: onChanged,
    );
  }

  void _recalculateCompleteness() {
    // Define "important" fields for completeness:
    final checks = <bool>[];

    // core descriptive fields
    checks.add(_selectedBehaviors.isNotEmpty);
    checks.add(_selectedInterests.isNotEmpty);
    checks.add(_selectedSocial.isNotEmpty);
    checks.add(_selectedHobbies.isNotEmpty);
    checks.add(_selectedLanguages.isNotEmpty);

    // lifestyle
    checks.add(_smoking != null && _smoking!.isNotEmpty);
    checks.add(_drinking != null && _drinking!.isNotEmpty);
    checks.add(_pets != null && _pets!.isNotEmpty);
    checks.add(_sleepTime != null);
    checks.add(_wakeTime != null);
    checks.add(_workShift != null && _workShift!.isNotEmpty);
    checks.add(_shareBathroom == true || _shareBathroom == false);
    checks.add(_slangUsage != null && _slangUsage!.isNotEmpty);
    checks.add(_foodType != null && _foodType!.isNotEmpty);
    checks.add(_studyTime != null && _studyTime!.isNotEmpty);
    checks.add(_fanPreference != null && _fanPreference!.isNotEmpty);
    checks.add(_acPreference != null && _acPreference!.isNotEmpty);
    checks.add(_floorPreference != null && _floorPreference!.isNotEmpty);
    checks.add(_pgDuration != null && _pgDuration! > 0);
    checks.add(_pgDurationUnit != null && _pgDurationUnit!.isNotEmpty);
    checks.add(_occupationCategory != null && _occupationCategory!.isNotEmpty);
    checks.add(_occupationDetail != null && _occupationDetail!.isNotEmpty);
    checks.add(_physicalCondition != null && _physicalCondition!.isNotEmpty);
    checks.add(_selectedAllergies.isNotEmpty);
    checks.add(_selectedDiseases.isNotEmpty);

    // numeric & scales
    checks.add(_cleanliness >= 1 && _cleanliness <= 5);
    checks.add(_socialLevel >= 1 && _socialLevel <= 5);

    // finances & preferences
    checks.add(_budgetRange.start > 0 && _budgetRange.end > _budgetRange.start);

    // education scores (must be parseable positive numbers)
    final tenth = double.tryParse(_tenthController.text.trim());
    final twelfth = double.tryParse(_twelfthController.text.trim());
    checks.add(tenth != null && tenth >= 0 && tenth <= 100);
    checks.add(twelfth != null && twelfth >= 0 && twelfth <= 100);

    // at least one contact or occupation
    checks.add(_emergencyContactController.text.trim().isNotEmpty);

    // compute percent
    final passed = checks.where((c) => c).length;
    _completeness = passed / checks.length;
  }

  Future<void> _savePreferences({required bool markComplete}) async {
    setState(() => _loading = true);
    _recalculateCompleteness();

    final isCompleteEnough = _completeness >= 1.0; // require full completion
    if (markComplete && !isCompleteEnough) {
      // show a dialog and refuse to mark complete
      setState(() => _loading = false);
      await showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: const Text('Incomplete preferences'),
              content: Text(
                'You must complete all required fields before marking preferences as given. '
                'Completion: ${(_completeness * 100).round()}%',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
      return;
    }

    final prefsData = {
      'behavior': _selectedBehaviors.toList(),
      'socialBehavior': _selectedSocial.toList(),
      'interests': _selectedInterests.toList(),
      'emergencyContact': _emergencyContactController.text.trim(),
      'tenthPercentage': double.tryParse(_tenthController.text.trim()),
      'twelfthPercentage': double.tryParse(_twelfthController.text.trim()),
      'hobbies': _selectedHobbies.toList(),
      'languages': _selectedLanguages.toList(),
      'smoking': _smoking,
      'drinking': _drinking,
      'pets': _pets,
      'workShift': _workShift,
      'shareBathroom': _shareBathroom,
      'cleanliness': _cleanliness,
      'socialLevel': _socialLevel,
      'slangUsage': _slangUsage,
      'foodType': _foodType,
      'studyTime': _studyTime,
      'fanPreference': _fanPreference,
      'acPreference': _acPreference,
      'floorPreference': _floorPreference,
      'pgDuration': _pgDuration,
      'pgDurationUnit': _pgDurationUnit,
      'occupationCategory': _occupationCategory,
      'occupationDetail': _occupationDetail,
      'physicalCondition': _physicalCondition,
      'allergies': _selectedAllergies.toList(),
      'diseases': _selectedDiseases.toList(),
      'sleepTime':
          _sleepTime != null
              ? '${_sleepTime!.hour}:${_sleepTime!.minute}'
              : null,
      'wakeTime':
          _wakeTime != null ? '${_wakeTime!.hour}:${_wakeTime!.minute}' : null,
      'budgetMin': _budgetRange.start,
      'budgetMax': _budgetRange.end,
      'updatedAt': FieldValue.serverTimestamp(),
      'preferencesGiven': (markComplete && isCompleteEnough) ? true : false,
    };

    // write in a single batch for consistency
    final batch = FirebaseFirestore.instance.batch();
    final roomFinderDoc = FirebaseFirestore.instance
        .collection('roomFinders')
        .doc(widget.uid);
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid);
    batch.set(roomFinderDoc, prefsData, SetOptions(merge: true));
    batch.set(userDoc, {
      'preferencesGiven': prefsData['preferencesGiven'] ?? false,
    }, SetOptions(merge: true));

    await batch.commit();

    setState(() => _loading = false);
    if (mounted) {
      // if user marked complete and it was allowed, go back
      if (markComplete && isCompleteEnough)
        Navigator.pop(context);
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              markComplete ? 'Saved (not complete).' : 'Draft saved',
            ),
          ),
        );
      }
    }
  }

  // Sub-widget to avoid repetition
  Widget _buildPreferenceTile(String title, dynamic value) {
    String displayText;
    if (value == null) {
      displayText = '—';
    } else if (value is List && value.isEmpty) {
      displayText = '—';
    } else if (value is List) {
      displayText = value.join(', ');
    } else {
      displayText = value.toString();
    }

    return ListTile(
      dense: true,
      title: Text(title),
      subtitle: Text(displayText),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
    );
  }

  @override
  void dispose() {
    behaviorOptions.clear();
    socialOptions.clear();
    interestsOptions.clear();
    _emergencyContactController.dispose();
    _tenthController.dispose();
    _twelfthController.dispose();
    super.dispose();
  }

  Widget _buildChoiceDropdown(
    String label,
    String? value,
    List<String> items,
    void Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items:
          items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_initialLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Preferences')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Completeness bar & preview
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Profile Completeness
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Profile Preferences Completion',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text('${(_completeness * 100).round()}%'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _completeness,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade300,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),

                    // Expansion: Preview of preferences
                    ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      title: const Text(
                        'Preview of Entered Preferences',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      children: [
                        _buildPreferenceTile('Behavior', _selectedBehaviors),
                        _buildPreferenceTile('Interests', _selectedInterests),
                        _buildPreferenceTile('Hobbies', _selectedHobbies),
                        _buildPreferenceTile('Work Shift', _workShift),
                        _buildPreferenceTile('Bathroom Sharing',_shareBathroom == null ? null : (_shareBathroom! ? 'Yes' : 'No'),),
                        _buildPreferenceTile('Food Preferences', _foodType),
                        _buildPreferenceTile('Study Time', _studyTime),
                        _buildPreferenceTile('Fan Preference', _fanPreference),
                        _buildPreferenceTile('AC Preference', _acPreference),
                        _buildPreferenceTile('Floor Preference',_floorPreference),
                        _buildPreferenceTile('PG Duration', _pgDuration?.toString(),),
                        _buildPreferenceTile('PG Duration Unit', _pgDurationUnit,),
                        _buildPreferenceTile('Occupation Category', _occupationCategory,),
                        _buildPreferenceTile('Occupation Detail', _occupationDetail,),
                        _buildPreferenceTile('Physical Condition',_physicalCondition,),
                        _buildPreferenceTile('Allergies', _selectedAllergies),
                        _buildPreferenceTile('Diseases', _selectedDiseases),
                        _buildPreferenceTile('Languages', _selectedLanguages),
                        _buildPreferenceTile('Smoking', _smoking),
                        _buildPreferenceTile(
                          'Sleep / Wake',
                          '${_formatTimeOfDay(_sleepTime)} / ${_formatTimeOfDay(_wakeTime)}',
                        ),
                        _buildPreferenceTile(
                          'Budget',
                          '₹${_budgetRange.start.round()} - ₹${_budgetRange.end.round()}',
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Large inputs
            _buildChips("Behavior", behaviorOptions, _selectedBehaviors),
            _buildChips("Social Behavior", socialOptions, _selectedSocial),
            _buildChips("Interests", interestsOptions, _selectedInterests),
            _buildChips("Hobbies", hobbyOptions, _selectedHobbies),

            const SizedBox(height: 10),
            // Smoking / Drinking / Pets / Work shift
            Row(
              children: [
                Expanded(
                  child: _buildChoiceDropdown(
                    'Smoking',
                    _smoking,
                    ['Yes', 'No', 'Sometimes', 'Prefer not to say'],
                    (v) => setState(() {
                      _smoking = v;
                      _recalculateCompleteness();
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildChoiceDropdown(
                    'Drinking',
                    _drinking,
                    ['Yes', 'No', 'Sometimes', 'Prefer not to say'],
                    (v) => setState(() {
                      _drinking = v;
                      _recalculateCompleteness();
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildChoiceDropdown(
                    'Pets',
                    _pets,
                    ['Has pet', 'No pet', 'Wants pet', 'Doesn\'t like pets'],
                    (v) => setState(() {
                      _pets = v;
                      _recalculateCompleteness();
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildChoiceDropdown(
                    'Work Shift',
                    _workShift,
                    ['WFH', 'Office', 'Hybrid', 'Night', 'Rotational'],
                    (v) => setState(() {
                      _workShift = v;
                      _recalculateCompleteness();
                    }),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Cleanliness and social scale
            Row(
              children: [
                const Text('Cleanliness'),
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    value: _cleanliness.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: '$_cleanliness',
                    onChanged: (v) => setState(() => _cleanliness = v.round()),
                  ),
                ),
                const SizedBox(width: 8),
                Text('$_cleanliness/5'),
              ],
            ),
            Row(
              children: [
                const Text('Social Level'),
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    value: _socialLevel.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: '$_socialLevel',
                    onChanged: (v) => setState(() => _socialLevel = v.round()),
                  ),
                ),
                const SizedBox(width: 8),
                Text('$_socialLevel/5'),
              ],
            ),

            const SizedBox(height: 10),

            // Sleep/wake pickers
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickTime(context, true),
                    child: Text('Sleep: ${_formatTimeOfDay(_sleepTime)}'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickTime(context, false),
                    child: Text('Wake: ${_formatTimeOfDay(_wakeTime)}'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Budget
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Preferred Budget (₹)'),
                RangeSlider(
                  values: _budgetRange,
                  min: 0,
                  max: 50000,
                  divisions: 100,
                  labels: RangeLabels(
                    '${_budgetRange.start.round()}',
                    '${_budgetRange.end.round()}',
                  ),
                  onChanged: (v) => setState(() => _budgetRange = v),
                ),
              ],
            ),

            const SizedBox(height: 10),

            _buildDropdown(
              "Slang Usage",
              _slangUsage,
              slangOptions,
              (val) => setState(() => _slangUsage = val),
            ),
            const SizedBox(height: 16),

            // Occupation
            _buildDropdown(
              "Occupation Type",
              _occupationCategory,
              occupationOptions.keys.toList(),
              (val) {
                setState(() {
                  _occupationCategory = val;
                  _occupationDetail = null;
                });
              },
            ),
            if (_occupationCategory != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _buildDropdown(
                  "$_occupationCategory Details",
                  _occupationDetail,
                  occupationOptions[_occupationCategory]!,
                  (val) => setState(() => _occupationDetail = val),
                ),
              ),
            const SizedBox(height: 16),

            // Food & Lifestyle
            _buildDropdown(
              "Food Type",
              _foodType,
              foodOptions,
              (val) => setState(() => _foodType = val),
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              "Study/Work Time",
              _studyTime,
              studyTimeOptions,
              (val) => setState(() => _studyTime = val),
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              "Fan Preference",
              _fanPreference,
              yesNoAdjustable,
              (val) => setState(() => _fanPreference = val),
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              "AC Preference",
              _acPreference,
              yesNoAdjustable,
              (val) => setState(() => _acPreference = val),
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              "Floor Preference",
              _floorPreference,
              floorOptions,
              (val) => setState(() => _floorPreference = val),
            ),
            const SizedBox(height: 16),

            // PG Duration
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _pgDurationController,
                    decoration: const InputDecoration(
                      labelText: "PG Duration (Number)",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      setState(() {
                        _pgDuration = int.tryParse(v);
                        _recalculateCompleteness();
                      });
                    },
                  ),
                ),

                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdown(
                    "Duration Unit",
                    _pgDurationUnit,
                    ["Days", "Months", "Years"],
                    (val) => setState(() => _pgDurationUnit = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Medical
            _buildChips("Allergies", allergyOptions, _selectedAllergies),
            _buildChips("Diseases", diseaseOptions, _selectedDiseases),
            _buildDropdown(
              "Physical Condition",
              _physicalCondition,
              physicalOptions,
              (val) => setState(() => _physicalCondition = val),
            ),
            const SizedBox(height: 16),

            // Languages
            _buildChips("Languages", languageOptions, _selectedLanguages),

            // Education & Occupation
            TextField(
              controller: _tenthController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '10th % (number)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _twelfthController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '12th % (number)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emergencyContactController,
              decoration: const InputDecoration(
                labelText: 'Emergency contact',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 18),

            // Save buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        _loading
                            ? null
                            : () => _savePreferences(markComplete: false),
                    icon:
                        _loading
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.save_alt),
                    label: const Text('Save Draft'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed:
                        _loading
                            ? null
                            : () => _savePreferences(markComplete: true),
                    icon:
                        _loading
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Icon(Icons.check),
                    label: const Text('Save & Mark Complete'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
