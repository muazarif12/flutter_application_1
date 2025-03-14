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

  // List of arenas
  List<String> _arenas = ["Arena 1", "Arena 2", "Arena 3"];
  String _selectedArena = "Arena 1";

  // Bookings per arena
  Map<String, List<Map<String, dynamic>>> _bookingsByArena = {
    "Arena 1": [
      {
        'sport': 'Football',
        'customer': 'John Doe',
        'amount': 200,
        'isHalfCourt': false,
        'date': DateTime(2025, 3, 15, 10, 0),
        'duration': 60,
        'isBlocked': false
      },
      {
        'sport': 'Tennis',
        'customer': 'Alice Brown',
        'amount': 150,
        'isHalfCourt': true,
        'date': DateTime(2025, 3, 15, 12, 0),
        'duration': 60,
        'isBlocked': false
      },
      {
        'sport': 'Cricket',
        'customer': 'Mark Wilson',
        'amount': 300,
        'isHalfCourt': false,
        'date': DateTime(2025, 3, 15, 14, 0),
        'duration': 120,
        'isBlocked': false
      },
    ],
    "Arena 2": [
      {
        'sport': 'Basketball',
        'customer': 'Emma Davis',
        'amount': 250,
        'isHalfCourt': true,
        'date': DateTime(2025, 3, 16, 9, 0),
        'duration': 60,
        'isBlocked': false
      },
      {
        'sport': 'Football',
        'customer': 'Chris Martin',
        'amount': 180,
        'isHalfCourt': false,
        'date': DateTime(2025, 3, 16, 11, 0),
        'duration': 60,
        'isBlocked': false
      },
      {
        'sport': 'Tennis',
        'customer': 'Sophia Lee',
        'amount': 160,
        'isHalfCourt': false,
        'date': DateTime(2025, 3, 16, 13, 0),
        'duration': 60,
        'isBlocked': true
      },
    ],
    "Arena 3": [
      {
        'sport': 'Football',
        'customer': 'Olivia Green',
        'amount': 220,
        'isHalfCourt': false,
        'date': DateTime(2025, 3, 17, 8, 0),
        'duration': 60,
        'isBlocked': false
      },
      {
        'sport': 'Cricket',
        'customer': 'Ethan Thomas',
        'amount': 320,
        'isHalfCourt': false,
        'date': DateTime(2025, 3, 17, 10, 0),
        'duration': 120,
        'isBlocked': false
      },
      {
        'sport': 'Basketball',
        'customer': 'Liam White',
        'amount': 270,
        'isHalfCourt': true,
        'date': DateTime(2025, 3, 17, 15, 0),
        'duration': 60,
        'isBlocked': false
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Host Calendar"),
        centerTitle: true,
        actions: [
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
      body: Column(
        children: [
          // Dropdown to select arena
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _selectedArena,
              isExpanded: true,
              items: _arenas
                  .map((arena) => DropdownMenuItem(
                        value: arena,
                        child: Text(arena,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ))
                  .toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedArena = newValue!;
                });
              },
            ),
          ),

          // Calendar with filtered slots
          Expanded(
            child: SfCalendar(
              firstDayOfWeek: 1,
              monthViewSettings:
                  const MonthViewSettings(showTrailingAndLeadingDates: false),
              view: _viewMode,
              allowedViews: const [
                CalendarView.day,
                CalendarView.week,
                CalendarView.month
              ],
              dataSource: BookingDataSource(_getCalendarAppointments()),
              timeSlotViewSettings: TimeSlotViewSettings(
                  numberOfDaysInView: _visibleDays, startHour: 8, endHour: 22),
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
                  _editSlot(details.appointments!.first);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Convert bookings of the selected arena to calendar appointments
  List<Appointment> _getCalendarAppointments() {
    return _bookingsByArena[_selectedArena]!.map((booking) {
      return Appointment(
        startTime: booking['date'],
        endTime: booking['date'].add(Duration(minutes: booking['duration'])),
        subject: "${booking['sport']} - ${booking['customer']}",
        color: booking['isBlocked']
            ? Colors.red
            : (booking['isHalfCourt'] ? Colors.blue : Colors.orange),
        notes: "Cost: \$${booking['amount']}",
      );
    }).toList();
  }

  // Edit Existing Slot
  void _editSlot(Appointment appointment) {
    Map<String, dynamic>? slot = _bookingsByArena[_selectedArena]!.firstWhere(
      (b) => b['date'] == appointment.startTime,
      orElse: () => {},
    );

    if (slot.isEmpty) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Text("Edit Slot - ${_formatDate(slot['date'])}",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold))),
              const SizedBox(height: 16),
              Text("Customer: ${slot['customer']}"),
              Text("Sport: ${slot['sport']}"),
              Text("Duration: ${slot['duration']} min"),
              Text("Cost: \$${slot['amount']}"),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(LucideIcons.check),
                label: const Text("Close"),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}-${date.month}-${date.year}";
  }
}

// Custom Data Source for Syncfusion Calendar
class BookingDataSource extends CalendarDataSource {
  BookingDataSource(List<Appointment> source) {
    appointments = source;
  }
}
