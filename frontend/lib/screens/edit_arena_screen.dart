import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../bloc/theme/theme_bloc.dart';
import '../bloc/theme/theme_state.dart';

class EditArenaScreen extends StatefulWidget {
  final Map<String, dynamic> arena;

  const EditArenaScreen({super.key, required this.arena});

  @override
  EditArenaScreenState createState() => EditArenaScreenState();
}

class EditArenaScreenState extends State<EditArenaScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers for form inputs
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController sizeController;
  late TextEditingController locationController;
  late TextEditingController contactController;
  late TextEditingController pricingController;
  late TextEditingController additionalFeeController;

  // Selected images/videos
  List<File> _mediaFiles = [];

  // Dropdown selections
  String? _selectedSport;
  int? _selectedMaxSlotDuration;
  bool _isHalfCourt = false;
  bool _instantBooking = false;
  String _pricingStrategy = 'Per Hour';

  // Max Slot configuration
  TimeOfDay? _openingTime;
  TimeOfDay? _closingTime;
  int _maxSlotDuration = 60;
  bool _monthlyOffer = false;
  bool _dailyPromo = false;

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
    // Initialize controllers with existing arena data
    nameController = TextEditingController(text: widget.arena['name']);
    descriptionController =
        TextEditingController(text: widget.arena['description']);
    sizeController = TextEditingController(text: widget.arena['size']);
    locationController = TextEditingController(text: widget.arena['location']);
    contactController = TextEditingController(text: widget.arena['contact']);
    pricingController = TextEditingController(text: widget.arena['price']);
    additionalFeeController =
        TextEditingController(text: widget.arena['additionalFee'] ?? '');

    _selectedSport = widget.arena['sport'];
    _selectedMaxSlotDuration = widget.arena['maxSlotDuration'] ?? 60;
    _isHalfCourt = widget.arena['isHalfCourt'] ?? false;
    _instantBooking = widget.arena['instantBooking'] ?? false;
    _pricingStrategy = widget.arena['pricingStrategy'] ?? 'Per Hour';

    // Load existing facilities
    for (var facility in facilities) {
      selectedFacilities[facility] =
          widget.arena['facilities']?.contains(facility) ?? false;
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
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        forceMaterialTransparency: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: isDarkMode ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Edit Arena",
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
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
                      _buildTextField(nameController, "Arena Name", isDarkMode),
                      _buildTextField(
                          descriptionController, "Description", isDarkMode),
                      _buildDropdownField(
                          "Sport Offered",
                          ['Football', 'Basketball', 'Tennis', 'Cricket'],
                          isDarkMode),
                    ],
                  )),
              _card(
                  isDarkMode: isDarkMode,
                  title: 'Location & Contact',
                  child: Column(
                    children: [
                      _buildTextField(
                          locationController, "Location", isDarkMode),
                      _buildTextField(
                          contactController, "Contact Number", isDarkMode),
                    ],
                  )),
              _card(
                  isDarkMode: isDarkMode,
                  title: 'Media Upload',
                  child: _buildMediaUpload()),
              _card(
                  isDarkMode: isDarkMode,
                  title: 'Facilities',
                  child: _buildMultiCheckboxField(
                      facilities, selectedFacilities, isDarkMode)),
              _card(
                  isDarkMode: isDarkMode,
                  title: 'Pricing & Fees',
                  child: Column(
                    children: [
                      _buildPricingStrategy(),
                      _buildTextField(pricingController,
                          "Base Pricing (Per Hour)", isDarkMode),
                      _buildTextField(additionalFeeController,
                          "Additional Services Fee (if any)", isDarkMode),
                    ],
                  )),
              _card(
                  isDarkMode: isDarkMode,
                  title: 'Booking & Slot Configurations',
                  child: Column(
                    children: [
                      _buildToggleField(
                          "Allow Instant Booking?",
                          _instantBooking,
                          (value) => setState(() => _instantBooking = value),
                          isDarkMode),
                      _buildToggleField(
                          "Half Court Available?",
                          _isHalfCourt,
                          (value) => setState(() => _isHalfCourt = value),
                          isDarkMode),
                      _buildSlotDesign(isDarkMode),
                    ],
                  )),
              _card(
                  isDarkMode: isDarkMode,
                  title: 'Policies',
                  child: _buildDropdownField("Cancellation Policy",
                      ['Flexible', 'Moderate'], isDarkMode)),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Arena Updated Successfully!")));
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Save Changes"),
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
                    color: isDarkMode ? Colors.white : Colors.black)),
            const Divider(),
            child,
          ],
        ),
      ),
    );
  }

  // Generic Text Field
  Widget _buildTextField(
      TextEditingController controller, String label, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          labelStyle: TextStyle(
              fontFamily: 'Exo2',
              color: isDarkMode ? Colors.white : Colors.black),
        ),
        validator: (value) => value!.isEmpty ? "Required field" : null,
      ),
    );
  }

  // Dropdown Field
  Widget _buildDropdownField(
      String label, List<String> items, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: label == "Sport Offered"
            ? _selectedSport
            : label == "Cancellation Policy"
                ? _cancellationPolicy
                : _selectedMaxSlotDuration?.toString(),
        decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(),
            labelStyle:
                TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: (value) {
          setState(() {
            if (label == "Sport Offered") _selectedSport = value;
            if (label == "Cancellation Policy") _cancellationPolicy = value!;
            if (label == "Max SLot Duration (minutes)")
              _selectedMaxSlotDuration = int.tryParse(value!);
          });
        },
        validator: (value) => value == null ? "Required field" : null,
      ),
    );
  }

  // Toggle Switch
  Widget _buildToggleField(
      String label, bool value, Function(bool) onChanged, bool isDarkMode) {
    return SwitchListTile(
      title: Text(
        label,
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      ),
      value: value,
      onChanged: onChanged,
    );
  }

  // Pricing Strategy Selection
  Widget _buildPricingStrategy() {
    return Column(
      children: [
        const Text("Pricing Strategy"),
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
  Widget _buildSlotDesign(bool isDarkMode) {
    return Column(
      children: [
        _buildTimePicker(
            "Opening Time", (time) => _openingTime = time, isDarkMode),
        _buildTimePicker(
            "Closing Time", (time) => _closingTime = time, isDarkMode),
        _buildDropdownField("Max SLot Duration (minutes)",
            ['30', '45', '60', '90', '120'], isDarkMode),
      ],
    );
  }

  // Time Picker
  Widget _buildTimePicker(
      String label, Function(TimeOfDay) onPicked, bool isDarkMode) {
    return ListTile(
      title: Text(
        label,
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      ),
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

  // Media Upload
  Widget _buildMediaUpload() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _pickMedia,
          icon: const Icon(Icons.camera_alt),
          label: const Text("Upload Media"),
        ),
      ],
    );
  }

  // Multi-Checkbox Field
  Widget _buildMultiCheckboxField(List<String> options,
      Map<String, bool> selectedOptions, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(label!, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,  color: isDarkMode? Colors.white : Colors.black)),
        ...options.map((option) {
          return CheckboxListTile(
            title: Text(
              option,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
            value: selectedOptions[option] ?? false,
            onChanged: (value) {
              setState(() {
                selectedOptions[option] = value ?? false;
              });
            },
          );
        }),
      ],
    );
  }
}
