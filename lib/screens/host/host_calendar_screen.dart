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
  String? _selectedArena;
  Key _calendarKey = UniqueKey();
  Set<DateTime> _countedDays = Set();

  // For filtering slots by arena
  List<Map<String, dynamic>> _bookings = [
    {
      'arena': 'Arena 1',
      'customer': 'John Doe',
      'amount': 200,
      'isHalfCourt': false,
      'date': DateTime(2025, 3, 23, 10, 0),
      'duration': 60,
      'isBlocked': false,
    },
    {
      'arena': 'Arena 1',
      'customer': 'John Doe',
      'amount': 200,
      'isHalfCourt': false,
      'date': DateTime(2025, 3, 22, 10, 0),
      'duration': 60,
      'isBlocked': false,
    },
    {
      'arena': 'Arena 2',
      'customer': 'Jane Smith',
      'amount': 150,
      'isHalfCourt': true,
      'date': DateTime(2025, 3, 22, 12, 22), // Second slot on same day
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
      'isBlocked': false,
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
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        forceMaterialTransparency: true,
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
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedArena = value;
                  _calendarKey = UniqueKey(); // Force Calendar Refresh
                });
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
      body: SfCalendar(
        key: _calendarKey,
        firstDayOfWeek: 1,
        monthViewSettings: const MonthViewSettings(
          showTrailingAndLeadingDates: false,
          appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
        ),
        view: _viewMode,
        dataSource: BookingDataSource(_getCalendarAppointments()),
        appointmentBuilder: (context, calendarAppointmentDetails) {
          if (_viewMode == CalendarView.month) {
            // Count the number of appointments for the given day
            DateTime appointmentDate = calendarAppointmentDetails.appointments.first.startTime;

            // Print and count the number of indicators being created
            int appointmentCount = _countAppointmentsForDay(appointmentDate);
            print("Appointments for ${appointmentDate.day}-${appointmentDate.month}-${appointmentDate.year}: $appointmentCount");

            // Return a small indicator if there are appointments for that day
            return Container(
              width: 10,  // Small circle for the indicator
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black, // Indicator color
              ),
            );
          } else {
            final Appointment appointment = calendarAppointmentDetails.appointments.first;
            return Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: appointment.color,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                appointment.subject,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            );
          }
        },
        timeSlotViewSettings: TimeSlotViewSettings(
          numberOfDaysInView: _visibleDays,
          startHour: 8,
          endHour: 24,
        ),
        headerStyle: const CalendarHeaderStyle(
          textAlign: TextAlign.start,
          textStyle: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          backgroundColor: Colors.white,
        ),
        onTap: (CalendarTapDetails details) {
          if (details.appointments != null && details.appointments!.isNotEmpty) {
            List<Appointment> slotsForDay = List<Appointment>.from(details.appointments!);

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

  // Count appointments for a specific day
  int _countAppointmentsForDay(DateTime date) {
    // Count appointments for the given date
    return _bookings
        .where((booking) {
      return booking['date'].year == date.year &&
          booking['date'].month == date.month &&
          booking['date'].day == date.day;
    })
        .length;  // Return the number of appointments for that day
  }

  // Convert bookings to calendar appointments
  List<Appointment> _getCalendarAppointments() {
    List<Map<String, dynamic>> filteredBookings = _selectedArena == null
        ? _bookings // Show all bookings if no filter
        : _bookings.where((b) => b['arena'] == _selectedArena).toList();

    return filteredBookings.map((booking) {
      DateTime slotTime = booking['date'];
      return Appointment(
        startTime: slotTime,
        endTime: slotTime.add(Duration(minutes: booking['duration'])),
        subject: booking['isHalfCourt'] ? "${booking['arena']} (1/2)" : booking['arena'],
        color: booking['isBlocked'] ? Colors.red : (booking['isHalfCourt'] ? Colors.blue : Colors.orange),
      );
    }).toList();
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
                    return ListTile(
                      title: Text(slot.subject),
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

  void _editSlot(Appointment appointment) {
    Map<String, dynamic>? slot = _bookings.firstWhere(
          (b) =>
      b['date'] == appointment.startTime &&
          b['arena'] == appointment.subject,
      orElse: () => {},
    );

    if (slot.isEmpty) return;

    double slotDuration = (slot['duration'] as int).toDouble();
    bool isHalfCourt = slot['isHalfCourt'];
    bool isBlocked = slot['isBlocked'];
    double slotCost = (slot['amount'] as num).toDouble();
    String arenaName = slot['arena'];

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
                height: 550,
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
                    Center(
                      child: Text(
                        "$arenaName - ${_formatDate(slot['date'])}",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text("Slot Duration", style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15,),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${slotDuration.toInt()} min",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Slider(
                      value: slotDuration,
                      min: 30.0, // Minimum duration
                      max: 60.0, // Maximum duration
                      divisions: 6, // Allows 5-minute increments
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
                    const SizedBox(height: 10),
                    Text("Slot Cost", style: const TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              if (slotCost > 0) slotCost -= 5;
                            });
                          },
                        ),
                        SizedBox(
                          width: 80,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(border: OutlineInputBorder()),
                            controller: TextEditingController(text: slotCost.toString()),
                            onChanged: (value) {
                              setState(() {
                                slotCost = double.tryParse(value) ?? slotCost;
                              });
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.green),
                          onPressed: () {
                            setState(() {
                              slotCost += 5;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text("Block Slot", style: const TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isBlocked = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isBlocked ? Colors.grey : Colors.green,
                          ),
                          child: const Text("Available"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isBlocked = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isBlocked ? Colors.red : Colors.grey,
                          ),
                          child: const Text("Blocked"),
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

  void _updateSlot(Map<String, dynamic> slot, double duration, bool halfCourt,
      bool blocked, double cost) {
    setState(() {
      slot['duration'] = duration.toInt();
      slot['isHalfCourt'] = halfCourt;
      slot['isBlocked'] = blocked;
      slot['amount'] = cost;
    });

    setState(() {});
  }

  String _formatDate(DateTime date) {
    return "${date.day}-${date.month}-${date.year}";
  }

  String _formatTime(DateTime date) {
    return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}

class BookingDataSource extends CalendarDataSource {
  BookingDataSource(List<Appointment> source) {
    appointments = source;
  }
}
