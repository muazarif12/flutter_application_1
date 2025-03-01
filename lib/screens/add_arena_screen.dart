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
  
  // Dropdown selections
  String? _selectedSport;
  bool _isHalfCourt = false;
  bool _instantBooking = false;
  String _pricingStrategy = 'Per Hour';
  
  // Slot configuration
  TimeOfDay? _openingTime;
  TimeOfDay? _closingTime;
  int _slotDuration = 60;
  bool _monthlyOffer = false;
  bool _dailyPromo = false;
  
  // Facilities checkboxes
  final List<String> facilities = [
    'Parking', 'Showers', 'Lockers', 'Cafeteria', 'Wi-Fi', 'Sauna'
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

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeBloc>().state;
    final bool isDarkMode = themeState is DarkThemeState;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        forceMaterialTransparency: true,
        title: const Text("Add New Arena"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _card(isDarkMode: isDarkMode, title: 'Basic Information', child: Column(
                children: [
                  _buildTextField(nameController, "Arena Name",),
                  _buildTextField(descriptionController, "Description", ),
                  _buildDropdownField("Sport Offered", ['Football', 'Basketball', 'Tennis', 'Cricket']),
                ],
              )),
              _card(isDarkMode: isDarkMode, title: 'Location & Contact', child: Column(
                children: [
                  _buildTextField(locationController, "Location"),
                  _buildTextField(contactController, "Contact Number"),
                ],
              )),

              _card(isDarkMode: isDarkMode, title: 'Media Upload', child: _buildMediaUpload()),

              _card(isDarkMode: isDarkMode, title: 'Facilities', child: _buildMultiCheckboxField(facilities, selectedFacilities,)),

              _card(isDarkMode: isDarkMode, title: 'Pricing & Fees', child: Column(
                children: [
                  _buildPricingStrategy(),
                  _buildTextField(pricingController, "Base Pricing (Per Hour)", ),
                  _buildTextField(additionalFeeController, "Additional Services Fee (if any)", ),
                ],
              )),

              _card(isDarkMode: isDarkMode, title: 'Booking & Slot Configurations', child: Column(
                children: [
                  _buildToggleField("Allow Instant Booking?", _instantBooking, (value) => setState(() => _instantBooking = value),),
                  _buildToggleField("Half Court Available?", _isHalfCourt, (value) => setState(() => _isHalfCourt = value),),
                  _buildSlotDesign(),
                ],
              )),

              _card(isDarkMode: isDarkMode, title: 'Policies', child: _buildDropdownField("Cancellation Policy", ['Flexible', 'Moderate'],)),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Save arena logic
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Arena Added Successfully!"))
                      );
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

  Widget _card({required String title, required Widget child, required bool isDarkMode}) {
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
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
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
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        validator: (value) => value!.isEmpty ? "Required field" : null,
      ),
    );
  }

  // Dropdown Field
  Widget _buildDropdownField(String label, List<String> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
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
        _buildDropdownField("Slot Duration (minutes)", ['30', '45', '60', '90', '120']),
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
          TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
          if (picked != null) setState(() => onPicked(picked));
        },
      ),
    );
  }

  // Multi-checkbox field
  Widget _buildMultiCheckboxField(List<String> options, Map<String, bool> selections) {
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
          children: _mediaFiles.map((file) => Image.file(file, width: 80, height: 80)).toList(),
        ),
      ],
    );
  }
}
