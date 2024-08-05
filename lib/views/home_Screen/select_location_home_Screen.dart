import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:notes_sharing_application/const/colors.dart';
import 'package:notes_sharing_application/widgets_common/our_button.dart';

class SelectLocationHomeScreen extends StatefulWidget {
  final String userid;

  SelectLocationHomeScreen({required this.userid});

  @override
  _SelectLocationHomeScreenState createState() =>
      _SelectLocationHomeScreenState();
}

class _SelectLocationHomeScreenState extends State<SelectLocationHomeScreen> {
  LatLng? _selectedLocation;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  final MapController _mapController = MapController();

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _selectedLocation = LatLng(position.latitude, position.longitude);
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
      // _searchController.clear();
      _getPlacemark(_selectedLocation!);
      _mapController.move(_selectedLocation!,
          13.0); // Move the map's center to the new location
      // Optionally, show a snackbar with the address
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Selected: $address')));
    });
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _submitLocation,
          ),
        ],
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
                            child: Icon(Icons.location_on_outlined, color: darkFontGrey,),
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
          Expanded(
            child: _selectedLocation == null
                ? Center(child: CircularProgressIndicator())
                : FlutterMap(
                    mapController: _mapController, // Add this line
                    options: MapOptions(
                      initialCenter: _selectedLocation!,
                      initialZoom: 13.0,
                      onTap: (tapPosition, latLng) => _onTap(latLng),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      ),
                      MarkerLayer(
                        markers: [
                          if (_selectedLocation != null)
                            Marker(
                              width: 80.0,
                              height: 80.0,
                              point: _selectedLocation!,
                              child: Container(
                                child: Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                            ),
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
