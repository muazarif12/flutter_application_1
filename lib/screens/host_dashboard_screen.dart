import 'package:flutter/material.dart';

class HostDashboardScreen extends StatelessWidget {
  const HostDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Currently Booked Slots
            _buildSectionTitle("Currently Booked Slots"),
            _buildBookingList([
              {'time': '10:00 AM - 12:00 PM', 'sport': 'Football', 'customer': 'John Doe'},
              {'time': '2:00 PM - 4:00 PM', 'sport': 'Tennis', 'customer': 'Jane Smith'},
            ]),

            const SizedBox(height: 20),

            // Upcoming Bookings
            _buildSectionTitle("Upcoming Bookings"),
            _buildBookingList([
              {'time': '6:00 PM - 8:00 PM', 'sport': 'Cricket', 'customer': 'Alice Johnson'},
              {'time': '9:00 AM - 10:00 AM', 'sport': 'Basketball', 'customer': 'Bob Brown'},
            ]),

            const SizedBox(height: 20),

            // Calendar View Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to Calendar View Page
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

            // Reminder to Reply to Messages
            _buildSectionTitle("Reminders"),
            _buildMessageReminder("You have 2 unread messages from customers."),

            const SizedBox(height: 20),

            // Contact App Support
            _buildSectionTitle("Support"),
            _buildContactSupportButton(context),
          ],
        ),
      ),
    );
  }

  // Section Title
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  // Booking List
  Widget _buildBookingList(List<Map<String, String>> bookings) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(booking['time']!),
            subtitle: Text("${booking['sport']} - ${booking['customer']}"),
          ),
        );
      },
    );
  }

  // Message Reminder
  Widget _buildMessageReminder(String message) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.message, color: Colors.blue),
        title: Text(message),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          // Navigate to messages screen
        },
      ),
    );
  }

  // Contact App Support Button
  Widget _buildContactSupportButton(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.support_agent, color: Colors.green),
        title: const Text("Contact App Support"),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          // Open support contact options
          _showSupportOptions(context);
        },
      ),
    );
  }

  // Show Support Options
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
              onTap: () {
                // Open email app
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text("Call Support"),
              onTap: () {
                // Open phone dialer
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text("Live Chat"),
              onTap: () {
                // Open live chat
                Navigator.pop(context);
              },
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