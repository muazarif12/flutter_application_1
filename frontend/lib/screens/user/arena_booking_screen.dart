import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import 'checkout_screen.dart'; // Import CheckoutScreen

class ArenaBookingScreen extends StatefulWidget {
  final Map<String, dynamic> arena;

  const ArenaBookingScreen({super.key, required this.arena});

  @override
  ArenaBookingScreenState createState() => ArenaBookingScreenState();
}

class ArenaBookingScreenState extends State<ArenaBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

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
    '6:00 PM'
  ];

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeBloc>().state;
    final bool isDarkMode = themeState is DarkThemeState;

    // Ensure system UI updates after the screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.read<ThemeBloc>().setSystemUI();
      }
    });
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: isDarkMode ? Colors.white : Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        forceMaterialTransparency: true,
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        title: Text(
          'Book ${widget.arena['name']}',
          style: TextStyle(
              fontFamily: 'Exo2',
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // **Personal Information**
              _card(
                isDarkMode: isDarkMode,
                title: 'Personal Details',
                child: Column(
                  children: [
                    _textField(
                        _nameController, 'Name', Icons.person, isDarkMode),
                    const SizedBox(height: 12),
                    _textField(
                        _contactController, 'Contact', Icons.phone, isDarkMode),
                  ],
                ),
              ),

              // **Sport Selection**
              _card(
                isDarkMode: isDarkMode,
                title: 'Sport Selection',
                child: _dropdownField(
                  isDarkMode: isDarkMode,
                  value: _selectedSport,
                  label: 'Select Sport',
                  icon: Icons.sports_soccer,
                  items: _sports,
                  onChanged: (value) {
                    setState(() {
                      _selectedSport = value;
                    });
                  },
                ),
              ),

              // **Date & Time Selection**
              _card(
                isDarkMode: isDarkMode,
                title: 'Date & Time',
                child: Column(
                  children: [
                    _datePickerField(isDarkMode),
                    const SizedBox(height: 12),
                    _dropdownField(
                      isDarkMode: isDarkMode,
                      value: _selectedSlot,
                      label: 'Select Slot',
                      icon: Icons.access_time,
                      items: _availableSlots,
                      onChanged: (value) {
                        setState(() {
                          _selectedSlot = value;
                        });
                      },
                    ),
                  ],
                ),
              ),

              // **Team & Court Preferences**
              _card(
                isDarkMode: isDarkMode,
                title: 'Game Preferences',
                child: Column(
                  children: [
                    _dropdownField(
                      isDarkMode: isDarkMode,
                      value: _teamSize,
                      label: 'Team Size',
                      icon: Icons.groups,
                      items:
                          List.generate(10, (index) => (index + 1).toString()),
                      onChanged: (value) {
                        setState(() {
                          _teamSize = int.tryParse(value!);
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    _toggleSwitch(
                      isDarkMode: isDarkMode,
                      label: 'Court Type',
                      value: _isHalfCourt,
                      onChanged: (value) {
                        setState(() {
                          _isHalfCourt = value;
                        });
                      },
                      activeText: 'Half Court',
                      inactiveText: 'Full Court',
                    ),
                  ],
                ),
              ),

              // **Teammate Request Checkbox**
              _card(
                isDarkMode: isDarkMode,
                title: 'Additional Preferences',
                child: CheckboxListTile(
                  activeColor: Colors.green,
                  title: Text('Send request for teammates',
                      style: TextStyle(
                          fontFamily: 'Exo2',
                          color: isDarkMode ? Colors.white : Colors.black)),
                  value: _sendTeammateRequest,
                  onChanged: (value) {
                    setState(() {
                      _sendTeammateRequest = value ?? false;
                    });
                  },
                ),
              ),

              const SizedBox(height: 20),

              // **Book Now Button**
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle),
                  label: const Text(
                    'Book Now',
                    style: TextStyle(
                      fontFamily: 'Exo2',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _confirmBooking(context);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // **Reusable Card Wrapper**
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
                    fontFamily: 'Exo2',
                    color: isDarkMode ? Colors.white : Colors.black)),
            const Divider(),
            child,
          ],
        ),
      ),
    );
  }

  Widget _toggleSwitch(
      {required String label,
      required bool value,
      required Function(bool) onChanged,
      required String activeText,
      required String inactiveText,
      required bool isDarkMode}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontFamily: 'Exo2',
                color: isDarkMode ? Colors.white : Colors.black)),
        Row(
          children: [
            Text(value ? activeText : inactiveText,
                style: TextStyle(
                    fontFamily: 'Exo2',
                    color: isDarkMode ? Colors.white : Colors.black)),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.green,
            ),
          ],
        ),
      ],
    );
  }

  // **Reusable Text Field**
  Widget _textField(TextEditingController controller, String label,
      IconData icon, bool isDarkMode) {
    return TextFormField(
      controller: controller,
      style: TextStyle(
          fontFamily: 'Exo2', color: isDarkMode ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
            fontFamily: 'Exo2',
            color: isDarkMode ? Colors.white : Colors.black),
        prefixIcon: Icon(
          icon,
          color: Colors.green,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Please enter $label' : null,
    );
  }

  // **Reusable Dropdown Field**
  Widget _dropdownField<T>({
    required T? value,
    required String label,
    required IconData icon,
    required List<String> items,
    required Function(String?) onChanged,
    required bool isDarkMode,
  }) {
    return DropdownButtonFormField<String>(
      dropdownColor: isDarkMode ? Colors.black : Colors.white,
      style: TextStyle(
          fontFamily: 'Exo2', color: isDarkMode ? Colors.white : Colors.black),
      value: value?.toString(),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
            fontFamily: 'Exo2',
            color: isDarkMode ? Colors.white : Colors.black),
        prefixIcon: Icon(
          icon,
          color: Colors.green,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
      validator: (value) =>
          value == null || value.isEmpty ? 'Please select $label' : null,
    );
  }

  // **Date Picker Field**
  Widget _datePickerField(bool isDarkMode) {
    return TextFormField(
      style: TextStyle(
          fontFamily: 'Exo2', color: isDarkMode ? Colors.white : Colors.black),
      controller: _dateController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Select Date',
        labelStyle: TextStyle(
            fontFamily: 'Exo2',
            color: isDarkMode ? Colors.white : Colors.black),
        prefixIcon: Icon(
          Icons.calendar_today,
          color: Colors.green,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (pickedDate != null) {
          setState(() {
            _selectedDate = pickedDate;
            _dateController.text =
                pickedDate.toLocal().toString().split(' ')[0];
          });
        }
      },
      validator: (value) =>
          _selectedDate == null ? 'Please select a date' : null,
    );
  }

  // **Booking Confirmation**
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
