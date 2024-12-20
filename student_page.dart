import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class StudentPage extends StatefulWidget {
  const StudentPage({Key? key}) : super(key: key);

  @override
  State<StudentPage> createState() => _StudentPageState();
}

final TextEditingController _busNumberController = TextEditingController();
final String apiUrl = 'https://bustracking-j13i.onrender.com';
LatLng? _busLocation; // Will be updated after fetching bus data

// Function to get bus location
Future<void> getBusLocation(String busNumber) async {
  try {
    final response = await http.post(
      Uri.parse('$apiUrl/busnumber'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'busNumber': busNumber,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Bus ${data['busNumber']} location: Latitude ${data['latitude']}, Longitude ${data['longitude']}');

      // Update the bus location
      _busLocation = LatLng(data['latitude'], data['longitude']);
    } else {
      print('Failed to retrieve bus location. ${response.body}');
    }
  } catch (e) {
    print('Error occurred: $e');
  }
}

class _StudentPageState extends State<StudentPage> {
  final TextEditingController departureController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();

  void navigateToMapPage() async {
    String busNumber = _busNumberController.text.trim();
    if (busNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid bus number")),
      );
      return;
    }

    // Fetch the bus location before navigation
    await getBusLocation(busNumber);

    // Check if location is available
    if (_busLocation != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StudentMapPage(busNumber: busNumber),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bus location not available")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Where is My Bus'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: destinationController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Destination Station',
                  prefixIcon: Icon(Icons.directions_bus_filled),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 2,
                      color: Color.fromARGB(255, 17, 78, 184),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: departureController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Departure Station',
                  prefixIcon: Icon(Icons.directions_bus_filled),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 2,
                      color: Color.fromARGB(255, 17, 78, 184),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
                child: const SizedBox(
                  width: double.infinity,
                  height: 24,
                  child: Center(
                    child: Text(
                      "Find Buses",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  '(or)',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _busNumberController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter Bus Number',
                  prefixIcon: Icon(Icons.search),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 2,
                      color: Color.fromARGB(255, 17, 78, 184),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: navigateToMapPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
                child: const SizedBox(
                  width: double.infinity,
                  height: 24,
                  child: Center(
                    child: Text(
                      "Find Bus",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StudentMapPage extends StatefulWidget {
  final String busNumber;

  const StudentMapPage({Key? key, required this.busNumber}) : super(key: key);

  @override
  State<StudentMapPage> createState() => _StudentMapPageState();
}

class _StudentMapPageState extends State<StudentMapPage> {
  final MapController _mapController = MapController();

  void _recenterMap() {
    if (_busLocation != null) {
      _mapController.move(_busLocation!, 15.0);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bus location not available")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bus Location: ${widget.busNumber}")),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _busLocation,
              zoom: 15.0,
              maxZoom: 18.4,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              if (_busLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _busLocation!,
                      width: 50,
                      height: 50,
                      builder: (context) => const Icon(
                        Icons.directions_bus,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            bottom: 80,
            right: 20,
            child: FloatingActionButton(
              onPressed: _recenterMap,
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}
