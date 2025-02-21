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
      'image': 'assets/arena.jpg'
    },
    {
      'id': 2,
      'name': 'Elite Sports Club',
      'location': 'Phase 6, DHA',
      'price': 'Rs. 700/hr',
      'image': 'assets/sample_image2.jpg'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Arenas"),
        centerTitle: true,
      ),
      body: arenas.isEmpty
          ? const Center(child: Text("No arenas added yet."))
          : ListView.builder(
              itemCount: arenas.length,
              itemBuilder: (context, index) {
                final arena = arenas[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 3,
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        arena['image'],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(arena['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${arena['location']} • ${arena['price']}"),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditArenaScreen(arena: arena),
                            ),
                          );
                        } else if (value == 'delete') {
                          _deleteArena(arena['id']);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddArenaScreen()),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _deleteArena(int id) {
    setState(() {
      arenas.removeWhere((arena) => arena['id'] == id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Arena deleted successfully')),
    );
  }
}
