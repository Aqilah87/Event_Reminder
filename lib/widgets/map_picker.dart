import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPicker extends StatefulWidget {
  final LatLng? initialPosition;
  final Function(LatLng) onLocationPicked;

  const MapPicker({
    Key? key,
    this.initialPosition,
    required this.onLocationPicked,
  }) : super(key: key);

  @override
  State<MapPicker> createState() => _MapPickerState();
}

class _MapPickerState extends State<MapPicker> {
  late LatLng _selectedPosition;
  late MapController _mapController;
  bool _isLoading = true;
  String _currentTileProvider = 'osm'; // 'osm', 'google', or 'cartodb'

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedPosition = widget.initialPosition ?? LatLng(3.139, 101.6869);
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  String _getTileUrl() {
    switch (_currentTileProvider) {
      case 'google':
        return 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}';
      case 'cartodb':
        return 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png';
      case 'osm':
      default:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }

  List<String>? _getSubdomains() {
    if (_currentTileProvider == 'cartodb') {
      return ['a', 'b', 'c', 'd'];
    }
    return null;
  }

  void _switchTileProvider() {
    setState(() {
      if (_currentTileProvider == 'osm') {
        _currentTileProvider = 'google';
      } else if (_currentTileProvider == 'google') {
        _currentTileProvider = 'cartodb';
      } else {
        _currentTileProvider = 'osm';
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Switched to ${_getTileProviderName()}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  String _getTileProviderName() {
    switch (_currentTileProvider) {
      case 'google':
        return 'Google Maps';
      case 'cartodb':
        return 'CartoDB';
      case 'osm':
      default:
        return 'OpenStreetMap';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Pick Location',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.layers, color: Colors.white),
            onPressed: _switchTileProvider,
            tooltip: 'Switch Map Style',
          ),
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: () {
              widget.onLocationPicked(_selectedPosition);
              Navigator.pop(context);
            },
            tooltip: 'Confirm Location',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.purple.shade700,
                  ),
                  const SizedBox(height: 16),
                  const Text('Loading map...'),
                  const SizedBox(height: 8),
                  Text(
                    'If map doesn\'t load, tap layers icon to switch',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selectedPosition,
                    initialZoom: 15.0,
                    minZoom: 3.0,
                    maxZoom: 18.0,
                    onTap: (tapPosition, point) {
                      setState(() {
                        _selectedPosition = point;
                      });
                      print('📍 Location selected: ${point.latitude}, ${point.longitude}');
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: _getTileUrl(),
                      subdomains: _getSubdomains() ?? const [],
                      userAgentPackageName: 'com.example.reminder_test',
                      maxZoom: 19,
                      tileProvider: NetworkTileProvider(),
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedPosition,
                          width: 80,
                          height: 80,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 50,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                // Map provider indicator
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getTileProviderName(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                
                // Info card at bottom
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.touch_app,
                                color: Colors.purple.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Tap on map to select location',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    'Lat: ${_selectedPosition.latitude.toStringAsFixed(4)}, '
                                    'Lng: ${_selectedPosition.longitude.toStringAsFixed(4)}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontFamily: 'monospace',
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Zoom in button
          FloatingActionButton(
            heroTag: 'zoom_in',
            mini: true,
            backgroundColor: Colors.white,
            onPressed: () {
              final currentZoom = _mapController.camera.zoom;
              _mapController.move(
                _mapController.camera.center,
                currentZoom + 1,
              );
            },
            child: Icon(Icons.add, color: Colors.purple.shade700),
          ),
          const SizedBox(height: 8),
          
          // Zoom out button
          FloatingActionButton(
            heroTag: 'zoom_out',
            mini: true,
            backgroundColor: Colors.white,
            onPressed: () {
              final currentZoom = _mapController.camera.zoom;
              _mapController.move(
                _mapController.camera.center,
                currentZoom - 1,
              );
            },
            child: Icon(Icons.remove, color: Colors.purple.shade700),
          ),
          const SizedBox(height: 16),
          
          // Center to KL button
          FloatingActionButton(
            heroTag: 'center_kl',
            backgroundColor: Colors.purple.shade700,
            onPressed: () {
              final klPosition = LatLng(3.139, 101.6869);
              setState(() {
                _selectedPosition = klPosition;
              });
              _mapController.move(klPosition, 15.0);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Centered to Kuala Lumpur'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: const Icon(Icons.my_location, color: Colors.white),
          ),
        ],
      ),
    );
  }
}