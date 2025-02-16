import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/theme/theme_bloc.dart';
import '../bloc/theme/theme_state.dart';
import 'arena_details_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onTabTapped;
  final int currentIndex;

  const HomeScreen({super.key, required this.onTabTapped, required this.currentIndex});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
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
    final themeState = context.watch<ThemeBloc>().state;
    final bool isDarkMode = themeState is DarkThemeState;

    // Ensure system UI updates when navigating to this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.read<ThemeBloc>().setSystemUI();
      }
    });

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        toolbarHeight: 100,
        forceMaterialTransparency: true,
        automaticallyImplyLeading: false,
        actions: [
          Container(
            padding: const EdgeInsets.all(16),
            width: MediaQuery.of(context).size.width,
            child: TextField(
              decoration: InputDecoration(
                labelStyle: const TextStyle(fontFamily: 'Exo2'),
                hintStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black,fontFamily: 'Exo2'),
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
                return _buildArenaCard(context, arena, isDarkMode);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArenaCard(BuildContext context, Map<String, dynamic> arena, bool isDarkMode) {
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'Exo2',
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
                    style:TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontFamily: 'Exo2',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    arena['location'],
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontFamily: 'Exo2',
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
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontFamily: 'Exo2',
                        ),
                      ),
                      const Spacer(),
                      Text(
                        arena['price'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontFamily: 'Exo2',
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
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Exo2',
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
