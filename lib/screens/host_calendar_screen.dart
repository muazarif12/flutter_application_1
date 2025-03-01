import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class HostCalendarScreen extends StatefulWidget {
  const HostCalendarScreen({super.key});

  @override
  _HostCalendarScreenState createState() => _HostCalendarScreenState();
}

class _HostCalendarScreenState extends State<HostCalendarScreen> {
  final CalendarView _viewMode = CalendarView.month; // Default View Mode

  // Dummy booking data
  final List<Map<String, dynamic>> _bookings = [
    {
      'sport': 'Football',
      'customer': 'John Doe',
      'amount': 200,
      'isHalfCourt': false,
      'date': DateTime(2025, 2, 28, 10, 0),
    },
    {
      'sport': 'Tennis',
      'customer': 'Jane Smith',
      'amount': 150,
      'isHalfCourt': true,
      'date': DateTime(2025, 2, 28, 14, 0),
    },
    {
      'sport': 'Cricket',
      'customer': 'Alice Johnson',
      'amount': 300,
      'isHalfCourt': false,
      'date': DateTime(2025, 3, 1, 18, 0),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Host Calendar"),
        centerTitle: true,

      ),
      body: SfCalendar(
        firstDayOfWeek: 1,
        monthViewSettings: MonthViewSettings(showTrailingAndLeadingDates: false),
        view: _viewMode,
        allowedViews: const [CalendarView.day, CalendarView.month], // Enables switching
        dataSource: BookingDataSource(_getCalendarAppointments()),
        onTap: (CalendarTapDetails details) {
          if (details.appointments != null && details.appointments!.isNotEmpty) {
            _showBookingDetails(details.appointments!.first);
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
        endTime: booking['date'].add(const Duration(hours: 2)),
        subject: booking['sport'],
        color: booking['isHalfCourt'] ? Colors.orange : Colors.blue,
        notes: booking['customer'],
      );
    }).toList();
  }

  // Show booking details
  void _showBookingDetails(Appointment appointment) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
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
                  "Booking Details",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow(LucideIcons.dumbbell, "Sport", appointment.subject),
              _buildDetailRow(LucideIcons.user, "Customer", appointment.notes ?? "N/A"),
              _buildDetailRow(
                LucideIcons.clock,
                "Time",
                "${_formatTime(appointment.startTime)} - ${_formatTime(appointment.endTime)}",
              ),
              _buildDetailRow(
                LucideIcons.home,
                "Court Type",
                appointment.color == Colors.orange ? "Half Court" : "Full Court",
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LucideIcons.x),
                  label: const Text("Close"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey, size: 22),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return "${time.hour % 12 == 0 ? 12 : time.hour % 12}:${time.minute.toString().padLeft(2, '0')} ${time.hour >= 12 ? "PM" : "AM"}";
  }
}

// Custom Data Source for Syncfusion Calendar
class BookingDataSource extends CalendarDataSource {
  BookingDataSource(List<Appointment> source) {
    appointments = source;
  }
}
