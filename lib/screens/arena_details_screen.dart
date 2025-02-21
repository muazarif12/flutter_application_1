import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/theme/theme_bloc.dart';
import '../bloc/theme/theme_state.dart';
import 'arena_booking_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ArenaDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> arena;

  const ArenaDetailsScreen({super.key, required this.arena});

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeBloc>().state;
    final bool isDarkMode = themeState is DarkThemeState;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,color: isDarkMode? Colors.white:Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        forceMaterialTransparency: true,
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        title: Text(
          arena['name'],
          style: TextStyle(fontFamily: 'Exo2', fontSize: 20, fontWeight: FontWeight.bold, color: isDarkMode? Colors.white:Colors.black),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share,color: isDarkMode? Colors.white:Colors.black),
            onPressed: () {
              _shareArena(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.favorite_border, color: isDarkMode? Colors.white:Colors.black),
            onPressed: () {
              _addToFavorites(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // **Image Slider**
            Hero(
              tag: arena['image'],
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 200,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    aspectRatio: 16 / 9,
                  ),
                  items: [
                    arena['image'],
                    'assets/sample_image2.jpg',
                    'assets/sample_image3.jpg'
                  ].map((image) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(image, fit: BoxFit.cover, width: double.infinity),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // **Rating Section**
            _card(
              isDarkMode: isDarkMode,
              title: 'Rating',
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 24),
                  const Icon(Icons.star, color: Colors.amber, size: 24),
                  const Icon(Icons.star, color: Colors.amber, size: 24),
                  const Icon(Icons.star, color: Colors.amber, size: 24),
                  const Icon(Icons.star_half_outlined, color: Colors.amber, size: 24),
                  const SizedBox(width: 8),
                  // Text(
                  //   arena['rating'].toString(),
                  //   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black),
                  // ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // **Location Section**
            _card(
              isDarkMode: isDarkMode,
              title: 'Location',
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      _openGoogleMaps(arena['location']);
                    },
                    child: Text(
                      arena['location'],
                      style: const TextStyle(fontSize: 16, color: Colors.blue, decoration: TextDecoration.underline),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () => _openGoogleMaps(arena['location']),
                    icon: Icon(Icons.map,color: Colors.green[900]),
                    label: Text("Open in Maps", style: TextStyle(color:Colors.green[900]),),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // **Arena Information**
            _card(
              isDarkMode: isDarkMode,
              title: 'Description',
              child: Text('This is a great place for sports lovers. The owner is John Doe.', style: TextStyle(color: Colors.green)),
            ),
            _card(
              isDarkMode: isDarkMode,
              title: 'Timings & Pricing',
              child: Text('Open: 9:00 AM - 10:00 PM\nPrice: Rs. 400/hr\nPer Day Cost: Rs. 3000', style: TextStyle(color: Colors.green)),
            ),
            _card(
              isDarkMode: isDarkMode,
              title: 'Pricing Details',
              child: Text('Pre-Tax: Rs. 400/hr\nPost-Tax: Rs. 450/hr', style: TextStyle(color: Colors.green)),
            ),

            const SizedBox(height: 16),

            // **Facilities**
            _card(
              isDarkMode: isDarkMode,
              title: 'Facilities',
              child: Wrap(
                spacing: 8,
                children: const [
                  Chip(label: Text('Cafeteria')),
                  Chip(label: Text('Showers')),
                  Chip(label: Text('Parking')),
                  Chip(label: Text('Wi-Fi')),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // **Recent Reviews**
            _card(
              isDarkMode: isDarkMode,
              title: 'Recent Reviews',
              child: Column(
                children: [
                  _reviewItem('John Doe', 'Great place to play cricket!', isDarkMode),
                  _reviewItem('Jane Smith', 'Well-maintained facilities.', isDarkMode),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // **Cancellation Policy**
            _card(
              isDarkMode: isDarkMode,
              title: 'Cancellation Policy',
              child: Text('Cancellations must be made 24 hours before the booking time.', style: TextStyle(color: Colors.green)),
            ),

            const SizedBox(height: 16),

            // **Support & Booking Options**

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.calendar_today,color: Colors.green[900]),
                label: Text(
                  'Book Now',
                  style: TextStyle(fontFamily: 'Exo2', fontSize: 16, fontWeight: FontWeight.bold,color: Colors.green[900]),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ArenaBookingScreen(arena: arena)),
                  );
                },
              ),
            ),

            const SizedBox(height: 15,),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.support_agent,color: Colors.green[900]),
                label: Text(
                  'Talk to Support',
                  style: TextStyle(fontFamily: 'Exo2', fontSize: 16, fontWeight: FontWeight.bold,color: Colors.green[900]),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                },
              ),
            ),
            // **Join Community Button**
            if (arena['communityExists'] == true)
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _joinCommunity(context);
                  },
                  icon: const Icon(Icons.group),
                  label: const Text('Join Community'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // **Reusable Widgets for UI Enhancements**
  Widget _card({
    required String title,
    required Widget child,
    required bool isDarkMode,
  }) {
    return Card(
      color: isDarkMode ? Colors.grey[850] : Colors.white,
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Exo2', color: isDarkMode ? Colors.white : Colors.black)),
            const Divider(),
            child,
          ],
        ),
      ),
    );
  }

  Widget _reviewItem(String user, String review, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text('$user: "$review"', style: const TextStyle(fontSize: 14, color: Colors.green)),
    );
  }

  // **Functions**
  void _openGoogleMaps(String location) async {
    final Uri googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$location');
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else {
      throw 'Could not launch Google Maps';
    }
  }

  void _shareArena(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Share functionality not implemented yet.')));
  }

  void _addToFavorites(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to favorites!')));
  }

  void _contactSupport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contact support functionality not implemented yet.')));
  }

  void _joinCommunity(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Join community functionality not implemented yet.')));
  }
}

