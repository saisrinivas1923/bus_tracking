import 'package:bus_tracking/driverlogin.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'adminlogin.dart';
import 'driver_page.dart';
import 'firebase_options.dart';
import 'student_page.dart';
//import 'driver_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // FlutterBackgroundService back = FlutterBackgroundService();
  // await back.configure(
  //     iosConfiguration: IosConfiguration(),
  //     androidConfiguration: AndroidConfiguration(onStart: (val){},isForegroundMode: true));
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const BusTrackingApp());
}

class BusTrackingApp extends StatelessWidget {
  const BusTrackingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bus Tracking App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: const Text("Bus Tracking App"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Adminlogin()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
                child: SizedBox(
                  width: 110, // Set the desired width
                  height: 38, // Set the desired height
                  child: Center(
                    child: Text(
                      "Admin",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                ),
            SizedBox(height: 20,),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => DriverLoginPage()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
                child: SizedBox(
                  width: 110, // Set the desired width
                  height: 38, // Set the desired height
                  child: Center(
                    child: Text(
                      "Driver",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                ),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => StudentPage()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
                child: SizedBox(
                  width: 110, // Set the desired width
                  height: 38, // Set the desired height
                  child: Center(
                    child: Text(
                      "Student",
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
    );
  }
}
