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

    // Ensure system UI updates after the screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.read<ThemeBloc>().setSystemUI();
      }
    });

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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

            // **Location & Google Maps Button**
            _sectionHeader('Location', isDarkMode),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _openGoogleMaps(arena['location']);
                    },
                    child: Text(
                      arena['location'],
                      style: const TextStyle(fontSize: 16, color: Colors.blue, decoration: TextDecoration.underline),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _openGoogleMaps(arena['location']),
                  icon: const Icon(Icons.map),
                  label: const Text("Open Maps"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // **Arena Information**
            _infoCard('Description', 'This is a great place for sports lovers. The owner is John Doe.', isDarkMode),
            _infoCard('Timings & Pricing', 'Open: 9:00 AM - 10:00 PM\nPrice: Rs. 400/hr\nPer Day Cost: Rs. 3000', isDarkMode),
            _infoCard('Pricing Details', 'Pre-Tax: Rs. 400/hr\nPost-Tax: Rs. 450/hr', isDarkMode),

            const SizedBox(height: 16),

            // **Facilities**
            _sectionHeader('Facilities', isDarkMode),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: const [
                Chip(label: Text('Cafeteria')),
                Chip(label: Text('Showers')),
                Chip(label: Text('Parking')),
                Chip(label: Text('Wi-Fi')),
              ],
            ),

            const SizedBox(height: 16),

            // **Overall Rating**
            _sectionHeader('Rating', isDarkMode),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 24),
                const SizedBox(width: 8),
                Text(
                  arena['rating'].toString(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // **Recent Reviews**
            _sectionHeader('Recent Reviews', isDarkMode),
            const SizedBox(height: 6),
            _reviewItem('John Doe', 'Great place to play cricket!'),
            _reviewItem('Jane Smith', 'Well-maintained facilities.'),

            const SizedBox(height: 20),

            // **Cancellation Policy**
            _sectionHeader('Cancellation Policy', isDarkMode),
            const SizedBox(height: 6),
            _infoCard('Policy', 'Cancellations must be made 24 hours before the booking time.', isDarkMode),

            const SizedBox(height: 16),

            // **Support & Booking Options**
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _contactSupport(context);
                    },
                    icon: const Icon(Icons.support_agent),
                    label: const Text('Talk to Support'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ArenaBookingScreen(arena: arena)),
                      );
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Book Now'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

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
  Widget _sectionHeader(String title, bool isDarkMode) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDarkMode? Colors.white: Colors.black),
    );
  }

  Widget _infoCard(String title, String description, bool isDarkMode) {
    return Card(
      color: isDarkMode ? Colors.grey[850] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black,)),
              const SizedBox(height: 6),
              Text(description, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reviewItem(String user, String review) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text('$user: "$review"', style: const TextStyle(fontSize: 14, color: Colors.grey)),
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
