import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/theme/theme_bloc.dart';
import '../bloc/theme/theme_state.dart';

class BookingsScreen extends StatefulWidget {
  @override
  _BookingsScreenState createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Dummy booking data
  final List<Map<String, dynamic>> _bookings = [
    {
      'arenaName': 'Arena 1',
      'sport': 'Football',
      'date': DateTime(2025, 3, 15, 18, 0), // Future booking (upcoming)
      'slot': '6:00 PM',
      'teamSize': 5,
      'isHalfCourt': true,
      'paymentMethod': 'Easypaisa',
      'amountPaid': 'Rs. 400',
    },
    {
      'arenaName': 'Arena 2',
      'sport': 'Tennis',
      'date': DateTime(2025, 2, 10, 10, 0), // Past booking (history)
      'slot': '10:00 AM',
      'teamSize': 2,
      'isHalfCourt': false,
      'paymentMethod': 'Cash',
      'amountPaid': 'Rs. 350',
    },
    {
      'arenaName': 'Arena 3',
      'sport': 'Cricket',
      'date': DateTime(2025, 3, 20, 14, 0), // Future booking (upcoming)
      'slot': '2:00 PM',
      'teamSize': 11,
      'isHalfCourt': false,
      'paymentMethod': 'PayPro',
      'amountPaid': 'Rs. 500',
    },
    {
      'arenaName': 'Arena 4',
      'sport': 'Basketball',
      'date': DateTime(2025, 1, 25, 16, 0), // Past booking (history)
      'slot': '4:00 PM',
      'teamSize': 5,
      'isHalfCourt': true,
      'paymentMethod': 'Easypaisa',
      'amountPaid': 'Rs. 450',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeBloc>().state;
    final bool isDarkMode = themeState is DarkThemeState;

    final List<Map<String, dynamic>> upcomingBookings = _bookings
        .where((booking) => booking['date'].isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => b['date'].compareTo(a['date'])); // Reverse chronological order

    final List<Map<String, dynamic>> pastBookings = _bookings
        .where((booking) => booking['date'].isBefore(DateTime.now()))
        .toList()
      ..sort((a, b) => b['date'].compareTo(a['date'])); // Reverse chronological order

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(
          "Bookings",
          style: TextStyle(
            fontFamily: 'Exo2',
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
        forceMaterialTransparency: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.green,
          labelColor: Colors.green,
          unselectedLabelColor: isDarkMode ? Colors.white70 : Colors.black45,
          labelStyle: TextStyle(fontFamily: 'Exo2', fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "Current"),
            Tab(text: "History"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingList(upcomingBookings, isDarkMode, true),
          _buildBookingList(pastBookings, isDarkMode, false),
        ],
      ),
    );
  }

  Widget _buildBookingList(List<Map<String, dynamic>> bookings, bool isDarkMode, bool isUpcoming) {
    if (bookings.isEmpty) {
      return Center(
        child: Text(
          "No bookings found",
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode ? Colors.white70 : Colors.black54,
            fontFamily: 'Exo2',
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _buildBookingItem(booking, isDarkMode, isUpcoming);
      },
    );
  }

  Widget _buildBookingItem(Map<String, dynamic> booking, bool isDarkMode, bool isUpcoming) {
    return Card(
      color: isDarkMode ? Colors.grey[900] : Colors.white,
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        title: Text(
          booking['arenaName'],
          style: TextStyle(fontFamily: 'Exo2', fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black),
        ),
        subtitle: Text(
          "${booking['sport']} - ${booking['date'].toLocal().toString().split(' ')[0]} at ${booking['slot']}",
          style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54, fontFamily: 'Exo2'),
        ),
        children: [
          ListTile(
            title: Text("Team Size", style: TextStyle(fontFamily: 'Exo2', fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
            subtitle: Text("${booking['teamSize']} players", style: TextStyle(fontFamily: 'Exo2', color: isDarkMode ? Colors.white70 : Colors.black54)),
          ),
          ListTile(
            title: Text("Court Type", style: TextStyle(fontFamily: 'Exo2', fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
            subtitle: Text(booking['isHalfCourt'] ? "Half Court" : "Full Court", style: TextStyle(fontFamily: 'Exo2', color: isDarkMode ? Colors.white70 : Colors.black54)),
          ),
          ListTile(
            title: Text("Payment Method", style: TextStyle(fontFamily: 'Exo2', fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
            subtitle: Text(booking['paymentMethod'], style: TextStyle(fontFamily: 'Exo2', color: isDarkMode ? Colors.white70 : Colors.black54)),
          ),
          ListTile(
            title: Text("Amount Paid", style: TextStyle(fontFamily: 'Exo2', fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
            subtitle: Text(booking['amountPaid'], style: TextStyle(fontFamily: 'Exo2', color: isDarkMode ? Colors.white70 : Colors.black54)),
          ),
          if (isUpcoming)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: ElevatedButton(
                onPressed: () {
                  _cancelBooking(booking);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text("Cancel Booking", style: TextStyle(color: Colors.white, fontFamily: 'Exo2')),
              ),
            ),
        ],
      ),
    );
  }

  void _cancelBooking(Map<String, dynamic> booking) {
    setState(() {
      _bookings.remove(booking);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Booking canceled successfully"),
        backgroundColor: Colors.red,
      ),
    );
  }
}
