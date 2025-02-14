import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'checkout_screen.dart'; // Import the CheckoutScreen

class ArenaBookingScreen extends StatefulWidget {
  final Map<String, dynamic> arena;

  const ArenaBookingScreen({super.key, required this.arena});

  @override
  _ArenaBookingScreenState createState() => _ArenaBookingScreenState();
}

class _ArenaBookingScreenState extends State<ArenaBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _dateController = TextEditingController(); // Controller for date
  String? _selectedSport;
  DateTime? _selectedDate;
  String? _selectedSlot;
  int? _teamSize;
  bool _isHalfCourt = false;
  bool _sendTeammateRequest = false;

  // Dummy data for sports and slots
  final List<String> _sports = ['Cricket', 'Football', 'Tennis'];
  final List<String> _availableSlots = [
    '10:00 AM',
    '12:00 PM',
    '2:00 PM',
    '4:00 PM',
    '6:00 PM',
  ]; // Hard-coded slots

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Book ${widget.arena['name']}',
          style: GoogleFonts.exo2(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name Input
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Contact Input
              TextFormField(
                controller: _contactController,
                decoration: InputDecoration(
                  labelText: 'Contact',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your contact information';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Sport Selection (if multiple sports are offered)
              if (_sports.length > 1)
                FormField<String>(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a sport';
                    }
                    return null;
                  },
                  builder: (FormFieldState<String> state) {
                    return DropdownButtonFormField<String>(
                      value: _selectedSport,
                      decoration: InputDecoration(
                        labelText: 'Select Sport',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        errorText: state.errorText,
                      ),
                      items: _sports.map((String sport) {
                        return DropdownMenuItem<String>(
                          value: sport,
                          child: Text(sport),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedSport = value;
                        });
                        state.didChange(value);
                      },
                    );
                  },
                ),
              const SizedBox(height: 20),

              // Date Picker
              TextFormField(
                controller: _dateController, // Add controller
                decoration: InputDecoration(
                  labelText: 'Select Date',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = pickedDate;
                      // Update the TextFormField value
                      _dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
                    });
                  }
                },
                validator: (value) {
                  if (_selectedDate == null) {
                    return 'Please select a date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Slot Selection (Dropdown with hard-coded slots)
              FormField<String>(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a slot';
                  }
                  return null;
                },
                builder: (FormFieldState<String> state) {
                  return DropdownButtonFormField<String>(
                    value: _selectedSlot,
                    decoration: InputDecoration(
                      labelText: 'Select Slot',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      errorText: state.errorText,
                    ),
                    items: _availableSlots.map((String slot) {
                      return DropdownMenuItem<String>(
                        value: slot,
                        child: Text(slot),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedSlot = value;
                      });
                      state.didChange(value);
                    },
                  );
                },
              ),
              const SizedBox(height: 20),

              // Team Size Dropdown
              FormField<int>(
                validator: (value) {
                  if (value == null) {
                    return 'Please select team size';
                  }
                  return null;
                },
                builder: (FormFieldState<int> state) {
                  return DropdownButtonFormField<int>(
                    value: _teamSize,
                    decoration: InputDecoration(
                      labelText: 'Team Size',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      errorText: state.errorText,
                    ),
                    items: List.generate(10, (index) => index + 1).map((int size) {
                      return DropdownMenuItem<int>(
                        value: size,
                        child: Text('$size'),
                      );
                    }).toList(),
                    onChanged: (int? value) {
                      setState(() {
                        _teamSize = value;
                      });
                      state.didChange(value);
                    },
                  );
                },
              ),
              const SizedBox(height: 20),

              // Court Type Toggle
              Row(
                children: [
                  const Text('Court Type:'),
                  const SizedBox(width: 10),
                  Switch(
                    value: _isHalfCourt,
                    onChanged: (value) {
                      setState(() {
                        _isHalfCourt = value;
                      });
                    },
                  ),
                  Text(_isHalfCourt ? 'Half Court' : 'Full Court'),
                ],
              ),
              const SizedBox(height: 20),

              // Teammate Request Checkbox
              CheckboxListTile(
                title: const Text('Send request for teammates'),
                value: _sendTeammateRequest,
                onChanged: (value) {
                  setState(() {
                    _sendTeammateRequest = value ?? false;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Book Now Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Handle booking logic
                    _confirmBooking(context);
                  }
                },
                child: const Text('Book Now'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to confirm booking
  void _confirmBooking(BuildContext context) {
    // Prepare booking details
    final bookingDetails = {
      'arenaName': widget.arena['name'],
      'sport': _selectedSport,
      'date': _selectedDate?.toLocal().toString().split(' ')[0],
      'slot': _selectedSlot,
      'teamSize': _teamSize,
      'isHalfCourt': _isHalfCourt,
    };

    // Navigate to CheckoutScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          bookingDetails: bookingDetails,
          onBookingConfirmed: (bookingDetails) {
            // Handle the confirmed booking (e.g., save to a list or database)
            print('Booking confirmed: $bookingDetails');
          },
        ),
      ),
    );
  }
}