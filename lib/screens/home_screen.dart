import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'arena_details_screen.dart'; // Import the Arena Details Screen

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.isDarkMode});

  final bool isDarkMode;

  final List<Map<String, dynamic>> arenas = const [
    {
      'name': 'Arena 1',
      'location': 'Gulistan-e-Jauhar Block 14',
      'rating': 4.5,
      'price': 'Rs. 400/hr',
      'availability': 'Limited Slots',
      'image': 'assets/arena.jpg',
      'tag': 'Player Favorite'
    },
    {
      'name': 'Arena 2',
      'location': 'DHA Phase 6',
      'rating': 4.2,
      'price': 'Rs. 350/hr',
      'availability': 'Available',
      'image': 'assets/sample_image2.jpg',
      'tag': 'Newly Opened'
    },
    {
      'name': 'Arena 3',
      'location': 'North Nazimabad Block H',
      'rating': 4.8,
      'price': 'Rs. 500/hr',
      'availability': 'Few Slots Left',
      'image': 'assets/sample_image3.jpg',
      'tag': 'Highly Rated'
    },
    {
      'name': 'Arena 4',
      'location': 'Clifton Block 5',
      'rating': 4.0,
      'price': 'Rs. 300/hr',
      'availability': 'Available',
      'image': 'assets/sample_image4.jpg',
      'tag': 'Budget Friendly'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        toolbarHeight: 100,
        forceMaterialTransparency: true,
        automaticallyImplyLeading: false,
        actions: [
          Container(
            padding: const EdgeInsets.all(16),
            width: MediaQuery.of(context).size.width,
            child: TextField(
              decoration: InputDecoration(
                labelStyle: GoogleFonts.exo2(),
                hintStyle: GoogleFonts.exo2(color: isDarkMode ? Colors.white : Colors.black),
                hintText: 'Search arenas near you',
                prefixIcon: Icon(Icons.search, color: isDarkMode ? Colors.white : Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Arena List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: arenas.length,
              itemBuilder: (context, index) {
                final arena = arenas[index];
                return _buildArenaCard(context, arena); // Pass context here
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        selectedLabelStyle: GoogleFonts.exo2(),
        unselectedLabelStyle: GoogleFonts.exo2(),
        selectedItemColor: Colors.green,
        unselectedItemColor: isDarkMode ? Colors.white : Colors.black38,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/bookings');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/settings');
              break;
          }
        },
      ),
    );
  }

  Widget _buildArenaCard(BuildContext context, Map<String, dynamic> arena) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArenaDetailsScreen(arena: arena),
          ),
        );
      },
      child: Card(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    arena['image'],
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      arena['tag'],
                      style: GoogleFonts.exo2(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Arena Name and Location
                  Text(
                    arena['name'],
                    style: GoogleFonts.exo2(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    arena['location'],
                    style: GoogleFonts.exo2(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Rating and Cost
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        arena['rating'].toString(),
                        style: GoogleFonts.exo2(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        arena['price'],
                        style: GoogleFonts.exo2(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: arena['availability'] == 'Limited Slots' ? Colors.red : Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          arena['availability'],
                          style: GoogleFonts.exo2(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
