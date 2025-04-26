import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';

class AddArenaScreen extends StatefulWidget {
  const AddArenaScreen({super.key});

  @override
  AddArenaScreenState createState() => AddArenaScreenState();
}

class AddArenaScreenState extends State<AddArenaScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form inputs
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController pricingController = TextEditingController();
  final TextEditingController additionalFeeController = TextEditingController();

  // Selected images/videos
  List<File> _mediaFiles = [];

  final Map<String, TimeOfDay?> _openingTimes = {};
  final Map<String, TimeOfDay?> _closingTimes = {};

  // Dropdown selections
  String? _selectedSport;
  bool _isHalfCourt = false;
  bool _instantBooking = false;
  String _pricingStrategy = 'Per Hour';

  // Slot configuration
  TimeOfDay? _openingTime;
  TimeOfDay? _closingTime;
  bool _dailyPromo = false;
  final Map<String, int> _slotDurations = {};
  final Map<String, List<String>> _generatedSlots = {};
  final Map<String, bool> _selectedDays = {}; // New: To track selected days
  bool _sameTimingEnabled = false;
  TimeOfDay? _globalOpeningTime;
  TimeOfDay? _globalClosingTime;

  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  // Facilities checkboxes
  final List<String> facilities = [
    'Parking',
    'Showers',
    'Lockers',
    'Cafeteria',
    'Wi-Fi',
    'Sauna'
  ];
  final Map<String, bool> selectedFacilities = {};

  // Policies
  String _cancellationPolicy = 'Flexible';
  final Map<String, double> _slotDurationValues = {}; // New state for slider

  @override
  void initState() {
    super.initState();
    for (var day in _days) {
      _selectedDays[day] = false; // ✅ Ensures all days are initialized
      _openingTimes[day] = null;
      _closingTimes[day] = null;
      _generatedSlots[day] = [];
      _slotDurations.putIfAbsent(day, () => 60);
      _slotDurationValues.putIfAbsent(day, () => 60.0);
    }
  }

  // Image Picker Function
  Future<void> _pickMedia() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      setState(() {
        _mediaFiles.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  Future<void> _pickTime(
      BuildContext context, String? day, bool isOpeningTime) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        if (day == null) {
          // Global timing case
          if (isOpeningTime) {
            _globalOpeningTime = picked;
          } else {
            _globalClosingTime = picked;
          }
        } else {
          // Day-specific timing
          if (isOpeningTime) {
            _openingTimes[day] = picked;
          } else {
            _closingTimes[day] = picked;
          }
        }
      });

      if (day != null) {
        _generateSlots(day);
      }
    }
  }

  // Generate Slots Based on Opening, Closing Time & Duration
  void _generateSlots(String day) {
    if (_openingTimes[day] == null || _closingTimes[day] == null) {
      setState(() {
        _generatedSlots[day] = [];
      });
      return;
    }

    TimeOfDay startTime = _openingTimes[day]!;
    TimeOfDay endTime = _closingTimes[day]!;
    int duration = 60; // Default slot duration
    List<String> slots = [];
    TimeOfDay currentTime = startTime;

    while (_timeOfDayToMinutes(currentTime) + duration <=
        _timeOfDayToMinutes(endTime)) {
      TimeOfDay slotEnd = _addMinutesToTime(currentTime, duration);
      slots.add("${_formatTime(currentTime)} - ${_formatTime(slotEnd)}");
      currentTime = slotEnd;
    }

    setState(() {
      _generatedSlots[day] = slots;
    });
  }

  // Convert TimeOfDay to Minutes
  int _timeOfDayToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  // Add Minutes to TimeOfDay
  TimeOfDay _addMinutesToTime(TimeOfDay time, int minutes) {
    int totalMinutes = _timeOfDayToMinutes(time) + minutes;
    return TimeOfDay(hour: totalMinutes ~/ 60, minute: totalMinutes % 60);
  }

  // Format TimeOfDay
  String _formatTime(TimeOfDay time) {
    return "${time.hourOfPeriod}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? "AM" : "PM"}";
  }

  // Apply Same Timing to Selected Days
  void _applySameTiming() {
    setState(() {
      for (var day in _days) {
        if (_selectedDays[day] == true) {
          if (_globalOpeningTime != null && _globalClosingTime != null) {
            _openingTimes[day] = _globalOpeningTime;
            _closingTimes[day] = _globalClosingTime;
            _generateSlots(day);
          }
        } else {
          _openingTimes[day] = null;
          _closingTimes[day] = null;
          _generatedSlots[day] = [];
        }
      }
    });
  }

  Widget _buildSlotConfiguration() {
    return Column(
      children: [
        SwitchListTile(
          title: const Text(
            "Set Same Timing for Selected Days",
            style: TextStyle(color: Colors.blue),
          ),
          activeColor: Colors.blue,
          value: _sameTimingEnabled,
          onChanged: (value) {
            setState(() {
              _sameTimingEnabled = value;
            });
          },
        ),
        if (_sameTimingEnabled) ...[
          Row(
            children: [
              const Text(
                "Opening: ",
                style: TextStyle(color: Colors.blue),
              ),
              IconButton(
                icon: const Icon(Icons.access_time, color: Colors.blue),
                onPressed: () => _pickTime(context, null, true),
              ),
              Text(_globalOpeningTime != null
                  ? _formatTime(_globalOpeningTime!)
                  : "Not Set"),
            ],
          ),
          Row(
            children: [
              const Text(
                "Closing: ",
                style: TextStyle(color: Colors.blue),
              ),
              IconButton(
                icon: const Icon(Icons.access_time, color: Colors.red),
                onPressed: () => _pickTime(context, null, false),
              ),
              Text(_globalClosingTime != null
                  ? _formatTime(_globalClosingTime!)
                  : "Not Set"),
            ],
          ),
          ElevatedButton.icon(
            onPressed:
                (_globalOpeningTime != null && _globalClosingTime != null)
                    ? _applySameTiming
                    : null,
            icon: const Icon(Icons.check),
            label: const Text("Apply Timing to Selected Days"),
          ),
        ],
        Column(
          children: _days.map((day) {
            return ExpansionTile(
              title: Row(
                children: [
                  Checkbox(
                    activeColor: Colors.blue,
                    value: _selectedDays[day],
                    onChanged: (value) {
                      setState(() {
                        _selectedDays[day] = value ?? false;
                        if (!value!) {
                          _openingTimes[day] = null;
                          _closingTimes[day] = null;
                          _generatedSlots[day] = [];
                        }
                      });
                    },
                  ),
                  Text(
                    day,
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
              ),
              children: [
                Row(
                  children: [
                    const Text("Opening: "),
                    IconButton(
                      icon: const Icon(Icons.access_time, color: Colors.blue),
                      onPressed: () => _pickTime(context, day, true),
                    ),
                    Text(_openingTimes[day] != null
                        ? _formatTime(_openingTimes[day]!)
                        : "Not Set"),
                  ],
                ),
                Row(
                  children: [
                    const Text("Closing: "),
                    IconButton(
                      icon: const Icon(Icons.access_time, color: Colors.red),
                      onPressed: () => _pickTime(context, day, false),
                    ),
                    Text(_closingTimes[day] != null
                        ? _formatTime(_closingTimes[day]!)
                        : "Not Set"),
                  ],
                ),
                if (_generatedSlots[day]!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Generated Slots:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      ..._generatedSlots[day]!.map((slot) => Text(slot)),
                    ],
                  ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeBloc>().state;
    final bool isDarkMode = themeState is DarkThemeState;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        forceMaterialTransparency: true,
        title: const Text(
          "Add New Arena",
          style: TextStyle(color: Colors.blue),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.blue),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _card(
                  isDarkMode: isDarkMode,
                  title: 'Basic Information',
                  child: Column(
                    children: [
                      _buildTextField(nameController, "Arena Name"),
                      _buildTextField(descriptionController, "Description"),
                      _buildDropdownField("Sport Offered",
                          ['Football', 'Basketball', 'Tennis', 'Cricket']),
                    ],
                  )),
              _card(
                  isDarkMode: isDarkMode,
                  title: 'Location & Contact',
                  child: Column(
                    children: [
                      _buildTextField(locationController, "Location"),
                      _buildTextField(contactController, "Contact Number"),
                    ],
                  )),
              _card(
                  title: 'Timings',
                  child: _buildSlotConfiguration(),
                  isDarkMode: isDarkMode),
              _card(
                  isDarkMode: isDarkMode,
                  title: 'Media Upload',
                  child: _buildMediaUpload()),
              _card(
                  isDarkMode: isDarkMode,
                  title: 'Facilities',
                  child:
                      _buildMultiCheckboxField(facilities, selectedFacilities)),
              _card(
                isDarkMode: isDarkMode,
                title: 'Pricing & Fees',
                child: Column(
                  children: [
                    _buildPricingInput(),
                    const SizedBox(
                      height: 20,
                    ), // ✅ Corrected function
                    _buildTextField(additionalFeeController,
                        "Additional Services Fee (if any)"),
                  ],
                ),
              ),
              _card(
                  isDarkMode: isDarkMode,
                  title: 'Policies',
                  child: _buildDropdownField(
                      "Cancellation Policy", ['Flexible', 'Moderate'])),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Arena Added Successfully!")));
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Add Arena"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(
      {required String title,
      required Widget child,
      required bool isDarkMode}) {
    return Card(
      color: isDarkMode ? Colors.grey[850] : Colors.white,
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue)),
            const Divider(),
            child,
          ],
        ),
      ),
    );
  }

  // Generic Text Field
  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(),
            labelStyle: TextStyle(color: Colors.blue)),
        validator: (value) => value!.isEmpty ? "Required field" : null,
      ),
    );
  }

  // Dropdown Field
  Widget _buildDropdownField(String label, List<String> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(),
            labelStyle: TextStyle(color: Colors.blue)),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: (value) {
          setState(() {
            if (label == "Sport Offered") _selectedSport = value;
            if (label == "Cancellation Policy") _cancellationPolicy = value!;
          });
        },
        validator: (value) => value == null ? "Required field" : null,
      ),
    );
  }

  // Toggle Switch
  Widget _buildToggleField(String label, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(label),
      value: value,
      onChanged: onChanged,
    );
  }

  // Pricing Strategy Selection
  Widget _buildPricingInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: const Text("Base Pricing (Per Hour)",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Decrement Button
            IconButton(
              icon: const Icon(Icons.remove, color: Colors.red),
              onPressed: () {
                setState(() {
                  int price = int.tryParse(pricingController.text) ?? 0;
                  if (price > 0) {
                    pricingController.text =
                        (price - 5).toString(); // Decrease by 5
                  }
                });
              },
            ),

            // Price Text Input
            SizedBox(
              width: 80,
              child: TextFormField(
                controller: pricingController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      int price = int.tryParse(value) ?? 0;
                      pricingController.text =
                          price.toString(); // Ensure valid integer
                    });
                  }
                },
              ),
            ),

            // Increment Button
            IconButton(
              icon: const Icon(Icons.add, color: Colors.green),
              onPressed: () {
                setState(() {
                  int price = int.tryParse(pricingController.text) ?? 0;
                  pricingController.text =
                      (price + 5).toString(); // Increase by 5
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  // Slot Design
  Widget _buildSlotDesign() {
    return Column(
      children: [
        const Text("Slot Design"),
        _buildTimePicker("Opening Time", (time) => _openingTime = time),
        _buildTimePicker("Closing Time", (time) => _closingTime = time),
        _buildDropdownField(
            "Max Slot Duration (minutes)", ['30', '45', '60', '90', '120']),
      ],
    );
  }

  // Time Picker
  Widget _buildTimePicker(String label, Function(TimeOfDay) onPicked) {
    return ListTile(
      title: Text(label),
      trailing: IconButton(
        icon: const Icon(Icons.access_time),
        onPressed: () async {
          TimeOfDay? picked = await showTimePicker(
              context: context, initialTime: TimeOfDay.now());
          if (picked != null) setState(() => onPicked(picked));
        },
      ),
    );
  }

  // Multi-checkbox field
  Widget _buildMultiCheckboxField(
      List<String> options, Map<String, bool> selections) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...options.map((option) => CheckboxListTile(
              activeColor: Colors.blue,
              title: Text(
                option,
                style: TextStyle(color: Colors.blue),
              ),
              value: selections[option] ?? false, // ✅ Default to `false`
              onChanged: (value) {
                setState(() => selections[option] = value ?? false);
              },
            )),
      ],
    );
  }

  // Media Upload
  Widget _buildMediaUpload() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _pickMedia,
          icon: const Icon(Icons.camera_alt),
          label: const Text("Upload Media"),
        ),
        Wrap(
          children: _mediaFiles
              .map((file) => Image.file(file, width: 80, height: 80))
              .toList(),
        ),
      ],
    );
  }
}
