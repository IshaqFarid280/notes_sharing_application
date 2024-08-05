import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:notes_sharing_application/const/colors.dart';
import 'package:notes_sharing_application/controlller/auth_controller.dart';

class MapScreen extends StatefulWidget {
  final String userid;

  const MapScreen({Key? key, required this.userid}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng _currentPosition = LatLng(1.2878, 103.8666);
  final AuthController _authController = Get.find();
  final MapController _mapController = MapController();
  bool _isLocationUpdated = false;
  LatLng? _selectedLocation;

  Future<LatLng?> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationServicesDialog();
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _mapController.move(_currentPosition, 13.0); // Move camera to current position
      _isLocationUpdated = true;
    });

    return _currentPosition;
  }

  void _showLocationServicesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Location Services Disabled'),
          content: Text('Please enable location services to use this feature.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await Geolocator.openLocationSettings();
              },
              child: Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateLocationAndNavigate() async {
    try {
      await _authController.updateLocation(
        widget.userid,
        _currentPosition.latitude,
        _currentPosition.longitude,
      );

      // Wait for 3 seconds after updating the location
      await Future.delayed(Duration(seconds: 3));

      // Navigate to home screen
      Get.toNamed('/main');
    } catch (e) {
      // Handle any errors, e.g., show a snackbar
      Get.snackbar('Error', e.toString());
    }
  }

  void _onTap(LatLng latLng) {
    setState(() {
      _currentPosition = latLng;
      _selectedLocation = latLng;
      _getPlacemark(_selectedLocation!);
    });
  }

  Future<void> _getPlacemark(LatLng location) async {
    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(location.latitude, location.longitude);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        print(
            'Placemark: ${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}');
      }
    } catch (e) {
      print('Error getting placemark: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentPosition,
            initialZoom: 13.0,
            onTap: (tapPosition, latLng) => _onTap(latLng),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.eventorganizerapp.eventorganizerbalcochfypproject',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: _currentPosition,
                  width: 60,
                  height: 60,
                  alignment: Alignment.center,
                  child:  Icon(Icons.location_pin, size: 60, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: Stack(
        children: [
          if (_isLocationUpdated) // Only show the main FAB if the location is updated
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton.extended(
                backgroundColor: redColor,
                icon: Icon(
                  Icons.my_location,
                  color: whiteColor,
                ),
                label: Text(
                  'Add Location',
                  style: TextStyle(color: whiteColor),
                ),
                onPressed: _updateLocationAndNavigate,
              ),
            ),
          Positioned(
            bottom: _isLocationUpdated ? 80 : 16, // Adjust the position based on the visibility of the main FAB
            right: 16,
            child: FloatingActionButton(
              backgroundColor: Colors.blue,
              child: Icon(Icons.gps_fixed, color: whiteColor),
              onPressed: _getUserLocation,
            ),
          ),
        ],
      ),
    );
  }
}
