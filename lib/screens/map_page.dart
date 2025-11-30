import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/location_service.dart';

class MapPage extends StatefulWidget {
  final LatLng? initialLocation;
  MapPage({this.initialLocation});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _controller;
  LatLng? _selected;
  CameraPosition _initialCamera = CameraPosition(target: LatLng(3.1390, 101.6869), zoom: 12); // KL fallback

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _selected = widget.initialLocation;
      _initialCamera = CameraPosition(target: widget.initialLocation!, zoom: 16);
    } else {
      _setToCurrent();
    }
  }

  void _setToCurrent() async {
    try {
      final pos = await LocationService.getCurrentLocation();
      setState(() {
        _initialCamera = CameraPosition(target: LatLng(pos.latitude, pos.longitude), zoom: 16);
      });
    } catch (e) {
      // ignore and use fallback
    }
  }

  void _onTap(LatLng latLng) {
    setState(() {
      _selected = latLng;
    });
  }

  void _onSave() {
    if (_selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please pick a location on the map')));
      return;
    }
    Navigator.of(context).pop(_selected); // return LatLng
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
        actions: [
          TextButton(
            onPressed: _onSave,
            child: Text('Save', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: _initialCamera,
        onMapCreated: (c) => _controller = c,
        onTap: _onTap,
        markers: _selected == null
            ? {}
            : {
                Marker(markerId: MarkerId('selected'), position: _selected!)
              },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
