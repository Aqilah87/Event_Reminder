import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapPage extends StatefulWidget {
  final LatLng? initialLocation;

  const MapPage({Key? key, this.initialLocation}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late final MapController _mapController;
  late LatLng _selectedPosition;
  bool _isLoading = true;

  // Default to Kuala Lumpur if GPS fails
  static const LatLng _defaultLocation = LatLng(3.1390, 101.6869);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedPosition = widget.initialLocation ?? _defaultLocation;
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    // Only fetch location if no initial location was passed
    if (widget.initialLocation == null) {
      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          if (mounted) setState(() => _isLoading = false);
          return;
        }

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            if (mounted) setState(() => _isLoading = false);
            return;
          }
        }

        if (permission == LocationPermission.deniedForever) {
          if (mounted) setState(() => _isLoading = false);
          return;
        }

        final pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        
        if (mounted) {
          setState(() {
            _selectedPosition = LatLng(pos.latitude, pos.longitude);
            _mapController.move(_selectedPosition, 15.0);
            _isLoading = false;
          });
        }
      } catch (e) {
        print("Error getting location: $e");
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _handleTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _selectedPosition = point;
    });
  }

  void _confirmSelection() {
    // Return the selected location to the previous screen
    Navigator.of(context).pop(_selectedPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
        actions: [
          TextButton.icon(
            onPressed: _confirmSelection,
            icon: const Icon(Icons.check, color: Colors.white),
            label: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _selectedPosition,
          initialZoom: 15.0,
          onTap: _handleTap,
        ),
        children: [
          TileLayer(
            // ✅ Using OpenStreetMap tiles (No API Key needed)
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple.shade700,
        child: const Icon(Icons.my_location, color: Colors.white),
        onPressed: () {
          _getCurrentLocation();
        },
      ),
    );
  }
}