import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:notes_sharing_application/const/colors.dart';
import 'package:notes_sharing_application/views/categoryScrenn/bottom_sheet_to_send_notification_screen.dart';
import 'package:notes_sharing_application/widgets_common/our_button.dart';

class NotifyAllUsersScreen extends StatefulWidget {
  final dynamic data;
  const NotifyAllUsersScreen({super.key, required this.data});

  @override
  State<NotifyAllUsersScreen> createState() => _NotifyAllUsersScreenState();
}

class _NotifyAllUsersScreenState extends State<NotifyAllUsersScreen> {
  LatLng? _selectedLocation;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  final MapController _mapController = MapController();
  List<Marker> _userMarkers = [];
  double _range = 5.0; // Initial range in kilometers

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _selectedLocation =
          LatLng(widget.data['latitude'], widget.data['longitude']);
    });
  }

  Future<void> _searchLocation(String query) async {
    setState(() {
      _isSearching = true;
    });
    try {
      List<Location> locations = await locationFromAddress(query);
      List<Map<String, dynamic>> results = [];
      for (Location location in locations) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
            location.latitude, location.longitude);
        String address = placemarks.isNotEmpty
            ? '${placemarks.first.street}, ${placemarks.first.locality}, ${placemarks.first.administrativeArea}, ${placemarks.first.country}'
            : 'Unknown location';
        results.add({'location': location, 'address': address});
      }
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
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

  void _selectLocationFromSearch(Location location, String address) {
    setState(() {
      _selectedLocation = LatLng(location.latitude, location.longitude);
      _searchResults = [];
      _getPlacemark(_selectedLocation!);
      _mapController.move(_selectedLocation!,
          13.0); // Move the map's center to the new location
    });
  }

  Future<void> _fetchUserMarkers() async {
    final userCollection = FirebaseFirestore.instance.collection('users');
    final userDocs = await userCollection.get();

    List<Marker> markers = [];
    for (var doc in userDocs.docs) {
      final userdata = doc.data();
      if (userdata.containsKey('latitude') &&
          userdata.containsKey('longitude')) {
        final double latitude = double.parse(userdata['latitude'].toString());
        final double longitude = double.parse(userdata['longitude'].toString());
        final LatLng position = LatLng(latitude, longitude);
        markers.add(
          Marker(
            width: 80.0,
            height: 80.0,
            point: position,
            child: Icon(
              Icons.person_pin_circle,
              color: Colors.blue,
              size: 40,
            ),
            key: Key(doc.id), // Add a key for easier reference
          ),
        );
      }
    }
    setState(() {
      _userMarkers = markers;
    });
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchUserMarkers();
  }

  void _onTap(LatLng latLng) {
    setState(() {
      _selectedLocation = latLng;
      _getPlacemark(_selectedLocation!);
    });
  }

  void _submitLocation() {
    _searchController.clear();
    Navigator.pop(context, _selectedLocation);
  }

  List<LatLng> _createPolygon(LatLng center, double radiusKm) {
    final List<LatLng> polygon = [];
    final int numberOfPoints = 360;
    final double radiusDegrees = radiusKm /
        111.32; // Approximate conversion factor (1 degree ~ 111.32 km)

    for (int i = 0; i < numberOfPoints; i++) {
      final double angle = (2 * pi * i) / numberOfPoints;
      final double dx = radiusDegrees * cos(angle);
      final double dy = radiusDegrees * sin(angle);
      final LatLng point = LatLng(
        center.latitude + dx,
        center.longitude +
            dy /
                cos(center.latitude *
                    pi /
                    180), // Adjust for longitude distortion at different latitudes
      );
      polygon.add(point);
    }

    return polygon;
  }
  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => BottomSheetToSendNotificationScreen(),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        // extendedPadding: EdgeInsets.zero,



        onPressed: _showBottomSheet,
        label: normalText(text: 'Send Notification', color: whiteColor),
        icon: Icon(Icons.send, color: whiteColor,),
        backgroundColor: Colors.blue.withOpacity(0.6),
      ),
      appBar: AppBar(
        title: Text('Event Notification'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search Location',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        _searchLocation(_searchController.text);
                      },
                    ),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      _searchLocation(value);
                    } else {
                      setState(() {
                        _searchResults = [];
                      });
                    }
                  },
                ),
                if (_isSearching) LinearProgressIndicator(),
                if (_searchResults.isNotEmpty)
                  Container(
                    height: MediaQuery.of(context).size.height * 0.25,
                    child: ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final result = _searchResults[index];
                        final location = result['location'] as Location;
                        final address = result['address'] as String;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          trailing: Icon(Icons.north_west),
                          leading: CircleAvatar(
                            child: Icon(
                              Icons.location_on_outlined,
                              color: darkFontGrey,
                            ),
                            backgroundColor: darkFontGrey.withOpacity(0.09),
                          ),
                          title: normalTextwithoutcenter(
                              text: address,
                              color: Colors.black,
                              weight: FontWeight.w700),
                          subtitle: normalTextwithoutcenter(
                            text: '${location.latitude}, ${location.longitude}',
                            weight: FontWeight.w400,
                            size: 8.0,
                            color: fontGrey.withOpacity(0.8),
                          ),
                          onTap: () {
                            _selectLocationFromSearch(location, address);
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          Slider(
            value: _range,
            min: 5,
            max: 100,
            divisions: 19, // Update divisions to reflect the new range
            label: "${_range.toInt()} km",
            onChanged: (value) {
              setState(() {
                _range = value;
                // Update zoom level based on range
                // Adjust zoom level calculation if needed
                double zoomLevel = 13.0 - (_range / 10);
                _mapController.move(_selectedLocation!, zoomLevel);
                print('zoom level $zoomLevel');
                print('range: $_range');
              });
            },
          ),
          Expanded(
            child: _selectedLocation == null
                ? Center(child: CircularProgressIndicator())
                : FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _selectedLocation!,
                      initialZoom: 13.0,
                      // onTap: (tapPosition, latLng) => _onTap(latLng),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      ),
                      PolygonLayer(
                        polygons: [
                          if (_selectedLocation != null)
                            Polygon(
                              points:
                                  _createPolygon(_selectedLocation!, _range),
                              borderColor: Colors.blue,
                              borderStrokeWidth: 2.0,
                              color: Colors.blue.withOpacity(0.2),
                            ),
                        ],
                      ),
                      MarkerLayer(
                        markers: [
                          if (_selectedLocation != null)
                            Marker(
                              width: 80.0,
                              height: 80.0,
                              point: _selectedLocation!,
                              child: Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ..._userMarkers,
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
