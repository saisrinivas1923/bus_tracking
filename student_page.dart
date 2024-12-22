import 'dart:async';
import 'dart:convert';
import 'package:bus_tracking/adminstops.dart';
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
final String apiUrl = 'https://bustracking-hpqq.onrender.com';

class _StudentPageState extends State<StudentPage> {
  final TextEditingController departureController = TextEditingController();
  LatLng? _busLocation;
  List<int> routes = [];

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
        setState(() {
          _busLocation = LatLng(data['latitude'], data['longitude']);
        });
      } else {
        print('Failed to retrieve bus location. ${response.body}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Future<void> fetchRoutes(String source) async {
    final url = Uri.parse('$apiUrl/getinfo');
    if (source.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid source")),
      );
      return;
    }
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'station': source}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          routes = (data['station']['buses'] as List)
              .map((e) => int.parse(e.toString()))
              .toList()
            ..sort();
        });
      } else {
        setState(() {
          routes = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No routes found or an error occurred.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to connect to the server.')),
      );
    }
  }

  void navigateToMapPage() async {
    String busNumber = _busNumberController.text.trim();
    if (busNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid bus number")),
      );
      return;
    }
    await getBusLocation(busNumber);
    if (_busLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bus location not available")),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentMapPage(busNumber: busNumber),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: const Text('Where is My Bus'),
      ),
      body:
      Padding(
        padding: const EdgeInsets.only(top:50.0,left:10,right:10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: departureController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter Your Boarding Point',
                  prefixIcon: Icon(Icons.directions_bus_filled),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 2,
                      color: Color.fromARGB(255, 17, 78, 184),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25.0),
              ElevatedButton(
                onPressed: () {
                  final source = departureController.text.trim();
                  if (source.isNotEmpty) {
                    fetchRoutes(source).then((val) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BusRouteInfo(
                            routes: routes,
                            source: source,
                          ),
                        ),
                      );
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid boarding point.'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  "Find Buses",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '(or)',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w300,
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  "Find Bus",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
  final String apiUrl = 'https://bustracking-hpqq.onrender.com';
  LatLng? _busLocation; // Will be updated after fetching bus data
  Timer? timer;
  //int num = 0;
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
        setState(() {
          _busLocation = LatLng(data['latitude'], data['longitude']);
        });

      } else {
        print('Failed to retrieve bus location. ${response.body}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

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
  void initState() {
    super.initState();
    timer=Timer.periodic(const Duration(seconds: 3), (_) async {
      await getBusLocation(widget. busNumber);
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
      appBar: AppBar(title: Text("Bus Location: ${widget.busNumber}")),
      body: Stack(
        children: [
          _busLocation==null? const Center(child: CircularProgressIndicator()) :
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
                        size: 25,
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

class BusRouteInfo extends StatefulWidget {
  final routes,source;

  const BusRouteInfo({super.key,required this.routes,required this.source});

  @override
  State<BusRouteInfo> createState() => _BusRouteInfoState();
}

class _BusRouteInfoState extends State<BusRouteInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
         backgroundColor: Colors.lightBlue,
         title: Text('Buses to ${widget.source}'),
         //centerTitle: true,
       ),
       body:Padding(
         padding: const EdgeInsets.all(10.0),
         child: ListView.builder(
          itemCount: widget.routes.length,
          itemBuilder: (context, index) {
            final route = widget.routes[index];
            return GestureDetector(
              onTap: (){
                Navigator.push(context,MaterialPageRoute(builder: (context)=>ManageStopsScreen(bus: route.toString())));
              },
              child: Card(
                child: ListTile(
                  title: Text('Bus No: ${route}'),
                ),
              ),
            );
          },
               ),
       ),
    );
  }
}
