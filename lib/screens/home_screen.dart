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
      'tag': 'Player Favorite',
      'sport': 'Cricket',
    },
    {
      'name': 'Arena 2',
      'location': 'DHA Phase 6',
      'rating': 4.2,
      'price': 'Rs. 350/hr',
      'availability': 'Available',
      'image': 'assets/sample_image2.jpg',
      'tag': 'Newly Opened',
      'sport': 'Football',
    },
    {
      'name': 'Arena 3',
      'location': 'North Nazimabad Block H',
      'rating': 4.8,
      'price': 'Rs. 500/hr',
      'availability': 'Few Slots Left',
      'image': 'assets/sample_image3.jpg',
      'tag': 'Highly Rated',
      'sport': 'Tennis',
    },
    {
      'name': 'Arena 4',
      'location': 'Clifton Block 5',
      'rating': 4.0,
      'price': 'Rs. 300/hr',
      'availability': 'Available',
      'image': 'assets/sample_image4.jpg',
      'tag': 'Budget Friendly',
      'sport': 'Cricket',
    },
  ];

  String? selectedSport;  // Initially null to show all arenas
  bool sortAscending = true;  // Flag to track sorting order (ascending or descending)

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
            padding: const EdgeInsets.only(left: 0,right: 16,top: 16,bottom: 16),
            width: MediaQuery.of(context).size.width *0.8,
            child: TextField(
              decoration: InputDecoration(
                labelStyle: const TextStyle(fontFamily: 'Exo2'),
                hintStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontFamily: 'Exo2'),
                hintText: 'Search arenas near you',
                prefixIcon: Icon(Icons.search, color: isDarkMode ? Colors.white : Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          IconButton(
            padding: EdgeInsets.only(right: 16),
            icon: Icon(Icons.filter_list, color: isDarkMode ? Colors.white : Colors.black),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Horizontal sports scroll view
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Cricket', 'Football', 'Tennis'].map((sport) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        // If the selected sport is tapped again, show all arenas
                        if (selectedSport == sport) {
                          selectedSport = null;
                        } else {
                          selectedSport = sport;
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: selectedSport == sport ? Colors.green : Colors.grey),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/$sport.png',
                              width: 50,
                              height: 50,
                              color: selectedSport == sport ? Colors.green : Colors.grey,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              sport,
                              style: TextStyle(
                                color: selectedSport == sport ? Colors.green : Colors.grey,
                                fontFamily: 'Exo2',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Filtered Arena List based on selected sport
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _getFilteredArenas().length,
              itemBuilder: (context, index) {
                final arena = _getFilteredArenas()[index];
                return _buildArenaCard(context, arena, isDarkMode);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Function to get arenas after applying sport and price filter
  List<Map<String, dynamic>> _getFilteredArenas() {
    List<Map<String, dynamic>> filteredArenas = arenas.where((arena) {
      return selectedSport == null || arena['sport'] == selectedSport;
    }).toList();

    // Sort the filtered arenas by price
    filteredArenas.sort((a, b) {
      final priceA = int.parse(a['price'].replaceAll(RegExp(r'[^0-9]'), ''));
      final priceB = int.parse(b['price'].replaceAll(RegExp(r'[^0-9]'), ''));

      return sortAscending ? priceA.compareTo(priceB) : priceB.compareTo(priceA);
    });

    return filteredArenas;
  }

  // Function to show the filter options dialog
  void _showFilterOptions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sort by Price'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Cheapest First'),
                leading: Radio<bool>(
                  value: true,
                  groupValue: sortAscending,
                  onChanged: (bool? value) {
                    setState(() {
                      sortAscending = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Text('Most Expensive First'),
                leading: Radio<bool>(
                  value: false,
                  groupValue: sortAscending,
                  onChanged: (bool? value) {
                    setState(() {
                      sortAscending = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontFamily: 'Exo2',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.blue, size: 16),
                      Text(
                        arena['location'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                          fontFamily: 'Exo2',
                        ),
                      ),
                    ],
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
