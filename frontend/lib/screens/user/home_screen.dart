import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import 'arena_details_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onTabTapped;
  final int currentIndex;

  const HomeScreen(
      {super.key, required this.onTabTapped, required this.currentIndex});

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

  // List of available areas
  final List<String> areas = [
    'All Areas',
    'Gulistan-e-Jauhar',
    'Gulshan Iqbal',
    'DHA',
    'Clifton',
    'North Nazimabad',
  ];

  String? selectedSport;
  bool sortAscending = true;
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  // Advanced search parameters
  String selectedArea = 'All Areas';
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  int teamSize = 5; // Default team size
  RangeValues priceRange = const RangeValues(300, 500); // Rs. 300 to Rs. 500
  bool showAdvancedSearch = false;

  @override
  void initState() {
    super.initState();
    _showLocationDialog();
  }

  void _showLocationDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Enable Location"),
            content: const Text(
              "To provide the best experience, allow access to your location.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("No, Thanks"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _requestLocationPermission();
                },
                child: const Text("Allow"),
              ),
            ],
          );
        },
      );
    });
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print(
          "User Location: Lat:${position.latitude}, Long:${position.longitude}");
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  // Method to show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Method to show time picker
  Future<void> _selectTime(BuildContext context) async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date first')),
      );
      return;
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeBloc>().state;
    final bool isDarkMode = themeState is DarkThemeState;

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
            padding:
                const EdgeInsets.only(left: 0, right: 16, top: 16, bottom: 16),
            width: MediaQuery.of(context).size.width * 0.8,
            child: TextField(
              controller: searchController,
              onChanged: (query) {
                setState(() {
                  searchQuery = query.toLowerCase();
                });
              },
              decoration: InputDecoration(
                labelStyle: const TextStyle(fontFamily: 'Exo2'),
                hintStyle: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Exo2'),
                hintText: 'Search arenas near you',
                prefixIcon: Icon(Icons.search,
                    color: isDarkMode ? Colors.white : Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear,
                            color: isDarkMode ? Colors.white : Colors.black),
                        onPressed: () {
                          setState(() {
                            searchController.clear();
                            searchQuery = "";
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),
          IconButton(
            padding: const EdgeInsets.only(right: 16),
            icon: Icon(
              showAdvancedSearch ? Icons.close : Icons.filter_list,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () {
              setState(() {
                showAdvancedSearch = !showAdvancedSearch;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Advanced Search Panel
            if (showAdvancedSearch) _buildAdvancedSearchPanel(isDarkMode),

            // Horizontal sports scroll view
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Cricket', 'Football', 'Tennis'].map((sport) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
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
                          border: Border.all(
                              color: selectedSport == sport
                                  ? Colors.green
                                  : Colors.grey),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/$sport.png',
                              width: 50,
                              height: 50,
                              color: selectedSport == sport
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              sport,
                              style: TextStyle(
                                color: selectedSport == sport
                                    ? Colors.green
                                    : Colors.grey,
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

            // Filtered Arena List
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

  // Advanced Search Panel Widget
  Widget _buildAdvancedSearchPanel(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Advanced Search',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
              fontFamily: 'Exo2',
            ),
          ),
          const SizedBox(height: 16),

          // Area Selection
          Text(
            'Area',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
              fontFamily: 'Exo2',
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: selectedArea,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontFamily: 'Exo2',
                ),
                dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
                items: areas.map((String area) {
                  return DropdownMenuItem<String>(
                    value: area,
                    child: Text(area),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedArea = newValue;
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Date & Time Selection
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontFamily: 'Exo2',
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 12),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey[800] : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedDate == null
                                  ? 'Select Date'
                                  : DateFormat('MMM dd, yyyy')
                                      .format(selectedDate!),
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black,
                                fontFamily: 'Exo2',
                              ),
                            ),
                            Icon(
                              Icons.calendar_today,
                              color: isDarkMode ? Colors.white : Colors.black,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Time',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontFamily: 'Exo2',
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _selectTime(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 12),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey[800] : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: selectedDate == null
                                ? Colors.grey.withOpacity(0.5)
                                : Colors.grey,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedTime == null
                                  ? 'Select Time'
                                  : selectedTime!.format(context),
                              style: TextStyle(
                                color: selectedDate == null
                                    ? (isDarkMode
                                        ? Colors.grey
                                        : Colors.grey[600])
                                    : (isDarkMode
                                        ? Colors.white
                                        : Colors.black),
                                fontFamily: 'Exo2',
                              ),
                            ),
                            Icon(
                              Icons.access_time,
                              color: selectedDate == null
                                  ? Colors.grey
                                  : (isDarkMode ? Colors.white : Colors.black),
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Team Size Selector
          Text(
            'Team Size: $teamSize players',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
              fontFamily: 'Exo2',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (teamSize > 1) {
                    setState(() {
                      teamSize--;
                    });
                  }
                },
                icon: Icon(
                  Icons.remove_circle,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              Expanded(
                child: Slider(
                  value: teamSize.toDouble(),
                  min: 1,
                  max: 11,
                  divisions: 10,
                  activeColor: Colors.green,
                  inactiveColor: Colors.grey,
                  onChanged: (value) {
                    setState(() {
                      teamSize = value.toInt();
                    });
                  },
                ),
              ),
              IconButton(
                onPressed: () {
                  if (teamSize < 11) {
                    setState(() {
                      teamSize++;
                    });
                  }
                },
                icon: Icon(
                  Icons.add_circle,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Price Range Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Price Range',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontFamily: 'Exo2',
                ),
              ),
              Text(
                'Rs. ${priceRange.start.toInt()} - Rs. ${priceRange.end.toInt()}',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontFamily: 'Exo2',
                ),
              ),
            ],
          ),
          RangeSlider(
            values: priceRange,
            min: 100,
            max: 1000,
            divisions: 18,
            activeColor: Colors.green,
            inactiveColor: Colors.grey,
            labels: RangeLabels(
              'Rs. ${priceRange.start.toInt()}',
              'Rs. ${priceRange.end.toInt()}',
            ),
            onChanged: (RangeValues values) {
              setState(() {
                priceRange = values;
              });
            },
          ),
          const SizedBox(height: 16),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Apply filters and close the advanced search panel
                setState(() {
                  showAdvancedSearch = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Exo2',
                ),
              ),
            ),
          ),

          // Reset Button
          TextButton(
            onPressed: () {
              setState(() {
                // Reset all advanced search filters
                selectedArea = 'All Areas';
                selectedDate = null;
                selectedTime = null;
                teamSize = 5;
                priceRange = const RangeValues(300, 500);
              });
            },
            child: Center(
              child: Text(
                'Reset All Filters',
                style: TextStyle(
                  color: Colors.green,
                  fontFamily: 'Exo2',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to get filtered arenas based on all filters
  List<Map<String, dynamic>> _getFilteredArenas() {
    List<Map<String, dynamic>> filteredArenas = arenas.where((arena) {
      // Basic text search
      final nameMatches = arena['name'].toLowerCase().contains(searchQuery);
      final locationMatches =
          arena['location'].toLowerCase().contains(searchQuery);

      // Sport filter
      final sportMatches =
          selectedSport == null || arena['sport'] == selectedSport;

      // Area filter (if "All Areas" is selected, don't filter by area)
      final areaMatches = selectedArea == 'All Areas' ||
          arena['location'].contains(selectedArea);

      // Price filter (extract numeric price value from string)
      final priceValue =
          int.parse(arena['price'].replaceAll(RegExp(r'[^0-9]'), ''));
      final priceMatches =
          priceValue >= priceRange.start && priceValue <= priceRange.end;

      return (nameMatches || locationMatches) &&
          sportMatches &&
          areaMatches &&
          priceMatches;
    }).toList();

    // Sort the filtered arenas by price
    filteredArenas.sort((a, b) {
      final priceA = int.parse(a['price'].replaceAll(RegExp(r'[^0-9]'), ''));
      final priceB = int.parse(b['price'].replaceAll(RegExp(r'[^0-9]'), ''));

      return sortAscending
          ? priceA.compareTo(priceB)
          : priceB.compareTo(priceA);
    });

    return filteredArenas;
  }

  // Function to show the filter options dialog (price sorting)
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

  Widget _buildArenaCard(
      BuildContext context, Map<String, dynamic> arena, bool isDarkMode) {
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                      const Icon(Icons.location_on,
                          color: Colors.blue, size: 16),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: arena['availability'] == 'Limited Slots'
                              ? Colors.red
                              : Colors.blue,
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
