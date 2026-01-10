import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo; // ✅ Import for search

class MapPage extends StatefulWidget {
  final LatLng? initialLocation;
  final bool isSelecting; // ✅ Control if we are picking or just viewing

  const MapPage({
    Key? key,
    this.initialLocation,
    this.isSelecting = true, // Default to true (picking mode)
  }) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late final MapController _mapController;
  late LatLng _selectedPosition;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController(); // ✅ Search controller
  String _selectedAddress = "Fetching address..."; // ✅ Store address

  // Default to Kuala Lumpur
  static const LatLng _defaultLocation = LatLng(3.1390, 101.6869);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedPosition = widget.initialLocation ?? _defaultLocation;
    
    // Only fetch current location if we are selecting AND no initial location was provided
    if (widget.isSelecting && widget.initialLocation == null) {
      _getCurrentLocation();
    } else {
      _isLoading = false;
      // If viewing an existing location, get its address
      _getAddress(_selectedPosition);
    }
  }

  // ✅ Convert LatLng to Address (Reverse Geocoding)
  Future<void> _getAddress(LatLng position) async {
    try {
      setState(() {
        _selectedAddress = "Fetching address...";
      });

      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        geo.Placemark place = placemarks[0];
        // Construct a readable address string
        String address = [
          place.street,
          place.subLocality,
          place.locality,
          place.country
        ].where((element) => element != null && element.isNotEmpty).join(', ');
        
        if (mounted) {
          setState(() {
            _selectedAddress = address;
            // Optionally fill search bar with this address if picking
            if (widget.isSelecting) {
              _searchController.text = address;
            }
          });
        }
      } else {
        setState(() => _selectedAddress = "Address not found");
      }
    } catch (e) {
      debugPrint("Error getting address: $e");
      if (mounted) {
        setState(() => _selectedAddress = "Unknown Location");
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      
      if (mounted) {
        final newPos = LatLng(pos.latitude, pos.longitude);
        setState(() {
          _selectedPosition = newPos;
          _mapController.move(_selectedPosition, 15.0);
        });
        // Get address for current location
        _getAddress(newPos);
      }
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  // ✅ New method to handle search
  Future<void> _searchPlace(String query) async {
    if (query.isEmpty) return;
    
    // Close keyboard
    FocusScope.of(context).unfocus();

    try {
      // Use geocoding package to find coordinates from address/name
      List<geo.Location> locations = await geo.locationFromAddress(query);
      
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final newPos = LatLng(loc.latitude, loc.longitude);
        
        setState(() {
          _selectedPosition = newPos;
          _mapController.move(newPos, 15.0); // Move map to searched location
        });
        // Update address display
        _getAddress(newPos);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location not found')),
          );
        }
      }
    } catch (e) {
      print("Search Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error finding location. Try a different name.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleTap(TapPosition tapPosition, LatLng point) {
    // ✅ Only allow moving the pin if we are in Selecting mode
    if (widget.isSelecting) {
      setState(() {
        _selectedPosition = point;
      });
      // ✅ Fetch address when tapping
      _getAddress(point);
    }
  }

  void _confirmSelection() {
    Navigator.of(context).pop(_selectedPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ✅ Change title based on mode
        title: Text(widget.isSelecting ? 'Pick Location' : 'Event Location'),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
        actions: [
          // ✅ Only show Save button if selecting
          if (widget.isSelecting)
            TextButton.icon(
              onPressed: _confirmSelection,
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedPosition,
              initialZoom: 15.0,
              onTap: _handleTap, // Logic inside handles readonly check
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.reminder_test',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedPosition,
                    width: 50,
                    height: 50,
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 50,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ✅ Search Bar Overlay (Only shown when selecting)
          if (widget.isSelecting)
            Positioned(
              top: 10,
              left: 15,
              right: 15,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) => _searchPlace(value),
                  decoration: InputDecoration(
                    hintText: 'Search city, place...',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search, color: Colors.purple),
                      onPressed: () => _searchPlace(_searchController.text),
                    ),
                  ),
                ),
              ),
            ),
            
          // ✅ Address Display Card (Bottom)
          Positioned(
            bottom: widget.isSelecting ? 80 : 20, // Move up if FAB exists
            left: 15,
            right: 15,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.redAccent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedAddress,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: widget.isSelecting
          ? FloatingActionButton(
              backgroundColor: Colors.purple.shade700,
              child: const Icon(Icons.my_location, color: Colors.white),
              onPressed: _getCurrentLocation,
            )
          : null, // Hide GPS button in view mode
    );
  }
}