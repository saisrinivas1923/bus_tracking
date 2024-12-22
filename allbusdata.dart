import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class AdminMapPage extends StatefulWidget {
  @override
  _AdminMapPageState createState() => _AdminMapPageState();
}

class _AdminMapPageState extends State<AdminMapPage> {
  final MapController _mapController = MapController();
  Timer? timer;

  List<Marker> _busMarkers = [];

  // Function to fetch bus locations from the API
  Future<void> _fetchBusLocations() async {
    final response = await http.get(Uri.parse(
        'https://bustracking-hpqq.onrender.com/data')); // Replace with your API URL

    if (response.statusCode == 200) {
      // Parse the JSON data from the API
      Map<String, dynamic> data = jsonDecode(response.body);
      // Create markers from the API data
      setState(() {
        _busMarkers = data.entries.map((entry) {

          // Ensure we only add valid latitude and longitude
          double latitude =
              double.tryParse(entry.value['latitude'].toString()) ?? 0.0;
          double longitude =
              double.tryParse(entry.value['longitude'].toString()) ?? 0.0;
          // print(latitude);
          // print(longitude);
          // print(entry);
          // print("---");
          return Marker(
            point: LatLng(latitude, longitude),
            width: 50,
            height: 50,
            builder: (context) => Stack(
              children: [
                Stack(
                  children: [
                    //Icon(Icons.location_on, color: Colors.red),
                    Container(
                      height: 18,
                      width: 18,
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.all(Radius.circular(100))),
                      child: Center(
                          child: Text(
                        entry.key,
                        style: TextStyle(fontSize: 7, color: Colors.white),
                      )),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList();
      });
    } else {
      // Handle API error here
      print('Failed to load bus data');
    }
  }

  @override
  void initState() {
    super.initState();
    timer=Timer.periodic(const Duration(seconds: 3), (_) async {
      await _fetchBusLocations();
    });
  }

  @override
  void dispose(){
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bus Locations on Map'),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: LatLng(17.0862706, 82.0524117), // Set a default map center
          zoom: 15.0,
          maxZoom: 18.4,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: _busMarkers, // Display the bus markers on the map
          ),
        ],
      ),
    );
  }
}
