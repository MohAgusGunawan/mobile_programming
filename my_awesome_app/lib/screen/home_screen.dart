// import 'package:awesomeappp/service/movie.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  @override
  void initState() {
    super.initState();
    _determinePosition().then((value) => {
          print(value.latitude),
          setState(() {
            latitude = value.latitude.toString();
            longitude = value.longitude.toString();
          })
        });
  }

  String latitude = '';
  String longitude = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Latitude: $latitude\nLongitude: $longitude'),
      ),
    );
  }
}
