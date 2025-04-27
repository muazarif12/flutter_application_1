import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class HostCalendarScreen extends StatefulWidget {
  const HostCalendarScreen({super.key});

  @override
  HostCalendarScreenState createState() => HostCalendarScreenState();
}

class BookingDataSource extends CalendarDataSource {
  BookingDataSource(List<Appointment> source) {
    appointments = source;
  }
}

class HostCalendarScreenState extends State<HostCalendarScreen> {
  CalendarView _viewMode = CalendarView.month;
  int _visibleDays = 7;
  late String _selectedArena; // Using late keyword to initialize in initState
  Key _calendarKey = UniqueKey();
  Set<DateTime> _countedDays = Set();
  // Track stats for display
  int _availableCount = 0;
  int _blockedCount = 0;

  // For filtering slots by arena
  List<Map<String, dynamic>> _bookings = [
    {
      'arena': 'Arena 1',
      'customer': 'John Doe',
      'amount': 200,
      'isHalfCourt': false,
      'date': DateTime(2025, 4, 23, 10, 0),
      'duration': 60,
      'isBlocked': false,
    },
    {
      'arena': 'Arena 1',
      'customer': 'John Doe',
      'amount': 200,
      'isHalfCourt': false,
      'date': DateTime(2025, 4, 22, 10, 0),
      'duration': 60,
      'isBlocked': false,
    },
    {
      'arena': 'Arena 2',
      'customer': 'Jane Smith',
      'amount': 150,
      'isHalfCourt': true,
      'date': DateTime(2025, 4, 22, 12, 22), // Second slot on same day
      'duration': 60,
      'isBlocked': true, // This one is blocked
    },
    {
      'arena': 'Arena 2',
      'customer': 'Smith',
      'amount': 150,
      'isHalfCourt': true,
      'date': DateTime(2025, 4, 22, 12, 22), // Second slot on same day
      'duration': 60,
      'isBlocked': false,
    },
    {
      'arena': 'Arena 2',
      'customer': 'Alex',
      'amount': 300,
      'isHalfCourt': false,
      'date': DateTime(2025, 3, 24, 18, 25),
      'duration': 60,
      'isBlocked': true, // This one is blocked
    },
    {
      'arena': 'Arena 2',
      'customer': 'Alice Johnson',
      'amount': 300,
      'isHalfCourt': false,
      'date': DateTime(2025, 3, 24, 18, 0),
      'duration': 60,
      'isBlocked': false,
    },
    // Adding more blocked slots
    {
      'arena': 'Arena 1',
      'customer': 'BLOCKED',
      'amount': 0,
      'isHalfCourt': false,
      'date': DateTime(2025, 4, 24, 14, 0), // April 24th, 2025 at 2:00 PM
      'duration': 120, // 2-hour block
      'isBlocked': true,
    },
    {
      'arena': 'Arena 1',
      'customer': 'BLOCKED',
      'amount': 0,
      'isHalfCourt': false,
      'date': DateTime(2025, 4, 25, 9, 0), // April 25th, 2025 at 9:00 AM
      'duration': 60,
      'isBlocked': true,
    },
    {
      'arena': 'Arena 3',
      'customer': 'BLOCKED',
      'amount': 0,
      'isHalfCourt': true,
      'date': DateTime(2025, 4, 26, 16, 30), // April 26th, 2025 at 4:30 PM
      'duration': 90, // 1.5-hour block
      'isBlocked': true,
    },
    {
      'arena': 'Arena 2',
      'customer': 'BLOCKED',
      'amount': 0,
      'isHalfCourt': false,
      'date': DateTime(2025, 4, 27, 20, 0), // April 27th, 2025 at 8:00 PM
      'duration': 120, // 2-hour block
      'isBlocked': true,
    },
    {
      'arena': 'Arena 3',
      'customer': 'BLOCKED',
      'amount': 0,
      'isHalfCourt': false,
      'date': DateTime(2025, 5, 1, 12, 0), // May 1st, 2025 at 12:00 PM
      'duration': 180, // 3-hour block (maintenance)
      'isBlocked': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Set the default selected arena to the first one in the list
    _selectedArena = _getUniqueArenas().first;
    _updateCounts(); // Initialize counts
  }

  // Helper method to get unique arena names
  List<String> _getUniqueArenas() {
    return _bookings.map((b) => b['arena'] as String).toSet().toList();
  }

  // Update available and blocked counts
  void _updateCounts() {
    List<Map<String, dynamic>> filteredBookings =
        _bookings.where((b) => b['arena'] == _selectedArena).toList();

    _blockedCount = filteredBookings.where((b) => b['isBlocked']).length;
    _availableCount = filteredBookings.length - _blockedCount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        forceMaterialTransparency: true,
        title: Text("Arena Calendar",
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          // Dropdown for selecting different arenas - now always requires a selection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DropdownButton<String>(
              value: _selectedArena,
              hint: const Text("Select Arena"),
              items: _getUniqueArenas().map((arena) {
                return DropdownMenuItem(value: arena, child: Text(arena));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedArena = value;
                    _calendarKey = UniqueKey(); // Force Calendar Refresh
                    _updateCounts(); // Update counts when arena changes
                  });
                }
              },
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                if (value == "Month") {
                  _viewMode = CalendarView.month;
                  _visibleDays = 7; // Reset custom views
                } else if (value == "Day") {
                  _viewMode = CalendarView.day;
                  _visibleDays = 1;
                } else if (value == "3-day") {
                  _viewMode = CalendarView.week;
                  _visibleDays = 3;
                } else if (value == "5-day") {
                  _viewMode = CalendarView.week;
                  _visibleDays = 5;
                } else if (value == "Week") {
                  _viewMode = CalendarView.week;
                  _visibleDays = 7;
                }
                _calendarKey = UniqueKey();
              });
            },
            icon: Icon(Icons.more_vert, color: Colors.green[900]),
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: "Day", child: Text("Day View")),
              const PopupMenuItem(value: "3-day", child: Text("3-Day View")),
              const PopupMenuItem(value: "5-day", child: Text("5-Day View")),
              const PopupMenuItem(value: "Week", child: Text("Week View")),
              const PopupMenuItem(value: "Month", child: Text("Month View")),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Status indicator
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _statusIndicator(Colors.green, _availableCount, "Available"),
                const SizedBox(width: 24),
                _statusIndicator(Colors.red, _blockedCount, "Blocked"),
              ],
            ),
          ),

          // Calendar
          Expanded(
            child: SfCalendar(
              key: _calendarKey,
              firstDayOfWeek: 1,
              monthViewSettings: const MonthViewSettings(
                showTrailingAndLeadingDates: false,
                appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
              ),
              view: _viewMode,
              dataSource: BookingDataSource(_getCalendarAppointments()),
              appointmentBuilder: appointmentBuilder,
              timeSlotViewSettings: TimeSlotViewSettings(
                numberOfDaysInView: _visibleDays,
                startHour: 8,
                endHour: 24,
              ),
              headerStyle: const CalendarHeaderStyle(
                textAlign: TextAlign.start,
                textStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                backgroundColor: Colors.white,
              ),
              onTap: (CalendarTapDetails details) {
                if (details.appointments != null &&
                    details.appointments!.isNotEmpty) {
                  List<Appointment> slotsForDay =
                      List<Appointment>.from(details.appointments!);

                  if (slotsForDay.length == 1) {
                    _editSlot(slotsForDay.first);
                  } else {
                    _showSlotSelection(slotsForDay);
                  }
                } else if (details.targetElement ==
                    CalendarElement.calendarCell) {
                  // Add new slot when tapping on empty cell
                  _addNewSlot(details.date!);
                }
              },
            ),
          ),

          // Legend
          _buildLegend(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add a new slot for the current date
          _addNewSlot(DateTime.now());
        },
        backgroundColor: Colors.green,
        child: Icon(Icons.add),
        tooltip: 'Add New Slot',
      ),
    );
  }

  // Add a new slot
  void _addNewSlot(DateTime date) {
    // Round to nearest hour
    final roundedDate = DateTime(
      date.year,
      date.month,
      date.day,
      date.hour,
      0,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setState) {
              double slotDuration = 60;
              bool isHalfCourt = false;
              bool isBlocked = false;
              double slotCost = 200;
              String customerName = '';

              return Container(
                padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        "Add New Slot - $_selectedArena",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        "${_formatDate(roundedDate)} | ${_formatTime(roundedDate)}",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text("Customer Details",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        labelText: "Customer Name",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      onChanged: (value) {
                        customerName = value;
                      },
                      enabled: !isBlocked,
                    ),
                    const SizedBox(height: 16),
                    Text("Slot Duration",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${slotDuration.toInt()} min",
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Slider(
                      value: slotDuration,
                      min: 30.0, // Minimum duration
                      max: 120.0, // Maximum duration
                      divisions: 6, // Allows 15-minute increments
                      onChanged: (value) {
                        setState(() {
                          slotDuration = value; // Update slot duration
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      title: const Text("Half Court Booking"),
                      value: isHalfCourt,
                      activeColor: Colors.blue,
                      onChanged: (value) {
                        setState(() {
                          isHalfCourt = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Text("Slot Cost",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle,
                              color: Colors.red),
                          onPressed: () {
                            setState(() {
                              if (slotCost > 0) slotCost -= 10;
                            });
                          },
                        ),
                        SizedBox(
                          width: 80,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder()),
                            controller: TextEditingController(
                                text: slotCost.toString()),
                            onChanged: (value) {
                              setState(() {
                                slotCost = double.tryParse(value) ?? slotCost;
                              });
                            },
                          ),
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.add_circle, color: Colors.green),
                          onPressed: () {
                            setState(() {
                              slotCost += 10;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text("Block Slot",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              isBlocked = false;
                            });
                          },
                          icon: Icon(Icons.check_circle),
                          label: const Text("Available"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isBlocked ? Colors.grey : Colors.green,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              isBlocked = true;
                              customerName =
                                  'BLOCKED'; // Clear customer name if blocked
                            });
                          },
                          icon: Icon(Icons.block),
                          label: const Text("Blocked"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isBlocked ? Colors.red : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(LucideIcons.x),
                          label: const Text("Cancel"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Create and add new slot
                            _createNewSlot(
                                roundedDate,
                                slotDuration.toInt(),
                                isHalfCourt,
                                isBlocked,
                                slotCost,
                                customerName.isEmpty
                                    ? (isBlocked ? 'BLOCKED' : 'Guest')
                                    : customerName);
                            Navigator.pop(context);
                          },
                          icon: const Icon(LucideIcons.check),
                          label: const Text("Save"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Create a new slot
  void _createNewSlot(DateTime date, int duration, bool halfCourt, bool blocked,
      double cost, String customerName) {
    setState(() {
      // Add the new slot to bookings
      _bookings.add({
        'arena': _selectedArena,
        'customer': customerName,
        'amount': cost,
        'isHalfCourt': halfCourt,
        'date': date,
        'duration': duration,
        'isBlocked': blocked,
      });

      // Force calendar refresh and update counts
      _calendarKey = UniqueKey();
      _updateCounts();

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('New slot added successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  // Status indicator widget
  Widget _statusIndicator(Color color, int count, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          "$label: $count",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Legend widget
  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _legendItem(Colors.green.shade400, Icons.check_circle, "Available"),
          _legendItem(Colors.red.shade300, Icons.block, "Blocked"),
          _legendItem(Colors.blue.shade400, Icons.grid_view, "Half Court"),
        ],
      ),
    );
  }

  // Legend item
  Widget _legendItem(Color color, IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  // Appointment builder
  Widget appointmentBuilder(BuildContext context,
      CalendarAppointmentDetails calendarAppointmentDetails) {
    if (_viewMode == CalendarView.month) {
      // Month view indicator logic
      DateTime appointmentDate =
          calendarAppointmentDetails.appointments.first.startTime;

      // Get slots for this day
      List<Map<String, dynamic>> slotsForDay = _bookings.where((booking) {
        return booking['date'].year == appointmentDate.year &&
            booking['date'].month == appointmentDate.month &&
            booking['date'].day == appointmentDate.day &&
            booking['arena'] == _selectedArena;
      }).toList();

      int blockedCount = slotsForDay.where((s) => s['isBlocked']).length;
      int availableCount = slotsForDay.length - blockedCount;

      return Container(
        padding: const EdgeInsets.all(2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (availableCount > 0)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                ),
              ),
            if (blockedCount > 0)
              Container(
                width: 8,
                height: 8,
                margin: EdgeInsets.only(top: availableCount > 0 ? 2 : 0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
              ),
          ],
        ),
      );
    } else {
      // For Week/Day/Timeline views
      final Appointment appointment =
          calendarAppointmentDetails.appointments.first;
      final bool isBlocked = appointment.notes == "blocked";
      final bool isHalfCourt = appointment.subject.contains("(1/2)");

      // Check if there are overlapping half-court bookings
      final List<Appointment> overlappingAppointments =
          _getOverlappingAppointments(appointment);

      if (isHalfCourt && overlappingAppointments.length >= 2) {
        // Two half-court bookings at the same time → split the cell
        return Row(
          children: [
            Expanded(
              child: _buildCustomAppointment(overlappingAppointments[0],
                  isLeft: true),
            ),
            Expanded(
              child: _buildCustomAppointment(overlappingAppointments[1],
                  isLeft: false),
            ),
          ],
        );
      } else {
        // Full-court booking or single half-court
        return _buildCustomAppointment(appointment, isLeft: isHalfCourt);
      }
    }
  }

  // Build custom appointment widget
  Widget _buildCustomAppointment(Appointment appointment,
      {required bool isLeft}) {
    final bool isBlocked = appointment.notes == "blocked";

    return Container(
      margin: EdgeInsets.only(right: isLeft ? 2 : 0, left: isLeft ? 0 : 2),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: appointment.color,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isBlocked ? Colors.red.shade700 : Colors.green.shade700,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isBlocked ? Icons.block : Icons.check_circle,
                color: Colors.white,
                size: 12,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  appointment.subject
                      .split(' ')
                      .take(2)
                      .join(' '), // Just show arena name and court type
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            isBlocked ? "BLOCKED" : "AVAILABLE",
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (!isBlocked && appointment.subject.contains('-'))
            Text(
              appointment.subject.split('-').last.trim(), // Show customer name
              style: const TextStyle(color: Colors.white70, fontSize: 10),
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  // Get calendar appointments
  List<Appointment> _getCalendarAppointments() {
    // Always filter bookings by the selected arena
    List<Map<String, dynamic>> filteredBookings =
        _bookings.where((b) => b['arena'] == _selectedArena).toList();

    return filteredBookings.map((booking) {
      DateTime slotTime = booking['date'];
      // Create more descriptive subject based on booking status
      String status = booking['isBlocked'] ? "BLOCKED" : "AVAILABLE";
      String courtType =
          booking['isHalfCourt'] ? "(1/2 Court)" : "(Full Court)";
      String customer = booking['isBlocked'] ? "" : " - ${booking['customer']}";

      return Appointment(
        startTime: slotTime,
        endTime: slotTime.add(Duration(minutes: booking['duration'])),
        subject: "${booking['arena']} $courtType $status$customer",
        color: booking['isBlocked']
            ? Colors.red.shade300 // Lighter red for blocked
            : (booking['isHalfCourt']
                ? Colors.blue.shade400
                : Colors.green.shade400),
        notes: booking['isBlocked']
            ? "blocked"
            : "available", // Use notes field to track status
      );
    }).toList();
  }

  // Get overlapping appointments (for the same time slot)
  List<Appointment> _getOverlappingAppointments(Appointment appointment) {
    return _getCalendarAppointments().where((a) {
      return a.startTime == appointment.startTime &&
          a.endTime == appointment.endTime &&
          a.subject.contains("(1/2)");
    }).toList();
  }

  // Count appointments for a specific day
  int _countAppointmentsForDay(DateTime date) {
    // Count appointments for the given date and the selected arena only
    return _bookings.where((booking) {
      return booking['date'].year == date.year &&
          booking['date'].month == date.month &&
          booking['date'].day == date.day &&
          booking['arena'] == _selectedArena;
    }).length; // Return the number of appointments for that day
  }

  void _showSlotSelection(List<Appointment> slots) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text("Select Slot to Edit",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: slots.length,
                  itemBuilder: (context, index) {
                    final slot = slots[index];
                    final bool isBlocked = slot.notes == "blocked";

                    return ListTile(
                      leading: Icon(
                        isBlocked ? Icons.block : Icons.check_circle,
                        color: isBlocked ? Colors.red : Colors.green,
                      ),
                      title: Row(
                        children: [
                          Text(slot.subject.split(' ').take(2).join(' ')),
                          const SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isBlocked
                                  ? Colors.red.shade100
                                  : Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isBlocked ? "BLOCKED" : "AVAILABLE",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isBlocked
                                    ? Colors.red.shade900
                                    : Colors.green.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                          "${_formatDate(slot.startTime)} | ${_formatTime(slot.startTime)} - ${_formatTime(slot.endTime)}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              Navigator.pop(context);
                              _editSlot(slot);
                            },
                          ),
                          // IconButton(
                          //   icon: Icon(Icons.delete, color: Colors.red),
                          //   onPressed: () {
                          //     Navigator.pop(context);
                          //     _deleteSlot(slot);
                          //   },
                          // ),
                        ],
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _editSlot(slot);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Format a date to display as day-month-year
  String _formatDate(DateTime date) {
    return "${date.day}-${date.month}-${date.year}";
  }

// Format a time to display as hour:minute
  String _formatTime(DateTime date) {
    return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  void _editSlot(Appointment appointment) {
    // Extract the arena name from the appointment subject
    // For half-court bookings, remove the (1/2) suffix
    String appointmentArenaName = appointment.subject.split(' ').first;

    // Find the matching booking from the _bookings list
    Map<String, dynamic>? slot = _bookings.firstWhere(
      (b) =>
          b['date'].year == appointment.startTime.year &&
          b['date'].month == appointment.startTime.month &&
          b['date'].day == appointment.startTime.day &&
          b['date'].hour == appointment.startTime.hour &&
          b['date'].minute == appointment.startTime.minute &&
          b['arena'] == appointmentArenaName,
      orElse: () => {},
    );

    // If the slot is found, show the edit dialog
    if (slot.isNotEmpty) {
      _showEditDialog(slot);
    }
  }

  // Show edit dialog for a slot
  void _showEditDialog(Map<String, dynamic> slot) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            double slotDuration = slot['duration'].toDouble();
            bool isHalfCourt = slot['isHalfCourt'];
            bool isBlocked = slot['isBlocked'];
            double slotCost = slot['amount'].toDouble();
            String customerName = slot['customer'];
            DateTime slotDate = slot['date'];

            return SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        "Edit Slot - ${slot['arena']}",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        "${_formatDate(slotDate)} | ${_formatTime(slotDate)}",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text("Customer Details",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        labelText: "Customer Name",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      controller: TextEditingController(text: customerName),
                      onChanged: (value) {
                        customerName = value;
                      },
                      enabled: !isBlocked,
                    ),
                    const SizedBox(height: 16),
                    Text("Slot Duration",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isBlocked ? Colors.red : Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${slotDuration.toInt()} min",
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Slider(
                      value: slotDuration,
                      min: 30.0,
                      max: 180.0, // Allow longer durations (up to 3 hours)
                      divisions: 10,
                      onChanged: (value) {
                        setState(() {
                          slotDuration = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      title: const Text("Half Court Booking"),
                      value: isHalfCourt,
                      activeColor: Colors.blue,
                      onChanged: (value) {
                        setState(() {
                          isHalfCourt = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Text("Slot Cost",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle,
                              color: Colors.red),
                          onPressed: () {
                            setState(() {
                              if (slotCost > 0) slotCost -= 10;
                            });
                          },
                        ),
                        SizedBox(
                          width: 80,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder()),
                            controller: TextEditingController(
                                text: slotCost.toString()),
                            onChanged: (value) {
                              setState(() {
                                slotCost = double.tryParse(value) ?? slotCost;
                              });
                            },
                          ),
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.add_circle, color: Colors.green),
                          onPressed: () {
                            setState(() {
                              slotCost += 10;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text("Block Slot",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              isBlocked = false;
                            });
                          },
                          icon: Icon(Icons.check_circle),
                          label: const Text("Available"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isBlocked ? Colors.grey : Colors.green,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              isBlocked = true;
                              if (customerName != 'BLOCKED') {
                                customerName = 'BLOCKED';
                              }
                            });
                          },
                          icon: Icon(Icons.block),
                          label: const Text("Blocked"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isBlocked ? Colors.red : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(LucideIcons.x),
                          label: const Text("Cancel"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Update the slot with new values
                            _updateSlot(slot, slotDuration.toInt(), isHalfCourt,
                                isBlocked, slotCost, customerName);
                            Navigator.pop(context);
                          },
                          icon: const Icon(LucideIcons.check),
                          label: const Text("Save"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Update a slot with new values
  void _updateSlot(Map<String, dynamic> slot, int duration, bool halfCourt,
      bool blocked, double cost, String customerName) {
    setState(() {
      // Update the slot properties
      slot['duration'] = duration;
      slot['isHalfCourt'] = halfCourt;
      slot['isBlocked'] = blocked;
      slot['amount'] = cost;
      slot['customer'] = customerName;

      // Force calendar refresh and update counts
      _calendarKey = UniqueKey();
      _updateCounts();

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Slot updated successfully'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
    });
  }
}
