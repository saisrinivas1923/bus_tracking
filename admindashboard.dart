import 'adminstops.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'allbusdata.dart';

class PlaceListPage extends StatefulWidget {
  @override
  _PlaceListPageState createState() => _PlaceListPageState();
}

class _PlaceListPageState extends State<PlaceListPage> {
  Map<String, List<String>> places = {};

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    const String apiUrl = "https://bustracking-hpqq.onrender.com/all-data";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final routes = data['routes'] as Map<String, dynamic>;
        setState(() {
          places = routes.map(
                  (key, value) => MapEntry(key, List<String>.from(value['buses'])));
        });
      } else {
        print("Failed to fetch data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  Future<void> _addPlace(String place) async {
    const String apiUrl = "https://bustracking-hpqq.onrender.com/add-station";
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({'station': place, 'buses': []}),
      );
      if (response.statusCode == 200) {
        setState(() {
          places[place] = [];
        });
        print("Place added successfully");
      } else {
        print("Failed to add place. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error adding place: $e");
    }
  }

  Future<void> _addBus(String place, String bus) async {
    const String apiUrl = "https://bustracking-hpqq.onrender.com/add-bus";
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({'station': place, 'bus': bus}),
      );
      if (response.statusCode == 200) {
        setState(() {
          places[place]?.add(bus);
        });
        print("Bus added successfully");
      } else {
        print("Failed to add bus. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error adding bus: $e");
    }
  }

  Future<void> _deleteBus(String place, String bus) async {
    const String apiUrl = "https://bustracking-hpqq.onrender.com/remove-bus";
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({'station': place, 'bus': bus}),
      );
      if (response.statusCode == 200) {
        setState(() {
          places[place]?.remove(bus);
          if (places[place]!.isEmpty) {
            places.remove(place);
          }
        });
        print("Bus deleted successfully");
      } else {
        print("Failed to delete bus. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error deleting bus: $e");
    }
  }

  Future<void> _deletePlace(String place) async {
    const String apiUrl =
        "https://bustracking-hpqq.onrender.com/remove-station";
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({'station': place}),
      );
      if (response.statusCode == 200) {
        setState(() {
          places.remove(place);
        });
        print("Place deleted successfully");
      } else {
        print("Failed to delete place. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error deleting place: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: [
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => AdminMapPage()));
          }, icon: Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Icon(Icons.not_listed_location_outlined),
          ),iconSize: 30,),
        ],
      ),
      body: places.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView(
        children: places.keys.map((place) {
          return ExpansionTile(
            title: Text(place),
            children: [
              ...places[place]!.map((bus) {
                return ListTile(
                  title: Text(bus),
                  onTap: () => {
                    print(bus),
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ManageStopsScreen(bus: bus)),
                    ),
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteBus(place, bus),
                  ),
                );
              }).toList(),
              ListTile(
                leading: Icon(Icons.add, color: Colors.green),
                title: Text('Add Bus'),
                onTap: () => _addBusDialog(place),
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete Place'),
                onTap: () => _deletePlace(place),
              ),
            ],
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPlaceDialog,
        child: Icon(Icons.add),
        tooltip: 'Add Place',
      ),
    );
  }

  void _addPlaceDialog() {
    String newPlace = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Place'),
          content: TextField(
            decoration: InputDecoration(labelText: 'Place'),
            onChanged: (value) {
              newPlace = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (newPlace.isNotEmpty) {
                  _addPlace(newPlace);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addBusDialog(String place) {
    String newBus = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Bus to $place'),
          content: TextField(
            decoration: InputDecoration(labelText: 'Bus Number'),
            onChanged: (value) {
              newBus = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (newBus.isNotEmpty) {
                  _addBus(place, newBus);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class BusDetailPage extends StatelessWidget {
  final String place;
  final String bus;

  BusDetailPage({required this.place, required this.bus});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bus Details'),
      ),
      body: Center(
        child: Text(
          'Details for Bus $bus at $place',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}