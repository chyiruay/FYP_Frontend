import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/api_service.dart';
import '../models/shelter.dart';
import '../utils/distance.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _controller;
  LocationData? _currentLocation;
  final Location _location = Location();
  Shelter? _selectedShelter;
  bool _autoSelected = false; // Track if auto-selection has occurred

  List<Shelter> _shelters = [];

  Future<void> _loadShelterPositions() async {
    try {
      final shelters = await ApiService.fetchShelters();
      setState(() {
        _shelters = shelters;
      });
    } catch (e) {
      print('Error fetching shelters: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadShelterPositions();
  }

  Future<void> _getCurrentLocation() async {
    final permission = await _location.hasPermission();
    if (permission == PermissionStatus.denied) {
      await _location.requestPermission();
    }

    final serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      await _location.requestService();
    }

    final location = await _location.getLocation();
    setState(() {
      _currentLocation = location;

      if (!_autoSelected && _currentLocation != null) {
        final userLatLng = LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);
        _selectedShelter = _findNearestShelter(userLatLng);
        _autoSelected = true;
      }
    });
  }

  Shelter? _findNearestShelter(LatLng userLatLng) {
    final availableShelters = _shelters.where((shelter) => shelter.available).toList();
    if (availableShelters.isEmpty) return null;
    availableShelters.sort((a, b) => distanceInMetres(userLatLng, a.location)
        .compareTo(distanceInMetres(userLatLng, b.location)));
    return availableShelters.first;
  }

  Future<void> _startNavigation() async {
    if (_selectedShelter == null) return;

    final destinationLat = _selectedShelter!.location.latitude;
    final destinationLng = _selectedShelter!.location.longitude;

    // Create Google Maps navigation URL
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$destinationLat,$destinationLng&travelmode=driving';

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: try to open Google Maps app directly
        final mapsUrl = 'comgooglemaps://?daddr=$destinationLat,$destinationLng&directionsmode=driving';
        final mapsUri = Uri.parse(mapsUrl);
        if (await canLaunchUrl(mapsUri)) {
          await launchUrl(mapsUri);
        } else {
          // Show error if Google Maps is not available
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Google Maps is not available on this device'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening Google Maps: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showShelterInstructions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange),
              const SizedBox(width: 8),
              const Text('Shelter Instructions'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.format_list_bulleted, color: Colors.orange, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Important Guidelines:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInstructionItem('Follow the instructions of shelter staff'),
                      _buildInstructionItem('Maintain quiet and orderly behavior'),
                      _buildInstructionItem('Practice personal hygiene and take care of your belongings'),
                      _buildInstructionItem('Respect other evacuees'),
                      _buildInstructionItem('Adhere to designated time and area restrictions at the shelter'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInstructionItem(String instruction) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 12),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              instruction,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEmergencyContacts() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.phone, color: Colors.red),
              const SizedBox(width: 8),
              const Text('Emergency Contacts'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning section
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'WARNING: Sending false messages to emergency numbers is a criminal offence. If convicted, the maximum penalty is a fine of RM50,000, 1 year imprisonment, or both.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.red.shade700,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Contact list
                _buildContactItem('Fire and Rescue Department (BOMBA)', '999'),
                _buildContactItem('Police (PDRM)', '999'),
                _buildContactItem('Malaysian Civil Defence Force (APM)', '999'),
                _buildContactItem('National Disaster Management Agency (NADMA)', '03-8064 2400'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContactItem(String name, String number) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => _makePhoneCall(number),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.phone, size: 18, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(
                    number,
                    style: const TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.red
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    try {
      // Close the dialog first
      Navigator.of(context).pop();
      
      // Create the phone call URL
      final url = 'tel:$phoneNumber';
      final uri = Uri.parse(url);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        // Fallback: try to open the phone app with the number pre-filled
        final fallbackUrl = 'tel://$phoneNumber';
        final fallbackUri = Uri.parse(fallbackUrl);
        if (await canLaunchUrl(fallbackUri)) {
          await launchUrl(fallbackUri);
        } else {
          // Show error if phone app is not available
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Phone app is not available on this device'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error making phone call: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentLocation == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final userLatLng = LatLng(
      _currentLocation!.latitude!,
      _currentLocation!.longitude!,
    );

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: userLatLng,
              zoom: 15,
            ),
            myLocationEnabled: true,
            onMapCreated: (controller) => _controller = controller,
            markers: {
              // User location
              Marker(
                markerId: const MarkerId('user'),
                position: userLatLng,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                infoWindow: const InfoWindow(title: 'You are here'),
              ),

              // Shelter markers
              ..._shelters.map((shelter) {
                final isAvailable = shelter.available;
                return Marker(
                  markerId: MarkerId(shelter.name),
                  position: shelter.location,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    isAvailable ? BitmapDescriptor.hueRed : BitmapDescriptor.hueAzure,
                  ),
                  infoWindow: InfoWindow(
                    title: shelter.name + (isAvailable ? '' : ' (not available)'),
                    snippet: (shelter.address.isNotEmpty
                        ? shelter.address
                        : 'Emergency Shelter'),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedShelter = shelter;
                      _autoSelected = true; // After manual override, never auto-select again
                    });
                  },
                );
              }),
            },

            // Route line to the selected shelter
            polylines: _selectedShelter == null
                ? {}
                : {
              Polyline(
                polylineId: const PolylineId("route"),
                color: Colors.green,
                width: 5,
                points: [userLatLng, _selectedShelter!.location],
              )
            },
          ),
          
          // Floating buttons in upper right corner
          Positioned(
            top: 100, // Below the app bar
            right: 16,
            child: Column(
              children: [
                // Instructions button
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: FloatingActionButton(
                    heroTag: "instructions",
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    onPressed: _showShelterInstructions,
                    child: const Icon(Icons.info_outline, size: 24),
                  ),
                ),
                // Emergency contacts button
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: FloatingActionButton(
                    heroTag: "emergency",
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    onPressed: _showEmergencyContacts,
                    child: const Icon(Icons.phone, size: 24),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Beautified bottom info card
      bottomNavigationBar: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _selectedShelter == null
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Material(
                  elevation: 12,
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.house, color: _selectedShelter!.available ? Colors.deepPurple : Colors.grey, size: 28),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _selectedShelter!.name + (_selectedShelter!.available ? '' : ' (not available)'),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.grey),
                              onPressed: () => setState(() => _selectedShelter = null),
                            ),
                          ],
                        ),
                        if (_selectedShelter!.address.isNotEmpty || !_selectedShelter!.available)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_selectedShelter!.address.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4.0),
                                    child: Text(
                                      'Address: ${_selectedShelter!.address}',
                                      style: const TextStyle(fontSize: 15, color: Colors.black54),
                                    ),
                                  ),
                                if (_selectedShelter!.capacity > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4.0),
                                    child: Text(
                                      'Capacity: ${_selectedShelter!.capacity}',
                                      style: const TextStyle(fontSize: 15, color: Colors.black54),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: Text(
                                    'Has water: ${_selectedShelter!.hasWater ? "Yes" : "No"}',
                                    style: const TextStyle(fontSize: 15, color: Colors.black54),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: Text(
                                    'Has food: ${_selectedShelter!.hasFood ? "Yes" : "No"}',
                                    style: const TextStyle(fontSize: 15, color: Colors.black54),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: Text(
                                    'Is accessible: ${_selectedShelter!.isAccessible ? "Yes" : "No"}',
                                    style: const TextStyle(fontSize: 15, color: Colors.black54),
                                  ),
                                ),
                                if (_selectedShelter!.notes != null && _selectedShelter!.notes!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4.0),
                                    child: Text(
                                      'Notes: ${_selectedShelter!.notes}',
                                      style: const TextStyle(fontSize: 15, color: Colors.black54),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.navigation),
                            label: const Text("Start Navigation"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              elevation: 4,
                            ),
                            onPressed: _selectedShelter!.available ? _startNavigation : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
