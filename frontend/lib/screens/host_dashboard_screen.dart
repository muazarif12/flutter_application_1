import 'package:flutter/material.dart';

class HostDashboardScreen extends StatelessWidget {
  const HostDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        forceMaterialTransparency: true,
        title: const Text("Dashboard"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Currently Booked Slots"),
            _buildBookingList([
              {'time': '10:00 AM - 12:00 PM', 'sport': 'Football', 'customer': 'John Doe'},
              {'time': '2:00 PM - 4:00 PM', 'sport': 'Tennis', 'customer': 'Jane Smith'},
            ]),

            const SizedBox(height: 20),

            _buildSectionTitle("Upcoming Bookings"),
            _buildBookingList([
              {'time': '6:00 PM - 8:00 PM', 'sport': 'Cricket', 'customer': 'Alice Johnson'},
              {'time': '9:00 AM - 10:00 AM', 'sport': 'Basketball', 'customer': 'Bob Brown'},
            ]),

            const SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CalendarViewScreen(),
                    ),
                  );
                },
                child: const Text("Go to Calendar View"),
              ),
            ),

            const SizedBox(height: 20),

            _buildSectionTitle("Reminders"),
            _buildMessageReminder("You have 2 unread messages from customers."),

            const SizedBox(height: 20),

            _buildSectionTitle("Support"),
            _buildContactSupportButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildBookingList(List<Map<String, String>> bookings) {
    return Column(
      children: bookings.map((booking) {
        return Card(
          color: Colors.white,
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            title: Text(booking['time']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${booking['sport']} - ${booking['customer']}"),
            trailing: const Icon(Icons.calendar_today, color: Colors.blue),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMessageReminder(String message) {
    return Card(
      color: Colors.white,
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.message, color: Colors.blue),
        title: Text(message),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {},
      ),
    );
  }

  Widget _buildContactSupportButton(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.support_agent, color: Colors.green),
        title: const Text("Contact App Support"),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () => _showSupportOptions(context),
      ),
    );
  }

  void _showSupportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text("Email Support"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text("Call Support"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text("Live Chat"),
              onTap: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }
}

// Calendar View Screen (Dummy Screen)
class CalendarViewScreen extends StatelessWidget {
  const CalendarViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calendar View"),
      ),
      body: const Center(
        child: Text("Calendar View Page"),
      ),
    );
  }
}
