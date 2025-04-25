import 'package:flutter/material.dart';
import 'add_arena_screen.dart';
import 'edit_arena_screen.dart';

class HostListingsScreen extends StatefulWidget {
  const HostListingsScreen({super.key});

  @override
  HostListingsScreenState createState() => HostListingsScreenState();
}

class HostListingsScreenState extends State<HostListingsScreen> {
  List<Map<String, dynamic>> arenas = [
    {
      'id': 1,
      'name': 'GreenField Arena',
      'location': 'Downtown Sports Complex',
      'price': 'Rs. 500/hr',
      'rating': 4.5,
      'availability': 'Available',
      'image': 'assets/arena.jpg',
      'tag': 'Football'
    },
    {
      'id': 2,
      'name': 'Elite Sports Club',
      'location': 'Phase 6, DHA',
      'price': 'Rs. 700/hr',
      'rating': 4.8,
      'availability': 'Limited Slots',
      'image': 'assets/sample_image2.jpg',
      'tag': 'Tennis'
    },
    {
      'id': 3,
      'name': 'Cricket Pro Ground',
      'location': 'Clifton Block 5',
      'price': 'Rs. 300/hr',
      'rating': 4.0,
      'availability': 'Available',
      'image': 'assets/cricket_ground.jpg',
      'tag': 'Cricket'
    },
  ];
  String? selectedSport;
  List<String> selectedSports = []; // ✅ Holds selected filters

  // ✅ Get filtered list of arenas
  List<Map<String, dynamic>> get filteredArenas {
    if (selectedSports.isEmpty) return arenas; // No filter applied
    return arenas
        .where((arena) => selectedSports.contains(arena['tag']))
        .toList();
  }

  // ✅ Handle filter selection
  void toggleFilter(String sport) {
    setState(() {
      if (selectedSports.contains(sport)) {
        selectedSports.remove(sport);
      } else {
        selectedSports.add(sport);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        forceMaterialTransparency: true,
        title: const Text("My Arenas"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ✅ Filter Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
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
                          border: Border.all(color: selectedSport == sport ? Colors.blue : Colors.grey),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/$sport.png',
                              width: 50,
                              height: 50,
                              color: selectedSport == sport ? Colors.blue : Colors.grey,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              sport,
                              style: TextStyle(
                                color: selectedSport == sport ? Colors.blue: Colors.grey,
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
          ),

          // ✅ Arena Listings
          Expanded(
            child: filteredArenas.isEmpty
                ? const Center(
                child: Text("No arenas found for selected sports."))
                : ListView.builder(
              itemCount: filteredArenas.length,
              itemBuilder: (context, index) {
                final arena = filteredArenas[index];
                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  elevation: 3,
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
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
                            Text(
                              arena['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
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
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Exo2',
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  arena['price'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Exo2',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: arena['availability'] ==
                                        'Limited Slots'
                                        ? Colors.red
                                        : Colors.blue,
                                    borderRadius:
                                    BorderRadius.circular(12),
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
                            const SizedBox(height: 16),
                            // ✅ Separate Edit and Delete Buttons
                            Row(
                              children: [
                                // Edit Button
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditArenaScreen(arena: arena),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  child: const Text('Edit'),
                                ),
                                // Delete Button
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _deleteArena(arena['id']);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text('Delete'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddArenaScreen()),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // ✅ Filter Button Widget
  Widget _filterButton(String sport, IconData icon) {
    bool isSelected = selectedSports.contains(sport);
    return GestureDetector(
      onTap: () => toggleFilter(sport),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[100] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.green : Colors.grey),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.green : Colors.black),
            const SizedBox(width: 5),
            Text(
              sport,
              style: TextStyle(
                color: isSelected ? Colors.green : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Delete Arena
  void _deleteArena(int id) {
    setState(() {
      arenas.removeWhere((arena) => arena['id'] == id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Arena deleted successfully')),
    );
  }
}
