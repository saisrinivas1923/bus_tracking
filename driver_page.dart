import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
class DriverPage extends StatefulWidget {
  const DriverPage({Key? key}) : super(key: key);

  @override
  State<DriverPage> createState() => _DriverPageState();
}
final TextEditingController _busNumberController = TextEditingController();
class _DriverPageState extends State<DriverPage> {
  bool _isSharing = false;

  void startSharingLocation() async {
    String busNumber = _busNumberController.text.trim();
    if (busNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a bus number")),
      );
      return;
    }
    setState(() {
      _isSharing = true;
    });

    // Simulate a delay for better user feedback
    await Future.delayed(const Duration(seconds: 1));

    // Navigate to Driver Map Page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DriverMapPage(busNumber: busNumber),
      ),
    ).then((_) {
      // Reset the sharing state when coming back
      setState(() {
        _isSharing = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Driver Page")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _busNumberController,
                decoration: const InputDecoration(
                  hintText: "Enter Bus Number",
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 2,
                      color: Color.fromARGB(255, 17, 78, 184),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _isSharing
                  ? const CircularProgressIndicator() // Show loading spinner
                  : ElevatedButton(
                onPressed: startSharingLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
                child: const SizedBox(
                  width: double.infinity, // Set the desired width
                  height: 25, // Set the desired height
                  child: Center(
                    child: Text(
                      "Start Sharing Location",
                      style: TextStyle(
                        fontSize: 18,
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

class DriverMapPage extends StatefulWidget {
  final String busNumber;

  const DriverMapPage({Key? key, required this.busNumber}) : super(key: key);

  @override
  State<DriverMapPage> createState() => _DriverMapPageState();
}

class _DriverMapPageState extends State<DriverMapPage> {
  LatLng? _currentLocation; // Current location of the driver
  final MapController _mapController = MapController(); // Controller for the map
  Location location = Location();
  Timer? _locationUpdateTimer;
  final String apiUrl = 'https://bustracking-j13i.onrender.com';

  // Function to store bus data
  Future<void> storeBusData(String busNumber, double latitude, double longitude) async {
    try {
      print(busNumber);
      print(latitude);
      print(longitude);
      final response = await http.post(
        Uri.parse('$apiUrl/bus'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'busNumber': busNumber,
          'latitude': latitude,
          'longitude': longitude,
        }),
      );

      if (response.statusCode == 200) {
        print('Bus location stored successfully!');
      } else {
        print('Failed to store bus location. ${response.body}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }
  @override
  void initState() {
    super.initState();
    _startPeriodicLocationUpdates();
  }

  void _startPeriodicLocationUpdates() {
    location.requestPermission().then((permissionGranted) {
      if (permissionGranted == PermissionStatus.granted) {
        _locationUpdateTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
          LocationData locationData = await location.getLocation();
          setState(() {
            _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
            storeBusData(_busNumberController.text,locationData.latitude!,locationData.longitude!);
          });
        });
      }
    });
  }

  void _stopSharingLocation() {
    _locationUpdateTimer?.cancel();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Location sharing stopped")),
    );
  }

  void _recenterMap() {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 15.0); // Recenter the map to the current location
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Current location not available")),
      );
    }
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Driver Location")),
      body: Stack(
        children: [
          _currentLocation == null
              ? const Center(child: CircularProgressIndicator())
              : FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _currentLocation,
              zoom: 15.0,
              maxZoom: 18.4,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentLocation!,
                    width: 50.0,
                    height: 50.0,
                    builder: (ctx) => const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 90,
            right: 20,
            child: FloatingActionButton(
              onPressed: _recenterMap,
              child: const Icon(Icons.my_location),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 85,
            child: ElevatedButton(
              onPressed: _stopSharingLocation,
              child: const Text("Stop Sharing Location"),
            ),
          ),
        ],
      ),
    );
  }
}
