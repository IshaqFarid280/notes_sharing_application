
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:notes_sharing_application/const/colors.dart';
import 'package:notes_sharing_application/controlller/event_controller.dart';
import 'package:notes_sharing_application/views/home_Screen/select_location_home_Screen.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import 'package:notes_sharing_application/widgets_common/our_button.dart';
import 'package:photo_view/photo_view.dart';

class AddNewSubjectScreen extends StatefulWidget {
  final String currentUserUid;

  AddNewSubjectScreen({required this.currentUserUid});

  @override
  State<AddNewSubjectScreen> createState() => _AddNewSubjectScreenState();
}

class _AddNewSubjectScreenState extends State<AddNewSubjectScreen> {
  final EventController _eventController = Get.put(EventController());

  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDateController = TextEditingController();
  final TextEditingController _eventTypeController = TextEditingController();
  final TextEditingController _visibilityController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  List<XFile> _selectedImages = [];

  bool _isLoading = false; // Variable to manage loading state

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // Variables for location
  double? _latitude;
  double? _longitude;


  Future<void> _pickImages() async {
    final ImagePicker _picker = ImagePicker();
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        _selectedImages = pickedFiles;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
        _updateDateTime();
      });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime)
      setState(() {
        _selectedTime = picked;
        _updateDateTime();
      });
  }

  void _updateDateTime() {
    if (_selectedDate != null && _selectedTime != null) {
      final DateTime combined = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      _eventDateController.text = combined.toIso8601String();
    }
  }
  Future<void> _navigateToMapScreen(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectLocationHomeScreen(userid: widget.currentUserUid),
      ),
    );
    if (result != null && result is LatLng) {
      String address = await _getAddressFromLatLng(result);
      setState(() {
        _eventTypeController.text = address;
        _latitude = result.latitude;
        _longitude = result.longitude;
      });
    }
  }

  Future<String> _getAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        return '${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}';
      }
    } catch (e) {
      print('Error getting placemark: $e');
    }
    return 'Unknown location';
  }

  Future<void> _postEvent() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      await _eventController.postEvent(
          title: _eventNameController.text,
          description: _detailsController.text,
          dateTime: DateTime.parse(_eventDateController.text),
          visibility: _visibilityController.text,
          userId: widget.currentUserUid,
          images: _selectedImages,
          location: _eventTypeController.text,
        latitude: _latitude!,
        longitude: _longitude!,

      );
      Navigator.pop(context);
    } catch (e) {
      print(e.toString());
      Get.snackbar("Error", '${e.toString()}', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _viewImage(BuildContext context, String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(),
          body: PhotoView(
            imageProvider: FileImage(File(imagePath)),
          ),
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.4,
          color: darkFontGrey.withOpacity(0.6),
          child: _selectedImages.isNotEmpty
              ? Image.file(
            File(_selectedImages[0].path),
            fit: BoxFit.cover,
          )
              : Center(child: Icon(Icons.upload_rounded, size: 100, color: Colors.white.withOpacity(0.7),)),
        ),
        if (_selectedImages.length > 1)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.1,
              color: Colors.black.withOpacity(0.5),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length - 1,
                itemBuilder: (context, index) {
                  final imageIndex = index + 1;
                  return GestureDetector(
                    onTap: () => _viewImage(context, _selectedImages[imageIndex].path),
                    child: Container(


                      margin: EdgeInsets.symmetric(horizontal: 4.0),
                      width: MediaQuery.of(context).size.height * 0.1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_selectedImages[imageIndex].path),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(14.0),
        child: InkWell(
          onTap: _postEvent,
          child: Container(
            width: MediaQuery.of(context).size.width*1,
            height: MediaQuery.of(context).size.height*0.06,
            decoration: BoxDecoration(
              color: Colors.yellow,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Center(
              child: Container(
                 child: _isLoading
                    ? CircularProgressIndicator(color: Colors.black) // Loading indicator
                    : Text('Submit', style: TextStyle(color: darkFontGrey, fontSize: 16.0, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ),
      ),
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios),
        ),
        title: Text('Add New Event'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImages,
              child: _buildImageGrid(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _eventNameController,
                decoration: InputDecoration(
                  hintText: 'Event Name',
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Center(
                          child: Text(
                            _selectedDate == null
                                ? 'Select Date'
                                : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectTime(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Center(
                          child: Text(
                            _selectedTime == null
                                ? 'Select Time'
                                : _selectedTime!.format(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _navigateToMapScreen(context),

              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Center(
                    child: Text(
                      _eventTypeController.text.isEmpty
                          ? 'Event Location'
                          : _eventTypeController.text,
                    ),
                  ),
                ),
              ),
            ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => _showVisibilityBottomSheet(context),
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _visibilityController.text.isEmpty
                          ? 'Event Visibility'
                          : _visibilityController.text,
                    ),
                  ),
                  Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _detailsController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Event Details',
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _showVisibilityBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        String selectedVisibility = _visibilityController.text;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  RadioListTile<String>(
                    title: const Text('Public'),
                    value: 'Public',
                    groupValue: selectedVisibility,
                    onChanged: (String? value) {
                      setState(() {
                        selectedVisibility = value!;
                        _visibilityController.text = value!;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Private'),
                    value: 'Private',
                    groupValue: selectedVisibility,
                    onChanged: (String? value) {
                      setState(() {
                        selectedVisibility = value!;
                        _visibilityController.text = value!;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

}
