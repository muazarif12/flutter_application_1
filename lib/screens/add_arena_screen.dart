import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../bloc/theme/theme_bloc.dart';
import '../bloc/theme/theme_state.dart';

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
  final Map<String, int> _maxSlotDurations = {};
  final Map<String, List<String>> _generatedSlots = {};

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

  @override
  void initState() {
    super.initState();
    for (var facility in facilities) {
      selectedFacilities[facility] = false;
    }
    for (var day in _days) {
      _openingTimes[day] = null;
      _closingTimes[day] = null;
      _maxSlotDurations[day] = 60; // Default max slot duration
      _generatedSlots[day] = [];
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

  // Time Picker Function
  Future<void> _pickTime(
      BuildContext context, String day, bool isOpeningTime) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        if (isOpeningTime) {
          _openingTimes[day] = picked;
        } else {
          _closingTimes[day] = picked;
        }
      });

      _generateSlots(day);
    }
  }

  // Generate Slots Based on Opening, Closing Time & Duration
  void _generateSlots(String day) {
    if (_openingTimes[day] == null || _closingTimes[day] == null) return;

    TimeOfDay startTime = _openingTimes[day]!;
    TimeOfDay endTime = _closingTimes[day]!;
    int duration = _maxSlotDurations[day]!;

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

  Widget _buildSlotConfiguration() {
    return Column(
      children: _days.map((day) {
        return ExpansionTile(
          title: Text(day, style: const TextStyle(fontWeight: FontWeight.bold)),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Opening Time
                  Expanded(
                    child: Row(
                      children: [
                        const Text("Opening: "),
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 12),
                              alignment: Alignment.centerLeft,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              side: const BorderSide(
                                  color: Colors.grey), // Add border
                            ),
                            onPressed: () => _pickTime(context, day, true),
                            child: Text(
                              _openingTimes[day] != null
                                  ? _formatTime(_openingTimes[day]!)
                                  : "Select Time",
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10), // Space between
                  // Closing Time
                  Expanded(
                    child: Row(
                      children: [
                        const Text("Closing: "),
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 12),
                              alignment: Alignment.centerLeft,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              side: const BorderSide(
                                  color: Colors.grey), // Add border
                            ),
                            onPressed: () => _pickTime(context, day, false),
                            child: Text(
                              _closingTimes[day] != null
                                  ? _formatTime(_closingTimes[day]!)
                                  : "Select Time",
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Max Slot Duration Slider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Max Slot Duration (minutes)",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: _maxSlotDurations[day]!.toDouble(),
                    min: 30,
                    max: 60,
                    divisions: 6, // Ensures step size of 5
                    label: "${_maxSlotDurations[day]} min",
                    onChanged: (value) {
                      setState(() {
                        _maxSlotDurations[day] = value.toInt();
                        _generateSlots(day);
                      });
                    },
                  ),
                  Text(
                    "${_maxSlotDurations[day]} minutes",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            // Generated Slots List
            if (_generatedSlots[day]!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Generated Slots:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    ..._generatedSlots[day]!.map((slot) => Text(slot)).toList(),
                  ],
                ),
              ),
          ],
        );
      }).toList(),
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
        title: const Text("Add New Arena"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
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
                    _buildIncrementDecrementField(
                        pricingController, "Base Pricing (Per Hour)"),
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

  Widget _buildIncrementDecrementField(
      TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove, color: Colors.red),
                onPressed: () {
                  setState(() {
                    int value = int.tryParse(controller.text) ?? 0;
                    if (value > 0) {
                      value -= 5; // Decrease by 5
                      controller.text = value.toString();
                    }
                  });
                },
              ),
              SizedBox(
                width: 50,
                child: TextFormField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(border: InputBorder.none),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  onChanged: (val) {
                    if (val.isEmpty) {
                      controller.text = "0";
                    }
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.green),
                onPressed: () {
                  setState(() {
                    int value = int.tryParse(controller.text) ?? 0;
                    value += 5; // Increase by 5
                    controller.text = value.toString();
                  });
                },
              ),
            ],
          ),
        ],
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
                    color: isDarkMode ? Colors.white : Colors.black)),
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
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
        validator: (value) => value!.isEmpty ? "Required field" : null,
      ),
    );
  }

  // Dropdown Field
  Widget _buildDropdownField(String label, List<String> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
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
  Widget _buildPricingStrategy() {
    return Column(
      children: [
        RadioListTile(
          title: const Text("Per Hour"),
          value: "Per Hour",
          groupValue: _pricingStrategy,
          onChanged: (value) {
            setState(() => _pricingStrategy = value.toString());
          },
        ),
        RadioListTile(
          title: const Text("Per Person Per Hour"),
          value: "Per Person Per Hour",
          groupValue: _pricingStrategy,
          onChanged: (value) {
            setState(() => _pricingStrategy = value.toString());
          },
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
              title: Text(option),
              value: selections[option],
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
