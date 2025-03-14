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
  List<Map<String, dynamic>> _bookings = [
    {
      'sport': 'Football',
      'customer': 'John Doe',
      'amount': 200,
      'isHalfCourt': false,
      'date': DateTime(2025, 3, 11, 10, 0),
      'duration': 60,
      'isBlocked': false,
    },
    {
      'sport': 'Tennis',
      'customer': 'Jane Smith',
      'amount': 150,
      'isHalfCourt': true,
      'date': DateTime(2025, 3, 10, 14, 0),
      'duration': 60,
      'isBlocked': false,
    },
    {
      'sport': 'Cricket',
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
                } else if (value == "30-day") {
                  _viewMode =
                      CalendarView.timelineMonth; // FIX: Use timelineMonth
                  _visibleDays = 30;
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
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          backgroundColor: Colors.white,
        ),
        onTap: (CalendarTapDetails details) {
          if (details.appointments != null &&
              details.appointments!.isNotEmpty) {
            _editSlot(details.appointments!.first);
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
        subject: booking['sport'],
        color: booking['isBlocked']
            ? Colors.red
            : (booking['isHalfCourt'] ? Colors.blue : Colors.orange),
        notes: "${booking['customer']} - \$${booking['amount']}",
      );
    }).toList();
  }

  // Edit Existing Slot
  void _editSlot(Appointment appointment) {
    Map<String, dynamic>? slot = _bookings.firstWhere(
      (b) => b['date'] == appointment.startTime,
      orElse: () => {},
    );

    if (slot.isEmpty) return;

    // Ensure duration is a double to avoid type errors
    double slotDuration = (slot['duration'] as int).toDouble();
    bool isHalfCourt = slot['isHalfCourt'];
    bool isBlocked = slot['isBlocked'];
    double slotCost =
        (slot['amount'] as num).toDouble(); // Ensure cost is also a double

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
                    Center(
                      child: Text(
                        "Edit Slot - ${_formatDate(slot['date'])}",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Slot Duration (Reduce Only)
                    Text("Slot Duration (Cannot be Increased)",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Slider(
                      value: slotDuration,
                      min: 30.0, // Must be a double
                      max: 60.0,
                      divisions: 2,
                      label: "${slotDuration.toInt()} min",
                      onChanged: (value) {
                        setState(() {
                          slotDuration = value;
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
      slot['duration'] = duration.toInt();
      slot['isHalfCourt'] = halfCourt;
      slot['isBlocked'] = blocked;
      slot['amount'] = cost;
    });
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
