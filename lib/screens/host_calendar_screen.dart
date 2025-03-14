import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class HostCalendarScreen extends StatefulWidget {
  const HostCalendarScreen({super.key});

  @override
  HostCalendarScreenState createState() => HostCalendarScreenState();
}

class HostCalendarScreenState extends State<HostCalendarScreen> {
  CalendarView _viewMode = CalendarView.month;
  int _visibleDays = 7;
  String? _selectedArena; // For filtering slots by arena

  List<Map<String, dynamic>> _bookings = [
    {
      'arena': 'Arena 1',
      'customer': 'John Doe',
      'amount': 200,
      'isHalfCourt': false,
      'date': DateTime(2025, 3, 11, 10, 0),
      'duration': 60,
      'isBlocked': false,
    },
    {
      'arena': 'Arena 1',
      'customer': 'Jane Smith',
      'amount': 150,
      'isHalfCourt': true,
      'date': DateTime(2025, 3, 11, 12, 0), // Second slot on same day
      'duration': 60,
      'isBlocked': false,
    },
    {
      'arena': 'Arena 2',
      'customer': 'Alice Johnson',
      'amount': 300,
      'isHalfCourt': false,
      'date': DateTime(2025, 3, 12, 18, 0),
      'duration': 60,
      'isBlocked': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Host Calendar"),
        centerTitle: true,
        actions: [
          // Dropdown for selecting different arenas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DropdownButton<String>(
              value: _selectedArena,
              hint: const Text("Filter by Arena"),
              items: [
                const DropdownMenuItem(value: null, child: Text("All Arenas")),
                ..._bookings
                    .map((b) => b['arena'] as String)
                    .toSet()
                    .map((arena) {
                  return DropdownMenuItem(value: arena, child: Text(arena));
                }).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedArena = value;
                });
              },
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                if (value == "3-day") {
                  _viewMode = CalendarView.week;
                  _visibleDays = 3;
                } else if (value == "5-day") {
                  _viewMode = CalendarView.week;
                  _visibleDays = 5;
                } else if (value == "Week") {
                  _viewMode = CalendarView.week;
                  _visibleDays = 7;
                } else if (value == "Day") {
                  _viewMode = CalendarView.day;
                  _visibleDays = 1;
                } else {
                  _viewMode = CalendarView.month;
                }
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
      body: SfCalendar(
        firstDayOfWeek: 1,
        monthViewSettings: const MonthViewSettings(
          showTrailingAndLeadingDates: false,
          appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
        ),
        view: _viewMode,
        allowedViews: const [
          CalendarView.day,
          CalendarView.week,
          CalendarView.month
        ],
        dataSource: BookingDataSource(_getCalendarAppointments()),
        timeSlotViewSettings: TimeSlotViewSettings(
          numberOfDaysInView: _visibleDays,
          startHour: 8,
          endHour: 22,
        ),
        headerStyle: const CalendarHeaderStyle(
          textAlign: TextAlign.start,
          textStyle: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
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
          }
        },
      ),
    );
  }

  // Convert bookings to calendar appointments
  List<Appointment> _getCalendarAppointments() {
    return _bookings.map((booking) {
      return Appointment(
        startTime: booking['date'],
        endTime: booking['date'].add(Duration(minutes: booking['duration'])),
        subject: booking['arena'], // Now stores the arena name
        color: booking['isBlocked']
            ? Colors.red
            : (booking['isHalfCourt'] ? Colors.blue : Colors.orange),
        notes: "${booking['customer']} - \$${booking['amount']}",
      );
    }).toList();
  }

  // Show slot selection if multiple exist
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
                    return ListTile(
                      title: Text("${slot.subject}"),
                      subtitle: Text(
                          "${_formatDate(slot.startTime)} | ${_formatTime(slot.startTime)} - ${_formatTime(slot.endTime)}"),
                      trailing: const Icon(Icons.edit, color: Colors.green),
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

  // Edit a slot
  void _editSlot(Appointment appointment) {
    // Find the correct booking using BOTH start time and arena
    Map<String, dynamic>? slot = _bookings.firstWhere(
      (b) =>
          b['date'] == appointment.startTime &&
          b['arena'] == appointment.subject,
      orElse: () => {},
    );

    // Ensure slot is not empty before opening modal
    if (slot.isEmpty) return;

    double slotDuration = (slot['duration'] as int).toDouble();
    bool isHalfCourt = slot['isHalfCourt'];
    bool isBlocked = slot['isBlocked'];
    double slotCost = (slot['amount'] as num).toDouble();
    String arenaName = slot['arena']; // Get arena name

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                padding: const EdgeInsets.all(20),
                height: 500,
                child: Column(
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

                    // Display Arena Name
                    Center(
                      child: Text(
                        "$arenaName - ${_formatDate(slot['date'])}",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Slot Duration (Read-Only)
                    Text("Slot Duration (Cannot be Increased)",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Slider(
                      value: slotDuration,
                      min: 30.0, // Set minimum allowed duration
                      max: 120.0, // Increase max limit if required
                      divisions:
                          18, // Allows 5-minute increments (from 30 to 120 min)
                      label: "${slotDuration.toInt()} min",
                      onChanged: (value) {
                        setState(() {
                          slotDuration = value; // Update slot duration
                        });
                      },
                    ),

                    // Half Court Toggle
                    SwitchListTile(
                      title: const Text("Half Court Booking"),
                      value: isHalfCourt,
                      onChanged: (value) {
                        setState(() {
                          isHalfCourt = value;
                        });
                      },
                    ),

                    if (isHalfCourt)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(8)),
                        child: const Text(
                            "Half of this slot is still available for booking."),
                      ),

                    // Block Slot Toggle
                    SwitchListTile(
                      title: const Text("Block Slot (Maintenance, etc.)"),
                      value: isBlocked,
                      onChanged: (value) {
                        setState(() {
                          isBlocked = value;
                        });
                      },
                    ),

                    // Slot Cost Input
                    Text("Slot Cost",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        const Icon(LucideIcons.dollarSign, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: "Enter slot cost",
                            ),
                            onChanged: (value) {
                              setState(() {
                                slotCost = double.tryParse(value) ?? slotCost;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Save & Close Buttons
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
                            _updateSlot(slot, slotDuration, isHalfCourt,
                                isBlocked, slotCost);
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

// Update Slot Data in Calendar
  void _updateSlot(Map<String, dynamic> slot, double duration, bool halfCourt,
      bool blocked, double cost) {
    setState(() {
      slot['duration'] = duration.toInt(); // ✅ Save edited duration
      slot['isHalfCourt'] = halfCourt;
      slot['isBlocked'] = blocked;
      slot['amount'] = cost;
    });

    // Refresh the calendar after updating the slot
    setState(() {});
  }

  String _formatDate(DateTime date) {
    return "${date.day}-${date.month}-${date.year}";
  }

  String _formatTime(DateTime date) {
    return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}

// Custom Data Source for Syncfusion Calendar
class BookingDataSource extends CalendarDataSource {
  BookingDataSource(List<Appointment> source) {
    appointments = source;
  }
}
