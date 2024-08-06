import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:notes_sharing_application/const/colors.dart';
import 'package:notes_sharing_application/widgets_common/our_button.dart';

class EventsMapScreen extends StatefulWidget {
  @override
  _EventsMapScreenState createState() => _EventsMapScreenState();
}

class _EventsMapScreenState extends State<EventsMapScreen> {
  final List<Marker> _markers = [];
  final MapController _mapController = MapController();
  Map<String, dynamic>? _selectedEventData;
  LatLng? _infoWindowPosition;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadEventMarkers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _loadEventMarkers(); // Reload markers with the search query applied
    });
  }

  Future<void> _loadEventMarkers() async {
    final snapshot = await FirebaseFirestore.instance.collection('events').get();
    _markers.clear(); // Clear existing markers before adding new ones
    for (var document in snapshot.docs) {
      final data = document.data() as Map<String, dynamic>;
      final address = data['locationevent'];

      if ((data['title'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (data['description'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase())) {
        if (address != null) {
          List<Location> locations = await locationFromAddress(address);
          if (locations.isNotEmpty) {
            final location = locations.first;
            setState(() {
              _markers.add(
                Marker(
                  point: LatLng(location.latitude, location.longitude),
                  child: GestureDetector(
                    onTap: () {
                      _showEventDetails(data, LatLng(location.latitude, location.longitude));
                    },
                    child: Icon(Icons.location_on, color: Colors.red, size: 40),
                  ),
                ),
              );
            });
          }
        }
      }
    }
  }

  void _showEventDetails(Map<String, dynamic> eventData, LatLng position) {
    setState(() {
      _selectedEventData = eventData;
      _infoWindowPosition = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events Map'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Events',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(0, 0),
                    initialZoom: 2,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: _markers,
                    ),
                  ],
                ),
                if (_selectedEventData != null && _infoWindowPosition != null)
                  Positioned(
                    left: MediaQuery.of(context).size.width / 2 - 100,
                    top: MediaQuery.of(context).size.height / 2 - 150,
                    child: _buildInfoWindow(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoWindow() {
    final dateTime = _selectedEventData!['dateTime'] != null
        ? (_selectedEventData!['dateTime'] as Timestamp).toDate()
        : null;
    final formattedDateTime = dateTime != null
        ? DateFormat('yyyy-MM-dd – kk:mm').format(dateTime)
        : 'No Date';

    return Container(
      width: MediaQuery.of(context).size.width * 0.6,
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            _selectedEventData!['images'][0],
            width: MediaQuery.of(context).size.width * 0.59,
          ),
          Text(
            _selectedEventData!['title'] ?? 'No Title',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4.0),
          Text(
            _selectedEventData!['description'] ?? 'No Description',
            style: TextStyle(),
            maxLines: 2,
          ),
          SizedBox(height: 8.0),
          normalTextwithoutcenter(text: ' $formattedDateTime', color: Colors.black),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedEventData = null;
                  _infoWindowPosition = null;
                });
              },
              child: normalText(text: 'Close', color: darkFontGrey),
            ),
          ),
        ],
      ),
    );
  }
}
