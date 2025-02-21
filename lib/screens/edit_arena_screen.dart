import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditArenaScreen extends StatefulWidget {
  final Map<String, dynamic> arena;

  const EditArenaScreen({super.key, required this.arena});

  @override
  EditArenaScreenState createState() => EditArenaScreenState();
}

class EditArenaScreenState extends State<EditArenaScreen> {
  final _formKey = GlobalKey<FormState>();

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
    // Initialize controllers with existing arena data
    nameController = TextEditingController(text: widget.arena['name']);
    descriptionController = TextEditingController(text: widget.arena['description']);
    sizeController = TextEditingController(text: widget.arena['size']);
    locationController = TextEditingController(text: widget.arena['location']);
    contactController = TextEditingController(text: widget.arena['contact']);
    pricingController = TextEditingController(text: widget.arena['price']);
    additionalFeeController = TextEditingController(text: widget.arena['additionalFee'] ?? '');

    _selectedSport = widget.arena['sport'];
    _isHalfCourt = widget.arena['isHalfCourt'] ?? false;
    _instantBooking = widget.arena['instantBooking'] ?? false;
    _pricingStrategy = widget.arena['pricingStrategy'] ?? 'Per Hour';

    // Load existing facilities
    for (var facility in facilities) {
      selectedFacilities[facility] = widget.arena['facilities']?.contains(facility) ?? false;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Arena"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(nameController, "Arena Name"),
              _buildTextField(descriptionController, "Description"),
              _buildTextField(sizeController, "Arena Size (sq. meters)"),
              _buildDropdownField("Sport Offered", ['Football', 'Basketball', 'Tennis', 'Cricket']),
              _buildToggleField("Half Court Available?", _isHalfCourt, (value) {
                setState(() => _isHalfCourt = value);
              }),
              _buildTextField(locationController, "Location"),
              _buildTextField(contactController, "Contact Number"),
              
              // Media Upload
              _buildMediaUpload(),

              // Facilities
              _buildMultiCheckboxField("Facilities Available", facilities, selectedFacilities),

              _buildToggleField("Allow Instant Booking?", _instantBooking, (value) {
                setState(() => _instantBooking = value);
              }),

              _buildPricingStrategy(),
              
              _buildSlotDesign(),

              _buildTextField(additionalFeeController, "Additional Services Fee (if any)"),

              _buildToggleField("Set Monthly Offer?", _monthlyOffer, (value) {
                setState(() => _monthlyOffer = value);
              }),

              _buildToggleField("Set Daily Promotion?", _dailyPromo, (value) {
                setState(() => _dailyPromo = value);
              }),

              _buildDropdownField("Cancellation Policy", ['Flexible', 'Moderate']),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Save arena changes logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Arena Updated Successfully!"))
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text("Save Changes"),
              ),
            ],
          ),
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
        value: label == "Sport Offered" ? _selectedSport : _cancellationPolicy,
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
  Widget _buildMultiCheckboxField(String label, List<String> options, Map<String, bool> selectedOptions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ...options.map((option) {
          return CheckboxListTile(
            title: Text(option),
            value: selectedOptions[option] ?? false,
            onChanged: (value) {
              setState(() {
                selectedOptions[option] = value ?? false;
              });
            },
          );
        }).toList(),
      ],
    );
  }
}