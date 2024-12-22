import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ManageStopsScreen extends StatefulWidget {
  final String bus;

  const ManageStopsScreen({Key? key, required this.bus}) : super(key: key);

  @override
  _ManageStopsScreenState createState() => _ManageStopsScreenState();
}

class _ManageStopsScreenState extends State<ManageStopsScreen> {
  List<String> stops = [];
  bool isLoading = true;

  final String baseUrl = 'https://bustracking-hpqq.onrender.com';

  @override
  void initState() {
    super.initState();
    fetchStops();
  }

  Future<void> fetchStops() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/get-stops'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'busNumber': widget.bus}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          stops = List<String>.from(data['stops'] ?? []);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch stops: ${response.body}');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showSnackBar('Error fetching stops: $error');
    }
  }

  Future<void> addStop(String stop) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add-stops'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'busNumber': widget.bus, 'stop': stop}),
      );

      if (response.statusCode == 200) {
        setState(() {
          stops.add(stop);
        });
        _showSnackBar('Stop added successfully');
      } else {
        throw Exception('Failed to add stop: ${response.body}');
      }
    } catch (error) {
      _showSnackBar('Error adding stop: $error');
    }
  }

  Future<void> removeStop(String stop) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/remove-stops'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'busNumber': widget.bus, 'stop': stop}),
      );

      if (response.statusCode == 200) {
        setState(() {
          stops.remove(stop);
        });
        _showSnackBar('Stop removed successfully');
      } else {
        throw Exception('Failed to remove stop: ${response.body}');
      }
    } catch (error) {
      _showSnackBar('Error removing stop: $error');
    }
  }

  Future<void> reorderStops() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/modify-stops'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'busNumber': widget.bus, 'stops': stops}),
      );

      if (response.statusCode == 200) {
        _showSnackBar('Stops reordered successfully');
      } else {
        throw Exception('Failed to reorder stops: ${response.body}');
      }
    } catch (error) {
      _showSnackBar('Error reordering stops: $error');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showAddStopDialog() {
    String stopName = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Stop'),
          content: TextField(
            onChanged: (value) => stopName = value.trim(),
            decoration: InputDecoration(
              labelText: 'Stop Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (stopName.isNotEmpty) {
                  addStop(stopName);
                  Navigator.pop(context);
                } else {
                  _showSnackBar('Stop name cannot be empty');
                }
              },
              child: Text('Okay'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stops for Bus ${widget.bus}')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ReorderableListView(
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) newIndex -= 1;
                        final item = stops.removeAt(oldIndex);
                        stops.insert(newIndex, item);
                      });
                      reorderStops();
                    },
                    children: [
                      for (int index = 0; index < stops.length; index++)
                        ListTile(
                          key: ValueKey(stops[index]),
                          title: Text(stops[index]),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => removeStop(stops[index]),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStopDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
