import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'arena_booking_screen.dart'; // Import the Arena Booking Screen

class ArenaDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> arena;

  const ArenaDetailsScreen({super.key, required this.arena});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          arena['name'],
          style: GoogleFonts.exo2(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              _shareArena(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              _addToFavorites(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Multiple Photos and Video (Sliding Behavior)
            SizedBox(
              height: 200,
              child: PageView.builder(
                itemCount: 3, // Replace with actual number of images/videos
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      arena['image'],
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Arena Name and Location
            Text(
              arena['name'],
              style: GoogleFonts.exo2(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                _openGoogleMaps(arena['location']);
              },
              child: Text(
                arena['location'],
                style: GoogleFonts.exo2(
                  fontSize: 16,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Brief Description and Owner
            Text(
              'Description:',
              style: GoogleFonts.exo2(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This is a brief description of the arena. It is a great place for sports enthusiasts. The owner is John Doe.',
              style: GoogleFonts.exo2(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),

            // Overall Rating
            Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  arena['rating'].toString(),
                  style: GoogleFonts.exo2(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Timings and Pricing
            Text(
              'Timings & Pricing:',
              style: GoogleFonts.exo2(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Open: 9:00 AM - 10:00 PM\nPrice: Rs. 400/hr\nPer Day Cost: Rs. 3000',
              style: GoogleFonts.exo2(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),

            // Pre-Tax and Post-Tax Prices
            Text(
              'Pricing Details:',
              style: GoogleFonts.exo2(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pre-Tax: Rs. 400/hr\nPost-Tax: Rs. 450/hr',
              style: GoogleFonts.exo2(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),

            // Facilities
            Text(
              'Facilities:',
              style: GoogleFonts.exo2(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
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
            const SizedBox(height: 20),

            // Recent Reviews
            Text(
              'Recent Reviews:',
              style: GoogleFonts.exo2(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'John Doe: "Great place to play cricket!"',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 8),
                Text(
                  'Jane Smith: "Well-maintained facilities."',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Cancellation Policy
            Text(
              'Cancellation Policy:',
              style: GoogleFonts.exo2(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cancellations must be made 24 hours before the booking time.',
              style: GoogleFonts.exo2(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),

            // Support and Booking Options
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _contactSupport(context);
                    },
                    child: const Text('Talk to Support'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to Arena Booking Screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ArenaBookingScreen(arena: arena),
                        ),
                      );
                    },
                    child: const Text('Book Now'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Join Community (if applicable)
            if (arena['communityExists'] == true)
              ElevatedButton(
                onPressed: () {
                  _joinCommunity(context);
                },
                child: const Text('Join Community'),
              ),
          ],
        ),
      ),
    );
  }

  // Function to open Google Maps
  void _openGoogleMaps(String location) async {
    final Uri googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$location',
    );
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else {
      throw 'Could not launch Google Maps';
    }
  }

  // Function to share arena details
  void _shareArena(BuildContext context) {
    // Implement share functionality (e.g., using the share package)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality not implemented yet.'),
      ),
    );
  }

  // Function to add arena to favorites
  void _addToFavorites(BuildContext context) {
    // Implement add to favorites functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Added to favorites!'),
      ),
    );
  }

  // Function to contact support
  void _contactSupport(BuildContext context) {
    // Implement contact support functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contact support functionality not implemented yet.'),
      ),
    );
  }

  // Function to join community
  void _joinCommunity(BuildContext context) {
    // Implement join community functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Join community functionality not implemented yet.'),
      ),
    );
  }
}

