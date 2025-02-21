import 'package:flutter/material.dart';

class HostCalendarScreen extends StatefulWidget {
  const HostCalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<HostCalendarScreen> {
  // Calendar view mode (Day or Month)
  String _viewMode = 'Day';

  // Dummy data for bookings
  final List<Map<String, dynamic>> _bookings = [
    {
      'time': '10:00 AM - 12:00 PM',
      'sport': 'Football',
      'customer': 'John Doe',
      'amount': 200,
      'isHalfCourt': false,
    },
    {
      'time': '2:00 PM - 4:00 PM',
      'sport': 'Tennis',
      'customer': 'Jane Smith',
      'amount': 150,
      'isHalfCourt': true,
    },
    {
      'time': '6:00 PM - 8:00 PM',
      'sport': 'Cricket',
      'customer': 'Alice Johnson',
      'amount': 300,
      'isHalfCourt': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calendar"),
        centerTitle: true,
        actions: [
          // Toggle between Day and Month View
          DropdownButton<String>(
            value: _viewMode,
            items: const [
              DropdownMenuItem(value: 'Day', child: Text("Day View")),
              DropdownMenuItem(value: 'Month', child: Text("Month View")),
            ],
            onChanged: (value) {
              setState(() {
                _viewMode = value!;
              });
            },
          ),
        ],
      ),
      body: _viewMode == 'Day' ? _buildDayView() : _buildMonthView(),
    );
  }

  // Day View
  Widget _buildDayView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Display bookings as blocked timings
        for (var booking in _bookings)
          _buildBookingBlock(booking),
      ],
    );
  }

  // Booking Block for Day View
  Widget _buildBookingBlock(Map<String, dynamic> booking) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      width: booking['isHalfCourt'] ? MediaQuery.of(context).size.width * 0.5 : double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            booking['time'],
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text("Customer: ${booking['customer']}"),
          Text("Amount: \$${booking['amount']}"),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              // Show more details
              _showBookingDetails(booking);
            },
            child: const Text("View Details"),
          ),
        ],
      ),
    );
  }

  // Show Booking Details
  void _showBookingDetails(Map<String, dynamic> booking) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Booking Details",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text("Time: ${booking['time']}"),
              Text("Sport: ${booking['sport']}"),
              Text("Customer: ${booking['customer']}"),
              Text("Amount: \$${booking['amount']}"),
              Text("Court Type: ${booking['isHalfCourt'] ? 'Half Court' : 'Full Court'}"),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Close"),
              ),
            ],
          ),
        );
      },
    );
  }

  // Month View
  Widget _buildMonthView() {
    // Dummy data for month view
    final Map<String, Map<String, dynamic>> monthData = {
      '2023-10-01': {'bookings': 3, 'balance': 500},
      '2023-10-02': {'bookings': 2, 'balance': 300},
      '2023-10-03': {'bookings': 1, 'balance': 150},
      // Add more days as needed
    };

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7, // 7 days in a week
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: monthData.length,
      itemBuilder: (context, index) {
        final date = monthData.keys.elementAt(index);
        final data = monthData[date]!;
        return Container(
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                date.split('-').last, // Display day only
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text("Bookings: ${data['bookings']}"),
              Text("Balance: \$${data['balance']}"),
            ],
          ),
        );
      },
    );
  }
}